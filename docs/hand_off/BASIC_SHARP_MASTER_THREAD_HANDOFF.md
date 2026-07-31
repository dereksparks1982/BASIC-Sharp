# BASIC# Master Thread Handoff

## Current project state

**Project:** BASIC# Ruby Bootstrap Compiler  
**Language identity:** BASIC# / BSharp  
**Intermediate representation:** BSharp IR / BSIR  
**World-state format:** BSharp Save  
**Inspection format:** BSharp ASK  
**Accepted base:** v0.1.22 BSharp Save Files and Deterministic World Restore  
**Accepted commit:** `d991679`  
**Accepted tag:** `v0.1.22`  
**Current candidate:** v0.1.23 ASK Introspection and Deterministic Answers  
**Project path:** `/home/dereksparks1982/DKLab/Projects/BASIC#`

## v0.1.23 completed work

- Added read-only `--ask` questions and repeated command-order answers.
- Added deterministic `--ask-json` output with `bsharp.ask.json` identity.
- Added Thing, Kind, inherited membership, state, value, relationship, event-match, IF, world, and save inspection.
- Preserved exact-Thing, nearest-Kind, and source-order matching during event inspection without action execution.
- Added ambiguity handling, explicit unsupported-question guidance, 256-question protection, bounded human output, and complete JSON.
- Preserved world state, IF activity, event state, and save readiness during ASK.
- Added source/BSIR/restored-save parity, deterministic output, runtime isolation, sample files, tests, stress, contracts, and validation records.

## Internal validation target

```text
212 runs
5,043 assertions
0 failures
0 errors
0 skips
```

All eight stress lanes pass, including ASK stress with 768 Kind members and 256 questions.

## Required retired-format diagnostic

```text
This file uses the retired DKIR format.
BASIC# v0.1.20 uses BSharp IR.
Recompile the original .bsharp source to create a new BSIR file.
```

## Explicit exclusions in v0.1.23

- No ASK Head or official word.
- No unrestricted natural-language understanding or spelling correction.
- No event execution, prediction, or mutation during inspection.
- No new syntax, arithmetic, bytecode, VM, GUI, engine bridge, self-hosting, or new DK-prefixed name.

## Rollback point

```text
commit d991679
tag v0.1.22
```

## Current continuation point

1. Derek installs the v0.1.23 changed-files-only package.
2. Derek reviews the suite, eight stress lanes, ASK samples, diagnostics, and working-tree scope.
3. Derek accepts or rejects the candidate.
4. If accepted, commit and tag v0.1.23.
5. Read the updated Company Bible and continuation records.
6. Present the complete v0.1.24 Stable Meaning Specification proposal before implementation.

## Cumulative accepted history

### v0.1.22 - 2026-07-30

BSharp Save Files and Deterministic World Restore. Accepted at commit `d991679`, tag `v0.1.22`.

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
