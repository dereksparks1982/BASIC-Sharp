# BASIC# Build Handshake v0.1.21

## Project and version

- **Project:** BASIC# Ruby Bootstrap Compiler
- **Build:** v0.1.21 Follow-Up Events and Deterministic Event Order
- **Required base:** accepted v0.1.20 BSharp IR Identity Migration
- **Required commit:** `c94faec`
- **Required tag:** `v0.1.20`
- **Target version:** `v0.1.21`
- **Project path:** `/home/dereksparks1982/DKLab/Projects/BASIC#`

## Exact package

`BASIC_Sharp_Ruby_Bootstrap_Compiler_v0_1_21_FOLLOW_UP_EVENTS_AND_DETERMINISTIC_EVENT_ORDER_CORRECTED_CHANGED_FILES_ONLY.zip`

## Completed changes

- Added the creator-facing official word `(cause`.
- Added explicit follow-up event templates to BSharp IR.
- Finished each current action body before any follow-up event runs.
- Settled reactive IF rules completely before the next event runs.
- Added deterministic first-created, first-run event ordering.
- Appended nested events to the end of the existing event line.
- Captured `that Kind` as a concrete Thing name when the event is created.
- Created a fresh WHEN context for every follow-up event.
- Continued past follow-up events that matched no WHEN rule.
- Stopped later waiting events after a follow-up runtime error.
- Discarded staged events when their action body or IF settlement failed.
- Added a 1,024-follow-up-event circuit breaker and bounded human trace.
- Added complete structured follow-up results and creator-facing cause reporting.
- Added source/saved-BSIR parity, deterministic replay, isolation, ordering, and loop tests.
- Added a dedicated follow-up-event sample and stress lane.
- Preserved all accepted Kind, IF, selection, value, amount, and BSharp IR behavior.

## Excluded work

- No automatic events from damage, change, carry, or unlock.
- No `every Kind` caused events.
- No delayed, timed, scheduled, prioritized, or parallel events.
- No new Heads.
- No new number or IF condition forms.
- No save/load, ASK, arithmetic, bytecode, VM, GUI, editor, game-engine bridge, or self-hosting work.
- No new `DK`-prefixed name.

## Validation

```text
157 runs
4,841 assertions
0 failures
0 errors
0 skips
```

All six stress lanes pass, including the new follow-up-event lane.

## Known risks

- Event chains can magnify creator-authored behavior quickly. The runtime stops after 1,024 follow-up events.
- A follow-up event that matches no rule is deliberately nonfatal and may indicate an intentionally ignored event or a creator mistake visible in the trace.
- A runtime error inside a follow-up event stops the remaining line so later events do not run against an uncertain world.
- `(cause` requires one concrete named Thing or a captured singular `that Kind`; plural event generation remains deliberately excluded.

## Rollback point

```text
commit c94faec
tag v0.1.20
```

The installer must restore that accepted base if installation or validation fails.

## Continuation

Candidate built and internally validated. Derek must install, inspect, and accept or reject it before commit and tag. After acceptance, read the current records and present the next proposal before implementation. The roadmap currently points to Save/Load World State.

## Corrected package record

The first v0.1.21 package was rejected by its own preflight before any project file changed because its installer expected the wrong accepted-base hash for `README.md`. Repeating that installer produced the same safe rejection.

The corrected candidate was rebuilt by restoring the exact accepted v0.1.20 project state from commit `c94faec`, reapplying the approved v0.1.21 changes, regenerating the BSharp IR samples, rebuilding every base-file hash, and rerunning the full clean-base installer proof.

The rejected package is not an accepted baseline and must not be installed or committed.
