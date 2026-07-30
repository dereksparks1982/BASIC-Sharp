# BASIC# Build Handshake v0.1.17

## Project and version

- **Project:** BASIC# Ruby Bootstrap Compiler
- **Build:** v0.1.17 Reactive IF Rules and Loop Protection
- **Required base:** accepted v0.1.16 Kind-Family Stress and Hardening
- **Required commit:** `fa48287`
- **Required tag:** `v0.1.16`
- **Target version:** `v0.1.17`
- **Project path:** `/home/dereksparks1982/DKLab/Projects/BASIC#`

## Exact package

`BASIC_Sharp_Ruby_Bootstrap_Compiler_v0_1_17_REACTIVE_IF_RULES_AND_LOOP_PROTECTION_CHANGED_FILES_ONLY.zip`

## Completed changes

- Replaced one-pass startup-only IF execution with controlled reactive settling.
- IF wakes only on a false-to-true condition transition.
- IF re-arms after its condition becomes false.
- START facts settle before the first event.
- A complete matched WHEN action list finishes before IF checking begins.
- IF-to-IF cascades run in creator source order until stable.
- Earlier rules awakened by later rules run on the next controlled pass.
- Added plain startup and event-time IF traces.
- Added repeating-world detection and a scaled firing guard.
- Added a 128-rule IF stress lane.
- Added v0.1.16 saved-DKIR compatibility coverage.

## Excluded work

- No new IF grammar.
- No OTHERWISE, AND, OR, numeric comparisons, values, or amounts.
- No Kind selectors in IF.
- No new Heads, Connectors, or official words.
- No event queue, time, repetition, save/load, ASK, bytecode, VM, engine bridge, or self-hosting work.

## Validation results

```text
95 runs
4,546 assertions
0 failures
0 errors
0 skips
```

```text
Runtime stress: PASS
504 Things
10,003 events per execution path
20,006 total event executions
```

```text
Kind-family stress: PASS
256-level ancestry
64 overlapping ancestor Triggers
500 descendant Things
2,000 repeated events per execution path
```

```text
IF-rule stress: PASS
128 chained IF rules
1,000 unrelated events after settling
100 false-to-true reactivation cycles
source/saved-DKIR parity
runtime isolation
deterministic replay
loop protection
```

## Known risks

- Older valid programs with multiple IF rules may now produce intended cascades that did not occur under startup-only checking.
- IF active-state memory must remain private to each runtime instance.
- Loop protection stops the current settling cycle but does not roll back world changes already made in that cycle.
- Timing is observational only and is not an acceptance gate.

## Rollback point

```text
commit fa48287
tag v0.1.16
```

The installer must reset and clean back to `v0.1.16` if installation or validation fails.

## Current continuation point

Candidate built and internally validated. Derek must install, inspect, and accept or reject it before commit and tag.

## Next planned work

After v0.1.17 acceptance, read the updated roadmap and handoff, then present the complete v0.1.18 proposal before implementation.
