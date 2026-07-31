# BASIC# Master Thread Handoff

## Current project state

**Project:** BASIC# Ruby Bootstrap Compiler  
**Language identity:** BASIC# / BSharp  
**Intermediate representation:** BSharp IR / BSIR  
**World-state format:** BSharp Save  
**Accepted base:** v0.1.21 Follow-Up Events and Deterministic Event Order  
**Accepted commit:** `d67373b`  
**Accepted tag:** `v0.1.21`  
**Current candidate:** v0.1.22 BSharp Save Files and Deterministic World Restore  
**Project path:** `/home/dereksparks1982/DKLab/Projects/BASIC#`

## v0.1.22 completed work

- Added the separate BSharp Save format marker `bsharp.save.json` and extension `.bsave.json`.
- Added `--save-world` and `--load-world` toolchain commands without adding language words.
- Added normalized SHA-256 program fingerprints shared by source and equivalent saved BSIR.
- Excluded file paths, compiler labels, diagnostics, comments, formatting, indentation, and line numbers from fingerprints.
- Saved only fully settled worlds.
- Preserved Thing definition order, names, Kinds, built-in identity, states, relationships, values, damage, and IF-active state.
- Restored worlds directly without replaying START, startup IF rules, or startup follow-up events.
- Validated complete save documents before changing runtime state.
- Rejected wrong formats, unsupported versions, program mismatches, Thing identity changes, invalid numbers, missing relationship targets, contradictory states, and inconsistent IF records.
- Added deterministic byte-identical save output with no timestamps or random identifiers.
- Added temporary-file write and atomic replacement behavior so failed writes preserve the previous save.
- Refused saves after unmatched events, runtime errors, or unfinished event chains.
- Added a direct-save-file explanation that points the creator to `--load-world`.
- Added a world-save sample, saved BSIR, example save, test suite, stress lane, contracts, handoffs, and validation records.
- Preserved all accepted BSharp IR, Kind, IF, set, value, amount, and follow-up-event behavior.

## Internal validation target

```text
182 runs
4,945 assertions
0 failures
0 errors
0 skips
```

```text
Runtime stress: PASS
Kind-family stress: PASS
IF-rule stress: PASS
Multiple-selection stress: PASS
Value-and-amount stress: PASS
Follow-up-event stress: PASS
World-save stress: PASS
```

## World-save contract summary

```text
matching .bsharp source or .bsir.json rules
+
matching settled .bsave.json world
-> direct deterministic restore
-> no START replay
-> accept the next external event normally
```

A save is not BSharp IR and cannot be run as program rules.

## Required mismatch diagnostic

```text
This BSharp Save belongs to a different BASIC# program.
Load it with the same .bsharp source or .bsir.json file that created it.
```

## Required direct-save diagnostic

```text
A BSharp Save contains world state, not program rules.
Start BASIC# with the matching .bsharp or .bsir.json file and use --load-world.
```

## Required retired-format diagnostic

```text
This file uses the retired DKIR format.
BASIC# v0.1.20 uses BSharp IR.
Recompile the original .bsharp source to create a new BSIR file.
```

DKIR remains retired with no compatibility layer or silent conversion.

## Explicit exclusions in v0.1.22

- No `(save` or `(load` official words.
- No automatic saves, save slots, file picker, compression, encryption, or cloud saves.
- No pending follow-up-event serialization or mid-chain saving.
- No save migration between different or changed programs.
- No dynamic Thing creation or deletion.
- No event-history or replay-log storage.
- No new language syntax, Heads, values, IF forms, arithmetic, ASK, bytecode, VM, GUI, engine bridge, or self-hosting work.
- No new `DK`-prefixed name.

## Rollback point

```text
commit d67373b
tag v0.1.21
```

## Current continuation point

1. Derek installs the v0.1.22 changed-files-only package.
2. Derek reviews the full suite, seven stress lanes, sample save/restore, and working-tree scope.
3. Derek accepts or rejects the candidate.
4. If accepted, commit and tag v0.1.22.
5. Read the updated Company Bible and continuation records.
6. Present the complete v0.1.23 proposal before implementation.
7. The roadmap currently points to ASK-style introspection.

## Cumulative accepted history

### v0.1.21 - 2026-07-30

Follow-Up Events and Deterministic Event Order. Accepted at commit `d67373b`, tag `v0.1.21`.

### v0.1.20 - 2026-07-30

BSharp IR Identity Migration. Accepted at commit `c94faec`, tag `v0.1.20`.

### v0.1.19 - 2026-07-30

Whole-Number Values and Damage Amounts. Accepted at commit `a479702`, tag `v0.1.19`.

### v0.1.18 - 2026-07-30

Multiple Selected Things and Deterministic Set Actions. Accepted at commit `05eaf68`, tag `v0.1.18`.

### v0.1.17 - 2026-07-30

Reactive IF Rules and Loop Protection. Accepted at commit `78fa0c3`, tag `v0.1.17`.

### v0.1.16 - 2026-07-30

Kind-Family Stress and Hardening. Accepted at commit `fa48287`, tag `v0.1.16`.

### v0.1.15 - 2026-07-30

Inherited Kind Matching. Accepted at commit `a672c49`, tag `v0.1.15`.

### v0.1.14 - 2026-07-30

Technical Identity Migration and Company Bible Integration. Accepted at commit `49f00f1`, tag `v0.1.14`.

## v0.1.21 corrected-package history

The first v0.1.21 package was rejected safely before mutation because it expected an incorrect accepted-base hash for `README.md`. The corrected package was rebuilt from the exact accepted v0.1.20 file state and became the accepted v0.1.21 baseline. v0.1.22 must verify the exact accepted v0.1.21 base at commit `d67373b`.
