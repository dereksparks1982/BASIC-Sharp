# BASIC# Master Thread Handoff

## Current candidate

- **Accepted base:** v0.1.26 BSharp Bytecode Architecture and Instruction Contract 1
- **Accepted commit:** `479db66`
- **Accepted tag:** `v0.1.26`
- **Candidate:** v0.1.27 BSharp Bytecode Emitter and Deterministic Disassembly 1
- **Project path:** `/home/dereksparks1982/DKLab/Projects/BASIC#`
- **Package:** `BASIC_Sharp_Ruby_Bootstrap_Compiler_v0_1_27_BSHARP_BYTECODE_EMITTER_AND_DETERMINISTIC_DISASSEMBLY_1_CHANGED_FILES_ONLY.zip`

## Canonical authority

Read end-to-end before every build:

```text
docs/company_bible/BASIC_SHARP_COMPANY_BIBLE.md
```

## v0.1.27 completed candidate work

- Added `compiler/bytecode_emitter.rb` and deterministic canonical lowering from resolved BSIR.
- Added `compiler/bytecode_disassembler.rb` for non-creator diagnostic text.
- Added CLI `--emit-bytecode` for `.bsharp` and `.bsir.json` inputs.
- Added atomic `.bsbc` plus `.bsbc.txt` output with custom `--out` support.
- Locked mandatory string prefix, semantic string encounter order, ancestor-first Kind order, Thing definition order, START order, WHEN-then-IF block order, zero-based indexes, zero padding, and raw 32-byte fingerprint storage.
- Lowered all current START instructions, actions, selectors, and IF conditions in Bytecode Profile 1.
- Added six sample binaries, six sample disassemblies, and a fixture hash manifest.
- Added source/BSIR byte parity, repeated determinism, line-number independence, invalid-program rejection, atomic-output safety, and implementation-leak tests.
- Advanced active BASIC# version surfaces to v0.1.27 without changing creator-facing language meaning.

## Validation floor

The accepted v0.1.26 floor may not decrease:

```text
234 runs
5,277 assertions
0 failures
0 errors
0 skips
```

The final v0.1.27 candidate must exceed that floor and pass all eight stress lanes, all 13 Meaning Profile cases, Company Bible audit, Bytecode Contract audit, Bytecode Emitter lane, sample fixture hashes, source/BSIR parity, generated BSIR and Save parity, and exact 51-path scope.

## Explicit exclusions

No arbitrary `.bsbc` loader, virtual machine, bytecode execution, Ruby-runtime replacement, optimization, compression, new syntax, Head, Connector, official word, BSIR/Save/ASK schema change, editor, IDE, engine bridge, self-hosting, pricing, licensing, activation, or subscription work.

## Risks and controls

- Binary and disassembly are generated from one canonical model.
- Source and BSIR paths are compared byte-for-byte.
- Meaning fingerprints reuse the accepted BSharp Save algorithm.
- Output writes use temporary files and rollback-safe pair replacement.
- Ruby classes, machine paths, timestamps, and object identities are forbidden from serialized output.
- Actual bytecode parsing and execution remain separate owner-approved builds.

## Rollback

```text
commit 479db66
tag v0.1.26
```

## Continuation

Derek installs and validates v0.1.27 before commit or tag. After acceptance, the next eligible proposal is **BSharp Bytecode Loader and Complete Validation 1**, unless Derek changes direction.

## Accepted history

- v0.1.24 Stable Meaning Specification and Conformance Profile 1, commit `28e5b5b`.
- v0.1.25 Canonical Company Bible Consolidation, commit `dadd813`.
- v0.1.26 BSharp Bytecode Architecture and Instruction Contract 1, commit `479db66`.
