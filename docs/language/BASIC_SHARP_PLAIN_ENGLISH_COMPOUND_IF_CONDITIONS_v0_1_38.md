# BASIC# Plain-English Compound IF Conditions v0.1.38

## Creator forms

```bsharp
IF PLAYER has at least 100 score and @boss is defeated
[
    |then (change @exit gate to unlocked
].

IF PLAYER has less than 1 health or @bridge is broken
[
    |then (change PLAYER to defeated
].
```

`and` requires every clause. `or` requires at least one. State, relation, exact text, exact number, and threshold clauses may be combined in source order. The whole group is one reactive IF condition: it wakes on false-to-true, stays quiet while true, and rearms only after the whole result becomes false.

Connector words inside straight quoted text are literal. A line containing both connectors is rejected; so are empty clauses, nesting, parentheses, and precedence-dependent expressions. Profile 6 does not add general `not`, `OTHERWISE`, or collection conditions.
