# BASIC# Roadmap

## Current accepted base

```text
v0.1.79: Self-Hosting Milestone 2 Slice 6 - Independent Compiler Driver + BSBC Artifact Round Trip
commit fdb8d17e6ea48e524cbe8713026a58902bd5da20
tag v0.1.79
```

v0.1.79 is the accepted rollback point. It placed `SmallCompilerSubsetDriver` in front of the integrated independent pipeline, produced real persisted `.bsbc` artifacts, reloaded them through the independent loader, executed them through the independent BSharp VM, and completed native validation, accepted snapshot, local Git closeout, and GitHub peeled-tag verification.

## Current candidate

```text
v0.1.80: Self-Hosting Milestone 2 Slice 7 - First BASIC#-Authored Compiler Component
```

v0.1.80 authors the first bounded compiler-domain decision component in BASIC# itself. The canonical source is `compiler/native/first_bsharp_compiler_component.bsharp`. The v0.1.79 independent driver compiles it into a real checked-in `.bsbc` artifact, and the independent loader/VM execute that artifact without requiring the source copy used to create it.

The primary proof lane is:

```text
BASIC# compiler-component source
-> SmallCompilerSubsetDriver
-> SmallCompilerSubsetPipeline
-> real first_bsharp_compiler_component.bsbc
-> source copy removed
-> SmallCompilerSubsetBSBCLoader
-> SmallCompilerSubsetBSBCVirtualMachine
-> compiler decision
```

The first native decision kernel classifies all nine accepted block heads: `KINDS`, `DEFINE`, `START`, `WHEN`, `IF`, `OTHERWISE`, `CONTROLS`, `HOVER`, and `CONTEXT`. Acceptance requires deterministic decisions, byte-identical repeated compilation, source-free artifact execution, and exact production BytecodeEmitter, production BSharp VM, and Ruby Runtime referee parity.

Reference: `spec/self_hosting/BASIC_SHARP_FIRST_NATIVE_COMPILER_COMPONENT_v1.json`.
Reference: `docs/self_hosting/BASIC_SHARP_FIRST_NATIVE_COMPILER_COMPONENT_v0_1_80.md`.
Reference: `compiler/native/first_bsharp_compiler_component.bsharp`.
Reference: `compiler/native/first_bsharp_compiler_component.bsbc`.
Reference: `spec/self_hosting/BASIC_SHARP_SELF_HOSTING_SUBSET_v1.json`.

Accepted prior-lane contracts remain active, including the independent encoder, loader, BSharp VM, integrated pipeline, compiler driver, and BSBC artifact round-trip gates.

Ruby remains the bootstrap compiler and referee authority. v0.1.80 is not full self-hosting and does not retire Ruby. Profiles 1 through 7 and creator-facing syntax remain unchanged.

The Company Bible header drift found after v0.1.79 is repaired in this build, and the canonical header version is now machine-checked against `BasicSharp::VERSION`.

## Canonical Company Bible

```text
docs/company_bible/BASIC_SHARP_COMPANY_BIBLE.md
```

This is the single canonical Company Bible reference for current BASIC# conduct, release, validation, rollback, packaging, GitHub closeout, and Elderedd migration rules. Its header version must match the active BASIC# version.

## Release closeout order

Every BASIC# build must follow the proven release path:

1. Apply the changed-files ZIP with the exact terminal command supplied with the download.
2. Run installer validation including the complete normal test suite, complete no-locale suite, all required stress/tool gates, and full Trial by Fire native counts required by the build.
3. Installer output preserves `PHASE START` / `PHASE PASS`, visible Minitest dot progress, run/assertion counts, and one unmistakable `FINAL PASS`.
4. Create the accepted snapshot after final PASS and before local Git closeout.
5. Commit and tag locally only after acceptance proof.
6. Complete GitHub remote closeout only after local acceptance, using the proven no-password project authentication path.
7. Start the next build only after the current build is closed.

## Emergency DKLab Retirement and Elderedd Migration

Priority: active. Status: continuing through v0.1.80.

- Elderedd Softworks LLC is the parent company identity.
- Elderedd Laboratory is the active lab identity.
- ELDL is internal shorthand only.
- BCS means BSharp Creator Services and remains future service-layer naming only.
- DKLab is retired as active BASIC# identity.
- DKLab may remain as compatibility, rollback, migration, and archival history.
- Canonical future path: `~/Elderedd/Projects/BASIC#`.
- Legacy compatibility path: `~/DKLab/Projects/BASIC#`.
- Do not remove the DKLab compatibility bridge until a later accepted build proves no active BASIC# workflow depends on it.

## Self-hosting runway

Current truthful claim:

```text
BSharp Compiler Subset 0 has an accepted independent compiler driver and real BSBC artifact round trip from v0.1.79.
v0.1.80 adds the first bounded compiler-domain component authored in BASIC# and executed from BASIC# bytecode under Ruby referee control.
Ruby remains the bootstrap compiler and production referee.
BASIC# is not fully self-hosted.
```

The v0.1.72 proposal is now implemented through semantic resolver independence, independent BSBC encoding, independent loading, independent BSharp VM execution, integrated pipeline independence, real artifact round trip, and the first BASIC#-authored compiler decision kernel.

## Game-making runway

v0.1.73 established four direct creator actions: open, close, lock, and take. v0.1.80 preserves those game-making semantics unchanged while the compiler implementation underneath them becomes more independent.

## Next direction after v0.1.80

1. Expand BASIC#-authored compiler logic only where the current language can express real compiler work without inventing programmer-facing syntax.
2. Keep Ruby as referee until BASIC#-authored components reproduce locked outputs strongly enough to earn further replacement.
3. A meaningful creator/game-making capability expansion if Derek chooses that lane.
4. Repair any proven validation/release defect before new functionality if one is found.

No new governance/audit system is planned unless a demonstrated failure requires it.

## Public proof-application ladder

These are future proof programs, not permission to interrupt the active compiler/runtime lane:

1. Calculator
2. Text Adventure / choose-your-own-adventure
3. Pong
4. Breakout
5. Solitaire
6. Larger 2D Game
7. Media Player

Solitaire is a future public BASIC# showcase. The game/source is intended for free noncommercial study and use, while Derek's Demon Killer custom card/deck artwork remains separately protected and excluded from that free-use grant.

## Release-hardening runway

The following gates remain active:

```text
tools/deterministic_fixture_hash_sweep.rb
tools/release_package_preflight.rb
tools/release_forensic_overlay.rb
tools/trial_by_fire_inventory.rb
tools/trial_by_fire_gauntlet.rb
```

They prevent stale fixture hashes, sealed artifact byte drift, manifest/payload mismatch, and incomplete validation from being accepted.

## Future BASIC# Graphics Format runway

Recorded for later only:

```text
BSG = BASIC# Graphics system
BGF = BASIC# Graphics Format
Extension = .bgf
```

Compatibility and functional language progress remain ahead of BGF implementation.

## Canonical self-hosting specification runway

```text
spec/self_hosting/BASIC_SHARP_SELF_HOSTING_SUBSET_v1.json
spec/self_hosting/BASIC_SHARP_TOKENIZER_READER_CONTRACT_v1.json
spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_PARSER_v1.json
spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_IR_EMITTER_v1.json
spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_SEMANTIC_RESOLVER_v1.json
spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_IR_PARITY_HARNESS_v1.json
spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_ERROR_CONTRACT_v1.json
spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_SCENE_BLOCK_EXPANSION_v1.json
spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_SYMBOL_TABLE_CONTRACT_v1.json
spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_BSBC_EMITTER_v1.json
spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_BSBC_EMITTER_INDEPENDENCE_v1.json
spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_BSBC_LOADER_INDEPENDENCE_v1.json
spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_BSBC_VM_INDEPENDENCE_v1.json
spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_PIPELINE_INDEPENDENCE_v1.json
spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_DRIVER_INDEPENDENCE_v1.json
spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_ARTIFACT_ROUND_TRIP_v1.json
spec/self_hosting/BASIC_SHARP_FIRST_NATIVE_COMPILER_COMPONENT_v1.json
spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_BSBC_PARITY_HARNESS_v1.json
spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_BSBC_EXECUTION_PARITY_v1.json
spec/self_hosting/BASIC_SHARP_SELF_HOSTING_FIXTURE_CORPUS_v1.json
spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_RUNTIME_SMOKE_v1.json
spec/self_hosting/BASIC_SHARP_BOOTSTRAP_BOUNDARY_AUDIT_v1.json
spec/self_hosting/BASIC_SHARP_README_CURRENT_RELEASE_TRUTH_v1.json
spec/self_hosting/BASIC_SHARP_SELF_HOSTING_MILESTONE_1_v1.json
docs/self_hosting/BASIC_SHARP_SELF_HOSTING_MILESTONE_2_PROPOSAL_v0_1_72.md
```
