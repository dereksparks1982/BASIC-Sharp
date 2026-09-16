# BASIC# Patch Notes v0.0.38

Creators can now write a real rule from several facts:

```bsharp
IF PLAYER has at least 100 score and @boss is defeated
[
    |then (change @exit gate to unlocked
].
```

Use only `and` or only `or` in one IF. BASIC# intentionally rejects a mixed expression instead of asking a non-programmer to learn precedence rules. Quoted text such as `"rock and roll or blues"` is preserved exactly. The whole condition wakes once when it becomes true and rearms after it becomes false.
