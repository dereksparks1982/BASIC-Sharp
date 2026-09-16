# BASIC# Compound IF Runtime v0.0.38

The reference runtime and BSharp VM evaluate Profile 6 clauses in recorded source order. `and` is true only when all clauses are true; `or` is true when any clause is true. The group, not its individual clauses, owns reactive state.

- Startup evaluates the complete result once.
- False-to-true wakes the action body once.
- A true result remains quiet.
- A false result rearms the group.
- Existing source ordering, settlement, follow-up ordering, and IF loop protection are unchanged.
- ASK reports one canonical joined condition and its complete truth/active state.
- Save format 6 preserves the active state so restore does not replay START or spuriously wake a rule.
