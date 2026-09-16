# BASIC# Changelog v0.0.39

## Added

- Plain-English IF / OTHERWISE two-sided reactive rules.
- Stable Meaning Profile 7, BSharp Bytecode Profile 7, and Save format 7.
- ASK branch reporting, direct VM/reference parity, complete fixtures, tests, and a 20,000-transition-per-runtime stress lane.
- Plain-English diagnostics for misplaced OTHERWISE and for `ELSE`, which directs creators to use `OTHERWISE`.

## Preserved

- Ordinary one-sided IF behavior and Profile 6 compound conditions.
- Source ordering, atomic actions, follow-up ordering, settlement, and loop protection.
- Every committed Profile 1 through Profile 6 BSBC and disassembly artifact byte-for-byte.

## Excluded

`ELSE`, `ELSE IF`, chained OTHERWISE, nested IF blocks, general `not`, mixed connectors, parentheses, calculations, timers, loops, collections, engine work, editor work, and self-hosting.
