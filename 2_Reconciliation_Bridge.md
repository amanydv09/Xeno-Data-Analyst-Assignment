# Reconciliation Bridge

## Objective

This reconciliation explains how the raw communication send count for Merchant ID `501` in October 2026 is adjusted to match Finance's reported `target_base` of **22**.

The reconciliation was built by progressively applying the reporting rules discovered from the campaign and communication data.

---

## Reconciliation Summary

| Step | Adjustment | Change | Running Count |
|---|---|---:|---:|
| 1 | Initial raw October campaign send attempts | — | 30 |
| 2 | Exclude sends belonging to campaign `9004`, which is still `approval_awaiting` | -4 | 26 |
| 3 | Deduplicate customers across retry chain `9001 → 9002 → 9003` | -3 | 23 |
| 4 | Deduplicate customer `D1` across retry chain `9201 → 9202` | -1 | **22** |
| 5 | Validate repeated sends in standalone campaign `9101` | 0 | **22** |

---

## Step-by-Step Reconciliation

### Step 1 — Initial Raw Send Count

The initial query counts all campaign communication records for:

- Merchant ID `501`
- Communication type `2`
- Send dates within October 2026

This produces:

**Initial Raw Send Count = 30**

At this stage, no campaign eligibility rules or retry-chain adjustments have been applied.

---

### Step 2 — Apply Campaign Eligibility Rules

Campaign `9004` has:

- `creation_status = approval_awaiting`
- `processing_status = processed`

Although communication records already exist for this campaign, it has not completed the required approval workflow and therefore is not eligible for official reporting.

Campaign `9004` contains **4 send attempts**.

Therefore:

**30 - 4 = 26**

**Eligible Send Count = 26**

---

### Step 3 — Reconcile Retry Chain 9001 → 9002 → 9003

Campaigns `9001`, `9002`, and `9003` belong to the same underlying communication because they form a retry chain.

Within this chain:

- Customer `C2` appears in campaigns `9001` and `9002`
- Customer `C3` appears in campaigns `9001`, `9002`, and `9003`

For target-base reporting, the same customer should count only once within the same retry chain.

Adjustments:

- `C2`: 2 attempts → 1 target = **-1**
- `C3`: 3 attempts → 1 target = **-2**

Total adjustment:

**-3**

Therefore:

**26 - 3 = 23**

**Running Target Base = 23**

---

### Step 4 — Reconcile Retry Chain 9201 → 9202

Campaign `9202` is a retry of campaign `9201`.

Customer `D1` appears once in campaign `9201` and again in campaign `9202`.

Since both attempts belong to the same underlying communication, `D1` should count only once.

Adjustment:

**-1**

Therefore:

**23 - 1 = 22**

**Running Target Base = 22**

---

### Step 5 — Validate Standalone Campaign 9101

Campaign `9101` is a standalone campaign and does not belong to a retry chain.

Customer `C20` appears twice in this campaign on different send dates.

According to the reporting rules, repeated sends within a standalone campaign represent separate valid send events and should not be deduplicated as retries.

Therefore, no adjustment is required.

**Adjustment = 0**

The final count remains:

# Final Target Base = 22

---

## Final Reconciliation

**Raw Send Attempts:** 30  
**Campaign Eligibility Adjustment:** -4  
**Retry Chain Adjustments:** -4  

**30 - 4 - 4 = 22**

The reconciled result matches Finance's reported `target_base` of **22**.
