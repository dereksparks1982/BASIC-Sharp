# BASIC# Patch Notes v0.1.19

BASIC# can now store plain whole-number values on Things and use explicit damage amounts.

```text
henry has 10 health
(damage henry by 3
(change health of henry to 7
IF [henry has 3 damage ...]
```

The hard arithmetic stays inside the runtime. Creators use named quantities and exact choices. No equations, decimals, percentages, or hidden health formula were added.

Set changes are atomic: if one selected Thing lacks the value or would overflow, nobody in that action line changes.
