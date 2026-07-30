# BASIC# IF-Rule Stress Test v0.1.17

## Default load

```text
128 chained IF rules
128 affected Things
1,000 unrelated events after settling
100 false-to-true reactivation cycles
source-built BSharp IR path
saved-BSharp IR path
intentional two-rule loop
```

## Required proofs

```text
128-rule cascade: PASS
Source order: PASS
No repeated firing while true: PASS
Reactivation after false: PASS
Source and saved-BSharp IR parity: PASS
Separate runtime isolation: PASS
Deterministic final world: PASS
Loop protection: PASS
IF-RULE STRESS TEST: PASS
```

Timing is recorded only. It is not a hard gate.
