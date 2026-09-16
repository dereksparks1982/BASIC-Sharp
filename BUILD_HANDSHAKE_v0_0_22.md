# BASIC# Build Handshake v0.0.22

## Project and version

- **Project:** BASIC# Ruby Bootstrap Compiler
- **Build:** v0.0.22 BSharp Save Files and Deterministic World Restore
- **Required base:** accepted v0.0.21 Follow-Up Events and Deterministic Event Order
- **Required commit:** `d67373b`
- **Required tag:** `v0.0.21`
- **Target version:** `v0.0.22`
- **Project path:** `/home/dereksparks1982/DKLab/Projects/BASIC#`

## Exact package

`BASIC_Sharp_Ruby_Bootstrap_Compiler_v0_0_22_BSHARP_SAVE_FILES_AND_DETERMINISTIC_WORLD_RESTORE_CHANGED_FILES_ONLY.zip`

## Completed changes

- Added separate BSharp Save identity, parser-independent format, and `.bsave.json` files.
- Added source/BSIR program fingerprints and deterministic save output.
- Added settled-world save, direct restore, strict candidate validation, and atomic writes.
- Preserved Thing order, identity, states, relationships, values, damage, and IF-active state.
- Prevented START, startup IF, and startup event replay on restore.
- Refused save after unmatched, failed, or circuit-broken event execution.
- Added CLI commands, sample files, tests, stress, contracts, validation, and handoffs.

## Excluded work

No new language words or syntax, pending-event serialization, automatic saves, slots, migration, dynamic Things, event history, ASK, arithmetic, bytecode, VM, GUI, engine bridge, self-hosting, or new DK-prefixed names.

## Validation

```text
182 runs
4,945 assertions
0 failures
0 errors
0 skips
```

All seven stress lanes pass.

## Risks and controls

- Wrong-program restore is blocked by normalized program fingerprints.
- Corrupt or contradictory state is rejected before runtime mutation.
- Failed writes preserve the previous save through same-directory temporary-file replacement.
- Pending work is excluded by the settled-only save boundary.
- Startup behavior is not replayed because restore bypasses START entirely.

## Rollback point

```text
commit d67373b
tag v0.0.21
```

The installer must restore that accepted base on any post-mutation failure.

## Continuation

Derek installs and reviews the candidate before commit/tag. After acceptance, read current records and present the v0.0.23 proposal. The roadmap currently points to ASK-style introspection.
