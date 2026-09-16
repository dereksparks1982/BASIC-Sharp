# BASIC# Validation v0.0.21

## Automated suite

```text
157 runs
4,841 assertions
0 failures
0 errors
0 skips
```

## Stress lanes

```text
Runtime stress: PASS
Kind-family stress: PASS
IF-rule stress: PASS
Multiple-selection stress: PASS
Value-and-amount stress: PASS
Follow-up-event stress: PASS
```

## Follow-up event validation

```text
Explicit (cause compilation: PASS
Complete body before follow-ups: PASS
IF settlement before follow-ups: PASS
First-created, first-run order: PASS
Nested end-of-line ordering: PASS
Captured that-Kind context: PASS
Fresh event context: PASS
Unmatched continuation: PASS
Failed-body staged-event discard: PASS
Failed-IF staged-event discard: PASS
Follow-up runtime-error stop: PASS
1,024-event loop protection: PASS
Bounded human trace: PASS
Complete structured results: PASS
No automatic hidden events: PASS
Source and saved-BSIR parity: PASS
Separate runtime isolation: PASS
Deterministic replay: PASS
```

Timing is observational only and is not an acceptance gate.

## Corrected clean-base proof

The first installer package safely rejected the accepted project before mutation because its `README.md` base hash was wrong. The corrected package uses the exact v0.0.20 files from commit `c94faec` as its base. Package hashes, accepted-base hashes, addition plan, syntax checks, the full suite, six stress lanes, compiler smoke tests, event-order smoke tests, retired-DKIR diagnostic, and working-tree scope must all pass again during installation.
