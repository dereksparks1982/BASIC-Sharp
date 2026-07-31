# BASIC# Master Thread Handoff

## Current candidate

- **Accepted base:** v0.1.30 VM Parity, BSharp Save, BSharp ASK, and Hardening
- **Accepted commit:** `30e1506`
- **Accepted tag:** `v0.1.30`
- **Candidate:** v0.1.31 BSharp VM Preferred Runtime Transition and Shadow Parity Verification
- **Project path:** `/home/dereksparks1982/DKLab/Projects/BASIC#`
- **Package:** `BASIC_Sharp_Ruby_Bootstrap_Compiler_v0_1_31_BSHARP_VM_PREFERRED_RUNTIME_TRANSITION_AND_SHADOW_PARITY_CHANGED_FILES_ONLY.zip`

## Canonical authority

Read end-to-end before every build:

```text
docs/company_bible/BASIC_SHARP_COMPANY_BIBLE.md
```

## v0.1.31 completed candidate work

- Made BSharp VM the preferred Profile 1 runtime for source, saved BSIR, and direct BSBC.
- Added source/BSIR in-memory BSBC emission and complete loader validation with no temporary artifacts.
- Added `--reference-runtime` as explicit access to the preserved reference oracle.
- Added `--verify-runtime-parity` for independent startup, event, world, IF, follow-up, ASK, Save, restore, and replay comparison.
- Added mismatch stopping with bounded fingerprints and no newly mismatched transition state accepted.
- Preserved direct BSBC behavior, Save/ASK formats, bytecode layout, and all committed BSBC bytes.
- Recorded and evaluated Derek's supplied external Claude review.
- Corrected current records to show v0.1.30 accepted at commit `30e1506`, tag `v0.1.30`.

## Validation floor

The accepted v0.1.30 floor may not decrease:

```text
292 runs
7,262 assertions
0 failures
0 errors
0 skips
```

The candidate result is 309 runs, 7,376 assertions, zero failures/errors/skips. All established lanes and the new preferred-runtime transition lane pass.

## Explicit exclusions

No reference-runtime deletion, new BASIC# syntax or meaning, new bytecode profile, binary-layout change, optimization, JIT, native machine code, strings, arithmetic expressions, repetition, functions, collections, editor, IDE, engine bridge, self-hosting, licensing, or monetization.

## Risks and controls

- Preferred source/BSIR execution validates emitted BSBC before world creation.
- Default execution does not instantiate the reference runtime.
- Shadow verification uses independently reconstructed engines and stops on disagreement.
- The reference runtime remains available for diagnosis and conformance.
- Existing IF, follow-up-event, Save, ASK, isolation, and failed-restore controls remain active.
- Shadow mode is intentionally slower and is not the normal creator path.

## Rollback

```text
commit 30e1506
tag v0.1.30
```

## Continuation

Derek installs and validates v0.1.31 before commit or tag. After acceptance, select the smallest creator-facing Profile 2 feature that supports useful programs and eventual self-hosting. The strongest current candidate is general text values, but it requires a separate exact proposal and approval.

## Accepted history

- v0.1.24 Stable Meaning Specification and Conformance Profile 1, commit `28e5b5b`.
- v0.1.25 Canonical Company Bible Consolidation, commit `dadd813`.
- v0.1.26 BSharp Bytecode Architecture and Instruction Contract 1, commit `479db66`.
- v0.1.27 BSharp Bytecode Emitter and Deterministic Disassembly 1, commit `f82b121`.
- v0.1.28 BSharp Bytecode Loader and Complete Structural Validation 1, commit `e352457`.
- v0.1.29 First BSharp Virtual Machine and Profile 1 Execution, commit `c5c1374`.
- v0.1.30 VM Parity, BSharp Save, BSharp ASK, and Hardening, commit `30e1506`.
