# One Surprising Data Finding

The most surprising finding was that repeated customer records cannot always be treated as duplicates.

Within a retry chain, multiple attempts for the same customer belong to the same underlying communication and therefore count only once toward the target base. However, in standalone campaign `9101`, customer `C20` appears twice on different send dates, and both records are valid separate send events.

This means that simply applying `COUNT(DISTINCT customer_id)` would produce an incorrect result. The business context of each campaign and its retry relationship must be considered before deciding whether repeated customer records should be deduplicated.

This distinction was critical in reconciling the raw communication data to Finance's final reported `target_base` of **22**.
