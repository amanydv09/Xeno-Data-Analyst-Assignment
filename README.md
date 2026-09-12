# Xeno Data Analyst Assignment - Target Base Reconciliation

## Objective

The objective of this assignment is to reconcile the reported `target_base` for Merchant ID `501` across all Diwali campaigns in October 2026.

The raw communication data contains multiple send attempts, including retries and sends associated with campaigns that are not yet eligible for official reporting. The goal is to identify the correct business logic and reconcile the raw count with Finance's reported target base of **22**.

## Approach

The analysis was performed using SQLite and followed a step-by-step reconciliation process:

1. Inspected the available database tables and campaign records.
2. Calculated the initial raw send count for October 2026.
3. Applied campaign eligibility rules based on creation and processing status.
4. Identified retry relationships using `parent_id`.
5. Mapped retry campaigns back to their original campaign using a recursive CTE.
6. Deduplicated customers across retry chains while preserving valid repeated sends for standalone campaigns.
7. Calculated the final reconciled target base.

## Reconciliation Summary

| Stage | Count |
|---|---:|
| Initial raw send attempts | 30 |
| After campaign eligibility filtering | 26 |
| Final target base after retry-chain reconciliation | **22** |

## Deliverables

### 1. Executable SQL Query Set
File: `1_executable_sql_query_set.sql`

Contains the SQL investigation steps and the final query used to calculate the target base.

### 2. Reconciliation Bridge
File: `2_reconciliation_bridge.md`

Shows how the count moves from the initial raw send count to the final Finance-reconciled target base.

### 3. One Surprising Data Finding
File: `3_surprising_data_finding.md`

Documents an important observation discovered while investigating the data.

## Final Result

**Final Target Base = 22**

The final SQL query was validated against the provided `comm_log.db` SQLite database and returns the expected Finance-reported value of **22**.

## Technology Used

- SQL
- SQLite
- GitHub
