# BASIC# Master Thread Handoff

## Current candidate

- **Accepted base:** v0.1.35 Direct BSBC Runtime-Transition Validation Repair and Complete Profile 3 Re-Carry
- **Accepted commit:** `8c5f096`
- **Accepted tag:** `v0.1.35`
- **Accepted branch:** `main`
- **Accepted native validation:** 370 runs, 7,698 assertions, zero failures, errors, or skips; all focused and stress lanes passed
- **Candidate:** v0.1.36 Plain-English Platform Movement and BSharp Profile 4
- **Project path:** `/home/dereksparks1982/DKLab/Projects/BASIC#`
- **Project scope:** 43 modified paths, 48 added paths, 0 deleted paths, 91 total project paths
- **Package:** `BASIC_Sharp_Ruby_Bootstrap_Compiler_v0_1_36_PLAIN_ENGLISH_PLATFORM_MOVEMENT_AND_BSHARP_PROFILE_4_CHANGED_FILES_ONLY.zip`

## Canonical authority

Read `docs/company_bible/BASIC_SHARP_COMPANY_BIBLE.md` from beginning to end before every build.

## v0.1.35 acceptance

Derek installed v0.1.35 from the exact accepted v0.1.32 base. The installer reported 370 runs and 7,698 assertions with zero failures, errors, or skips. Every established and Profile 3 focused/stress lane passed. Derek committed the 183-path candidate as `8c5f096`, tagged `v0.1.35`, confirmed a clean tree, and created `BASIC_SHARP_v0_1_35_ACCEPTED_COMMIT_8c5f096.zip`. That snapshot has SHA-256 `5e8745ae17c2cd40b2b52610ac181d921b40125074ad207b01140c45cfed8df5` and is the required v0.1.36 base.

## v0.1.36 completed candidate work

- Added `KEY moves PLAYER left at N speed`, `KEY moves PLAYER right at N speed`, and `KEY makes PLAYER jump at N speed` inside `CONTROLS for PLAYER`.
- Requires positive whole-number speeds, one left/right/jump job, three distinct keys, and separation from the accepted top-down movement model.
- Added held-key polling, release, opposing-input cancellation, derived/capped frame timing, horizontal and vertical velocity, built-in gravity, one grounded jump per new keypress, no airborne re-jump/buffer, landing reset, ceiling response, and wall response.
- Added the engine-neutral `move_with_collisions` command and documented its complete host boundary.
- Added Stable Meaning Profile 4, BSharp Bytecode Profile 4, profile format version 4, `sha256-bsir-meaning-v4`, BSharp Save format 4, ASK parity, source/BSIR/BSBC parity, and reference/BSharp VM declaration parity.
- Added a complete sample and generated BSIR, BSBC, disassembly, Save, input, expected-command, meaning, bytecode, and runtime fixtures.
- Added focused tests plus a 10,000-frame stress lane.
- Refreshed the Profile 2 deterministic Save-document fixture hash because its recorded creator version advances with every compiler build.
- Preserved accepted top-down Profile 3 controls and byte-identical committed Profile 1 through Profile 3 BSBC and disassembly artifacts.
- Updated the canonical Company Bible, README, roadmap, contracts, validation, changelog, patch notes, session log, changed-files ledger, manifest, handshake, and this cumulative handoff.

## Validation gate

Native owner validation must report at least:

```text
382 runs
7,750 assertions
0 failures
0 errors
0 skips
0 Ruby warnings or stderr
```

All established tools remain mandatory. New mandatory lanes are `tools/meaning_profile_4.rb`, `tools/bytecode_profile_4.rb`, and `tools/platform_movement_stress.rb`. The installer must verify exact scope and hashes, preserve all committed Profile 1 through Profile 3 BSBC/disassembly bytes, and automatically restore v0.1.35 if any post-mutation gate fails.

## Explicit exclusions

No Godot or Unity bridge, rendering, animation, slopes, ladders, swimming, wall jumps, double jumps, variable jump height, acceleration, coyote time, controller remapping, camera behavior, editor, IDE, self-hosting, licensing, monetization, optimizer, JIT, or native machine code.

## Risks and controls

- Profile 4 changes movement semantics, so older runtimes reject its new profile format instead of silently dropping declarations.
- Collision truth remains host-provided; the engine-neutral contract names exact frame inputs and output command fields.
- The first frame uses zero elapsed time and long stalls cap at 0.25 seconds to avoid a hidden large physics step.
- Profile 1 through Profile 3 compatibility is protected by committed-artifact hash tests.
- The installer requires clean `main`, exact commit `8c5f096`, tag `v0.1.35`, all base hashes, and exact added/modified scope before mutation.

## Rollback

```text
commit 8c5f096
tag v0.1.35
```

Any post-mutation failure restores all replaced v0.1.35 files and removes every v0.1.36 added path.

## Continuation

Derek installs v0.1.36 and runs native validation. When it passes, provide the Git commit/tag commands immediately, capture the accepted full v0.1.36 snapshot, and then propose the next focused creator-language build without making Derek ask what comes next.

## Accepted recent history

- v0.1.24 Stable Meaning Specification and Conformance Profile 1, `28e5b5b`.
- v0.1.25 Canonical Company Bible Consolidation, `dadd813`.
- v0.1.26-v0.1.28 Bytecode Profile 1 architecture, emission, disassembly, loading, and validation.
- v0.1.29-v0.1.30 first BSharp VM, parity, Save, ASK, and hardening.
- v0.1.31 preferred BSharp VM runtime and shadow parity, `e7126c1`.
- v0.1.32 creator-facing text values and Profile 2, `3566b02`.
- v0.1.33 rejected after focused emitter validation; automatic rollback restored v0.1.32.
- v0.1.34 rejected after stale runtime-banner validation; automatic rollback restored v0.1.32.
- v0.1.35 complete Profile 3 re-carry and runtime-transition repair, accepted as `8c5f096`.
