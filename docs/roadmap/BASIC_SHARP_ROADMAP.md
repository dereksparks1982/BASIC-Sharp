# BASIC# Roadmap

## Current accepted base

```text
v0.1.73: Plain-English Object Interaction Actions
commit f41d70a59f26def52ebb253ea1ad8f20c6e8bc0b
tag v0.1.73
```

v0.1.73 is the accepted rollback point. It made `(open`, `(close`, `(lock`, and `(take` executable end to end and passed the full native validation lane before snapshot, local Git closeout, and GitHub verification.

## Current candidate

```text
v0.1.74: Self-Hosting Milestone 2 Slice 1 - Semantic Resolver Independence
```

v0.1.74 gives BSharp Compiler Subset 0 an independent `SmallCompilerSubsetSemanticResolver`. The subset IR emitter must use that resolver for its primary BSharp IR document. The production Ruby `SemanticResolver` remains a separate referee only.

The accepted subset lane for this build is:

```text
TokenizerReader
-> SmallCompilerSubsetParser
-> SmallCompilerSubsetSemanticResolver
-> BSharp IR
-> subset BSBC
-> BSharp VM
```

The execution corpus expands to 18 fixtures and 56 events. One new fixture carries the accepted v0.1.73 open, close, lock, and take interactions through the independent resolver, BSBC emission, loader, VM, and Ruby-referee parity path.

Reference: `spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_SEMANTIC_RESOLVER_v1.json`.
Reference: `docs/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_SEMANTIC_RESOLVER_v0_1_74.md`.
Reference: `compiler/small_compiler_subset_semantic_resolver.rb`.

Ruby remains the bootstrap compiler. v0.1.74 is not full self-hosting and does not change normal production compiler routing, Profile 1-7 meaning, bytecode format, runtime meaning, Save, ASK, or input behaviour.

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

Priority: active. Status: continuing through v0.1.74.

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
BSharp Compiler Subset 0 has Self-Hosting Milestone 2 Slice 1 under Ruby referee control.
The subset path owns reader, parser, and semantic resolver stages for its bounded lane.
Ruby remains the bootstrap compiler and production referee.
BASIC# is not fully self-hosted.
```

The v0.1.72 proposal is now partially implemented by v0.1.74 semantic resolver independence. Future Milestone 2 slices should continue removing bounded subset dependence on production compiler stages while exact parity remains mandatory.

## Game-making runway

v0.1.73 established four direct creator actions: open, close, lock, and take. v0.1.74 carries them into the self-hosting execution corpus so game-making progress and compiler-independence progress remain connected.

## Next direction after v0.1.74

1. Another bounded Self-Hosting Milestone 2 compiler-stage independence slice under Ruby referee parity.
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
