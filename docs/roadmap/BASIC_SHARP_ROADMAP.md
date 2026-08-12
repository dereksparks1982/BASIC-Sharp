# BASIC# Roadmap

## Current accepted base

```text
v0.1.78: Self-Hosting Milestone 2 Slice 5 - Integrated Independent Compiler Pipeline
commit fac658396e719188b1a980d4d23e34ff81e7e86a
tag v0.1.78
```

v0.1.78 is the accepted rollback point. It connected the bounded Subset 0 reader, parser, semantic resolver, BSharp IR, independent BSBC encoder, independent BSBC loader, and independent BSharp VM behind one `SmallCompilerSubsetPipeline` source-to-world path and completed native validation, snapshot, local Git closeout, and GitHub peeled-tag verification.

## Current candidate

```text
v0.1.79: Self-Hosting Milestone 2 Slice 6 - Independent Compiler Driver + BSBC Artifact Round Trip
```

v0.1.79 places `SmallCompilerSubsetDriver` in front of the accepted integrated independent pipeline. The bounded primary path accepts BASIC# source text or a `.bsharp` source file, emits a real `.bsbc` artifact through the independent encoder, reloads it through `SmallCompilerSubsetBSBCLoader`, and executes it through `SmallCompilerSubsetBSBCVirtualMachine`.

The primary proof lane is:

```text
BASIC# source file
-> SmallCompilerSubsetDriver
-> SmallCompilerSubsetPipeline
-> SmallCompilerSubsetBSBCEncoder
-> real .bsbc artifact
-> SmallCompilerSubsetBSBCLoader
-> SmallCompilerSubsetBSBCVirtualMachine
-> world/result
```

Acceptance requires the persisted artifact to match the independent in-memory bytes exactly, survive source removal after successful compilation, reload and execute independently, and reproduce exact event-result, final-world, BSharp Save, disassembly, and deterministic hash parity. Production `Lexer`, `Parser`, `SemanticResolver`, `BytecodeEmitter`, `BytecodeLoader`, `BytecodeVirtualMachine`, and `Runtime` remain separate referees only.

Reference: `spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_DRIVER_INDEPENDENCE_v1.json`.
Reference: `spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_ARTIFACT_ROUND_TRIP_v1.json`.
Reference: `docs/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_DRIVER_INDEPENDENCE_v0_1_79.md`.
Reference: `compiler/small_compiler_subset_driver.rb`.
Reference: `spec/self_hosting/BASIC_SHARP_SELF_HOSTING_SUBSET_v1.json`.

Accepted prior-lane contracts remain active:

- `spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_BSBC_EMITTER_INDEPENDENCE_v1.json`
- `spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_BSBC_LOADER_INDEPENDENCE_v1.json`
- `spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_BSBC_VM_INDEPENDENCE_v1.json`
- `spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_PIPELINE_INDEPENDENCE_v1.json`

Ruby remains the bootstrap compiler and referee authority. v0.1.79 is not full self-hosting, does not retire Ruby, does not add Profile 8, does not add creator-facing syntax, and does not change the accepted BASIC# statement/action ordering rules or BSBC binary layout.

## Canonical Company Bible

```text
docs/company_bible/BASIC_SHARP_COMPANY_BIBLE.md
```

This is the single canonical Company Bible reference for current BASIC# conduct, release, validation, rollback, packaging, GitHub closeout, and Elderedd migration rules.

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

Priority: active. Status: continuing through v0.1.79.

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
BSharp Compiler Subset 0 has an accepted Self-Hosting Milestone 2 Slice 5 integrated independent pipeline under Ruby referee control, with Slice 6 independent compiler-driver and BSBC artifact-round-trip work as the current v0.1.79 candidate.
The bounded subset path owns reader, parser, semantic resolver, BSBC encoding, BSBC loading, BSharp VM execution, and integrated source-to-world orchestration.
Ruby remains the bootstrap compiler and production referee.
BASIC# is not fully self-hosted.
```

The v0.1.72 proposal is now further implemented by v0.1.74 semantic resolver independence, v0.1.75 BSBC emitter independence, v0.1.76 BSBC loader independence, v0.1.77 BSharp VM execution independence, and accepted v0.1.78 integrated pipeline independence. v0.1.79 advances the next bounded step by proving a real persisted compiler artifact can be created, reloaded, and executed independently while exact parity remains mandatory.

## Game-making runway

v0.1.73 established four direct creator actions: open, close, lock, and take. v0.1.79 carries them with text, numeric, inheritance, IF/OTHERWISE, multiple-selection, and follow-up-event meaning through the independent pipeline and persisted BSBC artifact round-trip proof so game-making meaning remains connected to compiler-independence progress.

## Next direction after v0.1.79

1. Continue Self-Hosting Milestone 2 with the next bounded production-compiler dependency removal under Ruby referee parity.
2. A meaningful creator/game-making capability expansion if Derek chooses that lane.
3. Repair any proven validation/release defect before new functionality if one is found.

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
spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_BSBC_PARITY_HARNESS_v1.json
spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_BSBC_EXECUTION_PARITY_v1.json
spec/self_hosting/BASIC_SHARP_SELF_HOSTING_FIXTURE_CORPUS_v1.json
spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_RUNTIME_SMOKE_v1.json
spec/self_hosting/BASIC_SHARP_BOOTSTRAP_BOUNDARY_AUDIT_v1.json
spec/self_hosting/BASIC_SHARP_README_CURRENT_RELEASE_TRUTH_v1.json
spec/self_hosting/BASIC_SHARP_SELF_HOSTING_MILESTONE_1_v1.json
docs/self_hosting/BASIC_SHARP_SELF_HOSTING_MILESTONE_2_PROPOSAL_v0_1_72.md
```
