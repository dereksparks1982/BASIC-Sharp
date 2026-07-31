# BASIC# v0.1.21 New Thread Handoff

## Required base

```text
v0.1.20
commit c94faec
tag v0.1.20
clean working tree
```

## Candidate

```text
v0.1.21 Follow-Up Events and Deterministic Event Order
```

## Completed

- Added explicit `(cause` follow-up events.
- Added deterministic FIFO event processing.
- Fixed the order as action body, IF settlement, then follow-up events.
- Added nested end-of-line ordering.
- Captured `that Kind` as a concrete Thing before queuing.
- Added fresh matching context for each event.
- Added no-match continuation and fatal-error chain stopping.
- Added staged-event discard on body or IF settlement failure.
- Added 1,024-event protection and bounded trace output.
- Added follow-up event sample, BSharp IR sample, tests, and stress tool.
- Full suite and all six stress lanes pass internally.

## Excluded

No automatic world-change events, plural caused events, time, delays, priorities, concurrency, save/load, ASK, arithmetic, bytecode, VM, editor, game-engine bridge, or self-hosting work.

## Rollback

```text
commit c94faec
tag v0.1.20
```

## Continuation

Owner installs and reviews the candidate. If accepted, commit and tag v0.1.21. Then read the current Company Bible and continuation records before proposing the next version. The roadmap currently points to Save/Load World State.

## Corrected-package requirement

Use only the corrected v0.1.21 ZIP. The first ZIP rejected before mutation because its `README.md` base hash did not match accepted commit `c94faec`. The corrected package was rebuilt from the exact accepted v0.1.20 file state and reran the full clean-base proof.
