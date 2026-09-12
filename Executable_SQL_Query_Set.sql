-- SQL Queries for Target Base Reconciliation

-- Step 1: List tables in the database
SELECT name
FROM sqlite_master
WHERE type = 'table';


-- Step 2: Inspect all campaigns
SELECT *
FROM campaign
WHERE merchant_id = 501
ORDER BY id;


-- Step 3: Naive count of all October campaign send attempts
SELECT COUNT(*) AS naive_send_count
FROM communication_log
WHERE merchant_id = 501
  AND communication_type = '2'
  AND sent_time >= '2026-10-01'
  AND sent_time < '2026-11-01';


-- Step 4: Check campaign status and number of send attempts
SELECT
    c.id AS campaign_id,
    c.name,
    c.parent_id,
    c.creation_status,
    c.processing_status,
    COUNT(cl.id) AS send_attempts
FROM campaign c
LEFT JOIN communication_log cl
    ON c.id = cl.communication_id
WHERE c.merchant_id = 501
GROUP BY
    c.id,
    c.name,
    c.parent_id,
    c.creation_status,
    c.processing_status
ORDER BY c.id;


-- Step 5: Count sends only from campaigns eligible for official reporting
SELECT COUNT(*) AS eligible_send_count
FROM communication_log cl
JOIN campaign c
    ON cl.communication_id = c.id
WHERE cl.merchant_id = 501
  AND cl.communication_type = '2'
  AND cl.sent_time >= '2026-10-01'
  AND cl.sent_time < '2026-11-01'
  AND c.creation_status IN ('approved', 'aborted', 'resumed', 'stopped')
  AND c.processing_status = 'processed';


-- Step 6: Map every campaign to the root of its retry chain
WITH RECURSIVE campaign_roots AS (

    SELECT
        id AS campaign_id,
        id AS root_id
    FROM campaign
    WHERE merchant_id = 501
      AND parent_id IS NULL

    UNION ALL

    SELECT
        c.id AS campaign_id,
        cr.root_id
    FROM campaign c
    JOIN campaign_roots cr
        ON c.parent_id = cr.campaign_id
    WHERE c.merchant_id = 501
)

SELECT *
FROM campaign_roots
ORDER BY root_id, campaign_id;


-- Step 7: Final Target Base calculation
WITH RECURSIVE campaign_roots AS (

    SELECT
        id AS campaign_id,
        id AS root_id
    FROM campaign
    WHERE merchant_id = 501
      AND parent_id IS NULL

    UNION ALL

    SELECT
        c.id AS campaign_id,
        cr.root_id
    FROM campaign c
    JOIN campaign_roots cr
        ON c.parent_id = cr.campaign_id
    WHERE c.merchant_id = 501
),

chain_info AS (

    SELECT
        root_id,
        COUNT(*) AS campaign_count
    FROM campaign_roots
    GROUP BY root_id
),

eligible_sends AS (

    SELECT
        cl.id AS send_id,
        cl.customer_id,
        cl.communication_id,
        cr.root_id,
        ci.campaign_count
    FROM communication_log cl
    JOIN campaign c
        ON cl.communication_id = c.id
    JOIN campaign_roots cr
        ON c.id = cr.campaign_id
    JOIN chain_info ci
        ON cr.root_id = ci.root_id
    WHERE cl.merchant_id = 501
      AND cl.communication_type = '2'
      AND cl.sent_time >= '2026-10-01'
      AND cl.sent_time < '2026-11-01'
      AND c.creation_status IN ('approved', 'aborted', 'resumed', 'stopped')
      AND c.processing_status = 'processed'
),

target_base_by_communication AS (

    SELECT
        root_id,
        CASE
            WHEN MAX(campaign_count) > 1
                THEN COUNT(DISTINCT customer_id)
            ELSE COUNT(*)
        END AS target_base
    FROM eligible_sends
    GROUP BY root_id
)

SELECT
    SUM(target_base) AS final_target_base
FROM target_base_by_communication;
