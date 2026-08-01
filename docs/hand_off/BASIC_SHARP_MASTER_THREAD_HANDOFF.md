# BASIC# Master Thread Handoff

## Current candidate

- **Accepted base:** v0.1.32 Meaning Profile 2 and BSharp Bytecode Profile 2
- **Accepted commit:** `3566b02`
- **Accepted tag:** `v0.1.32`
- **Accepted branch:** `main`
- **Rejected builds:** v0.1.33 and v0.1.34; both rolled back automatically and neither was committed or tagged
- **Candidate:** v0.1.35 Direct BSBC Runtime-Transition Validation Repair and Complete Profile 3 Re-Carry
- **Project path:** `/home/dereksparks1982/DKLab/Projects/BASIC#`
- **Project scope:** 107 modified paths, 76 added paths, 0 deleted paths, 183 total project paths
- **Package:** `BASIC_Sharp_Ruby_Bootstrap_Compiler_v0_1_35_DIRECT_BSBC_RUNTIME_TRANSITION_VALIDATION_REPAIR_AND_COMPLETE_PROFILE_3_RE_CARRY_CHANGED_FILES_ONLY.zip`

## Canonical authority

Read `docs/company_bible/BASIC_SHARP_COMPANY_BIBLE.md` from beginning to end before every build.

## v0.1.33 failure

Derek installed v0.1.33 from the exact accepted v0.1.32 base. Base checks, hashes, installation, Ruby syntax, JSON parsing, the complete suite, and thirteen focused lanes passed. The complete suite reported 368 runs and 7,686 assertions with zero failures, errors, or skips. `tools/bytecode_emitter.rb` then failed because `BasicSharp::BytecodeEmitter` stored Profile 3 internally but did not expose the public read-only `profile` method used by the tool. The installer restored the exact v0.1.32 state. v0.1.33 is rejected history, not a baseline.

## v0.1.34 failure

Derek installed v0.1.34 from the exact accepted v0.1.32 base. Git/base checks, all hashes, the exact 174-path installation, Ruby syntax, JSON parsing, the complete suite, and every focused lane through `tools/bytecode_vm_stress.rb` passed. The suite reported 369 runs and 7,692 assertions with zero failures, errors, or skips. `tools/runtime_transition.rb` then failed `Direct BSBC remains BSharp VM` because its validator still searched for a v0.1.32 banner while the candidate correctly reported v0.1.34. The direct `.bsbc` route itself remained the BSharp VM. The installer restored exact v0.1.32. v0.1.34 is rejected history, not a baseline.

## v0.1.35 completed candidate work

- Re-carried the entire owner-approved v0.1.33 visual grammar, comments, game controls, hover, context, Meaning Profile 3, Bytecode Profile 3, Save format 3, ASK, and runtime-parity work from accepted v0.1.32.
- Preserved `PLAYER`, `#Kind`, `@object`, `(action`, `|then`, `//` … `/.`, and canonical `[` … `].` Bodies.
- Preserved the public read-only `BasicSharp::BytecodeEmitter#profile` repair and Profile 1/2/3 regression coverage.
- Preserved the corrected Profile 2 deterministic Save-document fixture chain.
- Bound direct-BSBC and explicit reference-runtime banner validation to `BasicSharp::VERSION` instead of a retired numeric literal.
- Added regression coverage that rejects hard-coded runtime banners and tightened direct `.bsbc` CLI coverage to require the exact active VM identity.
- Preserved Profile 1 and Profile 2 BSBC and disassembly artifacts.
- Preserved both rejected-build failures and rollbacks in handshakes, audits, session logs, validation records, roadmap, and this handoff.
- Repaired streamed one-command installation and retained direct extracted-script execution.

## Validation gate

Native owner validation must report at least:

```text
370 runs
7,698 assertions
0 failures
0 errors
0 skips
0 Ruby warnings or stderr
```

Every established and Profile 3 focused tool must pass, including `tools/bytecode_emitter.rb` and the formerly failing `tools/runtime_transition.rb`. The installer must preserve every Profile 1/2 compatibility artifact, verify the exact manifest scope, and automatically restore v0.1.32 if any post-mutation check fails.

## Explicit exclusions

No syntax or meaning beyond the owner-approved v0.1.33 scope; no collision, physics, rendering, controller remapping, arithmetic, repetition, modules, editor, IDE, engine bridge, self-hosting, licensing, monetization, optimizer, JIT, or native machine code.

## Risks and controls

- The repair is intentionally surgical: two version-bound banner checks plus direct regression coverage.
- The entire rejected feature set is re-carried because v0.1.33 and v0.1.34 rolled back and cannot be used as a base.
- The installer requires the exact accepted commit, tag, branch, clean tree, and base hashes before mutation.
- Any native validation failure restores all replaced v0.1.32 files and removes all added candidate paths.

## Rollback

```text
commit 3566b02
tag v0.1.32
```

## Continuation

Derek installs and validates v0.1.35 before commit or tag. After acceptance, commit and tag v0.1.35, capture the accepted full project snapshot and current v0.1.35 handshake, then discuss the previously requested plain-English movement commands. No next feature begins before those acceptance steps.

## Accepted recent history

- v0.1.24 Stable Meaning Specification and Conformance Profile 1, `28e5b5b`.
- v0.1.25 Canonical Company Bible Consolidation, `dadd813`.
- v0.1.26-v0.1.28 Bytecode Profile 1 architecture, emission, disassembly, loading, and validation.
- v0.1.29-v0.1.30 first BSharp VM, parity, Save, ASK, and hardening.
- v0.1.31 preferred BSharp VM runtime and shadow parity, `e7126c1`.
- v0.1.32 creator-facing text values and Profile 2, `3566b02`.
- v0.1.33 rejected after focused emitter validation; automatic rollback restored v0.1.32.
- v0.1.34 rejected after version-stale runtime-transition validation; automatic rollback restored v0.1.32.
