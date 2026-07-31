# BASIC# Master Thread Handoff

## Current candidate

- **Accepted base:** v0.1.29 First BSharp Virtual Machine and Profile 1 Execution
- **Accepted commit:** `c5c1374`
- **Accepted tag:** `v0.1.29`
- **Candidate:** v0.1.30 VM Parity, BSharp Save, BSharp ASK, and Hardening
- **Project path:** `/home/dereksparks1982/DKLab/Projects/BASIC#`
- **Package:** `BASIC_Sharp_Ruby_Bootstrap_Compiler_v0_1_30_VM_PARITY_BSHARP_SAVE_ASK_AND_HARDENING_CHANGED_FILES_ONLY.zip`

## Canonical authority

Read end-to-end before every build:

```text
docs/company_bible/BASIC_SHARP_COMPANY_BIBLE.md
```

## v0.1.30 completed candidate work

- Added deterministic BSharp Save writing from BSharp VM worlds.
- Added validated BSharp Save restoration into the VM without START or startup-event replay.
- Preserved IF active state and save readiness across restoration.
- Added read-only BSharp ASK support over VM Things, Kinds, events, IF rules, world summaries, and save summaries.
- Added `.bsbc` CLI combinations for run, load-world, ASK, ASK JSON, and save-world.
- Added source / saved BSIR / validated BSBC three-way parity tests.
- Added repeated save/restore/replay, 64-world isolation, deterministic save bytes, and failed-restore recovery tests.
- Added the bounded BSharp VM stress lane with event soak, restore cycles, ASK saturation, isolation, loop guards, and timing reports.
- Preserved all committed `.bsbc` and `.bsbc.txt` artifacts byte-for-byte.
- Kept direct VM execution independent of `BasicSharp::Runtime`.

## Validation floor

The accepted v0.1.29 floor may not decrease:

```text
282 runs
7,150 assertions
0 failures
0 errors
0 skips
```

The candidate must exceed that floor and pass all established stress lanes, all 13 Meaning Profile cases, Company Bible audit, Bytecode Contract, Emitter, Loader, VM lane, new VM hardening lane, artifact parity, exact scope, and installer rollback proof.

## Explicit exclusions

No reference-runtime removal, preferred-runtime transition, optimization, JIT, native machine code, new bytecode profile, binary-layout change, sample BSBC rewrite, new BASIC# syntax or meaning, strings, arithmetic expressions, repetition, functions, collections, editor, IDE, engine bridge, self-hosting, licensing, or monetization.

## Risks and controls

- Save restoration validates the program fingerprint and complete world before mutation.
- A failed restore leaves the existing VM world unchanged.
- ASK uses the VM's read-only inspection boundary and preserves save readiness.
- Each VM owns independent mutable state while the loaded program remains frozen.
- Existing IF and 1,024-follow-up guards remain active under stress.
- The source/BSIR reference runtime remains available until an owner-approved transition.

## Rollback

```text
commit c5c1374
tag v0.1.29
```

## Continuation

Derek installs and validates v0.1.30 before commit or tag. After acceptance, the next eligible proposal is a preferred-runtime decision followed by the smallest Profile 2 capability needed for useful programs and eventual self-hosting.

## Accepted history

- v0.1.24 Stable Meaning Specification and Conformance Profile 1, commit `28e5b5b`.
- v0.1.25 Canonical Company Bible Consolidation, commit `dadd813`.
- v0.1.26 BSharp Bytecode Architecture and Instruction Contract 1, commit `479db66`.
- v0.1.27 BSharp Bytecode Emitter and Deterministic Disassembly 1, commit `f82b121`.
- v0.1.28 BSharp Bytecode Loader and Complete Structural Validation 1, commit `e352457`.
- v0.1.29 First BSharp Virtual Machine and Profile 1 Execution, commit `c5c1374`.
