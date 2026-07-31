# BASIC# Master Thread Handoff

## Current candidate

- **Accepted base:** v0.1.25 Canonical Company Bible Consolidation
- **Accepted commit:** `dadd813`
- **Accepted tag:** `v0.1.25`
- **Candidate:** v0.1.26 BSharp Bytecode Architecture and Instruction Contract 1
- **Project path:** `/home/dereksparks1982/DKLab/Projects/BASIC#`
- **Package:** `BASIC_Sharp_Ruby_Bootstrap_Compiler_v0_1_26_BSHARP_BYTECODE_ARCHITECTURE_AND_INSTRUCTION_CONTRACT_1_CHANGED_FILES_ONLY.zip`

## Canonical authority

Read end-to-end before every build:

```text
docs/company_bible/BASIC_SHARP_COMPANY_BIBLE.md
```

## v0.1.26 completed candidate work

- Established BSharp Bytecode and BSBC as protected execution-artifact identities.
- Defined `.bsbc`, `BSBC` magic bytes, `bsharp.bytecode.bin`, and `bsharp.bytecode.v1`.
- Defined the exact 32-byte header, 16-byte section directory, four-byte alignment, and eight required sections.
- Defined nine Profile 1 instructions, five selector identities, and four IF condition operators with fixed operand contracts.
- Defined deterministic string, Kind, Thing, event, IF, and code-block ordering.
- Mapped all 13 Meaning Profile 1 cases to representable bytecode machinery.
- Defined diagnostic disassembly and complete malformed-artifact rejection before execution.
- Added `compiler/bytecode_contract.rb`, `tools/bytecode_contract.rb`, and `tests/test_bytecode_contract.rb`.
- Advanced active BASIC# version surfaces to v0.1.26 without changing creator-facing language meaning.

## Candidate validation floor

The accepted v0.1.25 floor must not decrease:

```text
234 runs
5,277 assertions
0 failures
0 errors
0 skips
```

The final candidate must also pass all eight stress lanes, all 13 Meaning Profile cases, the Company Bible audit, and the BSharp Bytecode Contract audit.

## Explicit exclusions

No bytecode emitter, generated `.bsbc` program, loader, VM, bytecode execution, Ruby-runtime replacement, new syntax, Head, Connector, official word, BSIR/save/ASK schema change, editor, IDE, engine bridge, self-hosting, pricing, licensing, activation, or subscription work.

## Risks and controls

- The contract is versioned narrowly as `bsharp.bytecode.v1`; unused identities remain reserved.
- The contract maps stable Profile 1 meaning rather than Ruby classes or private runtime structures.
- BSIR remains the readable resolved representation; BSBC is the future compact execution artifact.
- Emission and execution remain separate owner-approved builds.
- Malformed artifacts must be rejected completely before any execution.

## Rollback

```text
commit dadd813
tag v0.1.25
```

## Continuation

Derek installs and validates v0.1.26 before commit or tag. After acceptance, the next eligible proposal is BSharp Bytecode Emitter and Deterministic Disassembly, unless Derek changes direction.

## Accepted history

- v0.1.25 Canonical Company Bible Consolidation: commit `dadd813`, tag `v0.1.25`.
- v0.1.24 Stable Meaning Specification and Conformance Profile 1: commit `28e5b5b`, tag `v0.1.24`.
- v0.1.23 ASK Introspection and Deterministic Answers: commit `aa69291`, tag `v0.1.23`.
- v0.1.22 BSharp Save Files and Deterministic World Restore: commit `d991679`, tag `v0.1.22`.
- v0.1.21 Follow-Up Events and Deterministic Event Order: commit `d67373b`, tag `v0.1.21`.
- v0.1.20 BSharp IR Identity Migration: commit `c94faec`, tag `v0.1.20`.
- v0.1.19 Whole-Number Values and Damage Amounts: commit `a479702`, tag `v0.1.19`.
- v0.1.18 Multiple Selected Things and Deterministic Set Actions: commit `05eaf68`, tag `v0.1.18`.
- v0.1.17 Reactive IF Rules and Loop Protection: commit `78fa0c3`, tag `v0.1.17`.
- v0.1.16 Kind-Family Stress and Hardening: commit `fa48287`, tag `v0.1.16`.
- v0.1.15 Inherited Kind Matching: commit `a672c49`, tag `v0.1.15`.
- v0.1.14 Technical Identity Migration and Company Bible Integration: commit `49f00f1`, tag `v0.1.14`.
