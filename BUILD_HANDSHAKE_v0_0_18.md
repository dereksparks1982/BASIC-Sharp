# BASIC# Build Handshake v0.0.18

## Project and version

- **Project:** BASIC# Ruby Bootstrap Compiler
- **Build:** v0.0.18 Multiple Selected Things and Deterministic Set Actions
- **Required base:** accepted v0.0.17 Reactive IF Rules and Loop Protection
- **Required commit:** `78fa0c3`
- **Required tag:** `v0.0.17`
- **Target version:** `v0.0.18`
- **Project path:** `/home/dereksparks1982/DKLab/Projects/BASIC#`

## Exact package

`BASIC_Sharp_Ruby_Bootstrap_Compiler_v0_0_18_MULTIPLE_SELECTED_THINGS_AND_DETERMINISTIC_SET_ACTIONS_CHANGED_FILES_ONLY.zip`

## Completed changes

- Activated the existing `kind_set` / `every Kind` action reference.
- Added deterministic direct and inherited Kind selection from current runtime Things.
- Preserved creator definition order and built-in player-first order where applicable.
- Completed one action line across its whole selection before starting the next line.
- Preserved singular `that Kind` event context after plural actions.
- Added set support for damage, change, carry, and unlock.
- Added nonfatal empty-set explanations.
- Added plain diagnostics for unsupported set use in START, WHEN Triggers, and IF conditions.
- Added plain correction for unbound `a Kind` action targets.
- Ignored serialized candidate lists as runtime authority.
- Added strict saved-BSharp IR set-reference validation before START mutations.
- Added bounded human traces with complete structured result lists.
- Added a focused sample, tests, v0.0.17 compatibility fixture, and 1,024-Thing stress lane.

## Excluded work

- No all/plural aliases, `those`, `any`, or all-versus-any conditions.
- No set references in START, WHEN Triggers, or IF conditions.
- No new official words, values, amounts, variables, queues, time, repetition, save/load, ASK, bytecode, VM, engine bridge, or self-hosting work.

## Validation results

```text
114 runs
4,637 assertions
0 failures
0 errors
0 skips
```

```text
Runtime stress: PASS
Kind-family stress: PASS
IF-rule stress: PASS
Multiple-selection stress: PASS
```

```text
1,024 Things
768 direct and inherited guard matches
100 repeated multi-target events per path
76,800 per-target mutations per path
bounded human trace
complete structured results
source/saved-BSharp IR parity
runtime isolation
deterministic replay
```

## Known risks

- Set actions can generate many structured steps; human output is bounded but complete result data is retained.
- Runtime selection must continue to ignore stale serialized candidate lists.
- Singular context must never be overwritten by a plural selection.
- Valid empty sets are nonfatal, while unknown Kinds remain errors.
- Timing is observational only and is not an acceptance gate.

## Rollback point

```text
commit 78fa0c3
tag v0.0.17
```

The installer must reset and clean back to `v0.0.17` if installation or validation fails.

## Current continuation point

Candidate built and internally validated. Derek must install, inspect, and accept or reject it before commit and tag.

## Next planned work

After v0.0.18 acceptance, read the updated roadmap and handoff, then present the complete v0.0.19 proposal before implementation.
