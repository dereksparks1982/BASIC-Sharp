# BASIC# Plain-English OTHERWISE Branches v0.1.39

```bsharp
IF PLAYER has less than 1 health
[
    |then (change PLAYER to defeated
].
OTHERWISE
[
    |then (change PLAYER to alive
].
```

`OTHERWISE` must be the next meaningful Head after its matching IF block. Blank lines and comments may appear between them; another Head may not. At START, the currently matching branch runs once. False-to-true runs IF, true-to-false runs OTHERWISE, and unchanged truth stays quiet. Each selected branch completes before IF settlement continues.

Atomic and compound IF conditions are accepted. Ordinary IF without OTHERWISE is unchanged. BASIC# uses **IF / OTHERWISE**, not IF / ELSE: `ELSE` is rejected with guidance to use `OTHERWISE`. Standalone, conditional, repeated, or chained OTHERWISE sections are also rejected with creator-facing diagnostics.
