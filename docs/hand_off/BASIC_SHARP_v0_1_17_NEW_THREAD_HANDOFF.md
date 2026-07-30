# BASIC# v0.1.17 New Thread Handoff

## Required base

```text
v0.1.16
commit fa48287
tag v0.1.16
working tree clean
```

## Candidate

```text
v0.1.17 Reactive IF Rules and Loop Protection
```

## Completed

- Reactive false-to-true IF wake-up.
- Re-arm after false.
- START and post-WHEN settling.
- Complete WHEN action list before IF checking.
- Source-order IF cascades.
- Repeating-state and firing-limit loop protection.
- Plain IF trace.
- Source/saved-BSharp IR parity.
- v0.1.13, v0.1.15, and v0.1.16 fixture compatibility.

## Validation

```text
95 runs
4,546 assertions
0 failures
0 errors
0 skips
all three stress lanes PASS
```

## Excluded

No new IF grammar, OTHERWISE, AND, OR, values, event queue, time, ASK, VM, engine bridge, or self-hosting work.

## Continuation

Derek installs and reviews the candidate. If accepted, commit and tag v0.1.17. Then read the current roadmap and present the complete next-build proposal before implementation.
