# BASIC# Master Thread Handoff

## Current candidate

- **Accepted base:** v0.1.31 BSharp VM Preferred Runtime Transition and Shadow Parity Verification
- **Accepted commit:** `e7126c1f7e1963a72abb367687bfa0483fb59b64`
- **Accepted tag:** `v0.1.31`
- **Accepted branch:** `main`
- **Candidate:** v0.1.32 Meaning Profile 2: Creator-Facing Text Values and BSharp Bytecode Profile 2
- **Project path:** `/home/dereksparks1982/DKLab/Projects/BASIC#`
- **Package:** `BASIC_Sharp_Ruby_Bootstrap_Compiler_v0_1_32_MEANING_PROFILE_2_CREATOR_FACING_TEXT_VALUES_AND_BSHARP_BYTECODE_PROFILE_2_CHANGED_FILES_ONLY.zip`

## Canonical authority

Read `docs/company_bible/BASIC_SHARP_COMPANY_BIBLE.md` from beginning to end before every build.

## v0.1.32 completed candidate work

- Added creator-facing exact text values with straight double quotes, single-line UTF-8, and preserved case, punctuation, and spaces.
- Carried typed text through AST, resolution, BSIR, deterministic fingerprints, reference runtime, preferred VM, ASK, typed Save/restore, and shadow parity.
- Added Stable Meaning Profile 2 and conformance fixtures while retaining Profile 1 selection for programs that do not use text.
- Added BSharp Bytecode Profile 2 with role-aware strings and `START_TEXT_VALUE`, `CHANGE_TEXT_VALUE`, and `TEXT_VALUE_EQUALS`.
- Added complete Profile 2 emission, loading, validation, disassembly, VM execution, negative cases, deterministic fixtures, and stress coverage.
- Preserved committed Profile 1 BSBC bytes, disassembly, fingerprints, and runtime meaning.

## Validation floor and environment

The accepted v0.1.31 floor is:

```text
309 runs
7,376 assertions
0 failures
0 errors
0 skips
```

Focused Profile 2 tests and deterministic stress lanes pass in the build environment. The available WebAssembly Ruby runtime cannot provide native `Open3`, atomic rename, or the exact installed extension set, so the final full-suite, warning-free count remains an owner-side installer gate on native Ruby. The package must not be accepted or committed unless that gate passes.

## Explicit exclusions

No interpolation, concatenation, escape-sequence language, multiline text, `(speak ...)`, text event matching, arithmetic on text, editor work, IDE, engine bridge, self-hosting, licensing, monetization, optimizer, JIT, native machine code, or unrelated syntax.

## Risks and controls

- Literal contents never pass through identifier lowercasing.
- Value schemas reject text/whole-number conflicts before execution or restore.
- Profile 2 instructions are rejected under Profile 1 identity.
- Role-aware string validation preserves literal text without weakening canonical identifiers.
- Profile 1 artifact hashes and deterministic meaning remain regression gates.
- Ruby/VM verification stops on the first semantic disagreement.
- Save documents are typed and versioned; Profile 1 save validation remains accepted.

## Rollback

```text
commit e7126c1f7e1963a72abb367687bfa0483fb59b64
tag v0.1.31
```

The installer verifies the exact accepted base, applies only the approved paths, runs validation, and restores the pre-install state if a post-mutation gate fails.

## Continuation

Derek installs and validates v0.1.32 before commit or tag. After acceptance, the next explicit discussion is a separate focused proposal for plain-English left/right platformer movement with creator-chosen speed. The compiler/runtime bridge should hide input polling, direction math, frame timing, velocity, collision movement, and engine calls. No movement syntax or behavior is part of v0.1.32, and exact words—including Derek's rough `PLAYER` and `<move>` ideas—remain owner decisions. The editor remains a staged long-term destination and is not part of v0.1.32.

## Accepted recent history

- v0.1.24 Stable Meaning Specification and Conformance Profile 1, `28e5b5b`.
- v0.1.25 Canonical Company Bible Consolidation, `dadd813`.
- v0.1.26-v0.1.28 Bytecode Profile 1 architecture, emission, disassembly, loading, and validation.
- v0.1.29-v0.1.30 first BSharp VM, parity, Save, ASK, and hardening.
- v0.1.31 preferred BSharp VM runtime and shadow parity, `e7126c1`.
