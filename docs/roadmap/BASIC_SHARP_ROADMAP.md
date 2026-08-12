# BASIC# Roadmap

## Current accepted base

```text
v0.1.82: Self-Hosting Milestone 2 Slice 9 - Native Semantic Routing Integration
commit e5181842eba869da1d561359b84ff7e6b34ddddd
tag v0.1.82
```

v0.1.82 is the accepted rollback point. It preserved v0.1.81 BASIC#-authored parser dispatch, added active BASIC#-authored semantic routing for all eight accepted semantic families, failed closed under semantic sabotage, proved a two-generation fixed point, and completed native Trial by Fire, snapshot, annotated tag, SSH push, and peeled-tag verification.

## Current candidate

```text
v0.1.83: Self-Hosting Milestone 2 Slice 10 - Native Symbol Resolution Integration
```

v0.1.83 preserves the accepted native parser and semantic stages, then makes the bounded symbol-table and semantic path request final known/unknown, unique/duplicate, Kind-link, PLAYER, action, and value decisions from `compiler/native/first_bsharp_symbol_resolver.bsbc` through `compiler/small_compiler_subset_native_symbol_resolution.rb`.

The candidate path is:

```text
BASIC# source
-> TokenizerReader
-> BASIC# native parser dispatch [v0.1.81]
-> SmallCompilerSubsetParser
-> BASIC# native semantic routing [v0.1.82]
-> BASIC# native symbol resolution [v0.1.83]
-> SmallCompilerSubsetSemanticResolver
-> BSharp IR
-> independent BSBC encoder
-> independent BSBC loader
-> independent BSharp VM
```

Ruby bootstrap plumbing may expose neutral lookup observations, but the final bounded symbol decision must come from BASIC# BSBC and contradictory native decisions fail closed. Acceptance requires false-known, false-unknown, duplicate, and bad Kind-link sabotage rejection, observable symbol invocation counts, preserved upstream native stages, disabled production constructors on the primary proof path, exact BSharp IR/BSBC/runtime referee parity, and a v0.1.82-to-v0.1.83 two-generation byte-identical fixed point.

## Canonical Company Bible

```text
docs/company_bible/BASIC_SHARP_COMPANY_BIBLE.md
```

This is the single canonical Company Bible for BASIC# conduct, release, validation, rollback, packaging, GitHub closeout, and Elderedd migration rules. Its header version must match `BasicSharp::VERSION`.

## Release closeout order

Every accepted BASIC# build follows the same release path:

1. Apply the changed-files ZIP with the exact terminal command supplied with the download.
2. Run installer validation including the complete normal test suite, complete no-locale suite, all sealed tools, required stress lanes, deterministic sweep, forensic/preflight gates, whole-language gauntlet, and full Trial by Fire counts.
3. Preserve `PHASE START` / `PHASE PASS`, visible Minitest dot progress, run/assertion counts, and one unmistakable `FINAL PASS`.
4. Create the accepted snapshot after final PASS and before local Git closeout.
5. Commit and create the annotated tag locally only after acceptance proof.
6. Push through the proven SSH/no-password GitHub path and verify the peeled annotated tag.
7. Begin the next build only after the current build is fully closed.

## Elderedd migration

Priority: active.

- Elderedd Softworks LLC is the parent company identity.
- Elderedd Laboratory is the active lab identity.
- ELDL is internal shorthand only.
- BCS means BSharp Creator Services and remains future service-layer naming only.
- DKLab is retired as an active BASIC# identity.
- DKLab may remain as compatibility, rollback, migration, and archival history.
- Canonical future path: `~/Elderedd/Projects/BASIC#`.
- Legacy compatibility path: `~/DKLab/Projects/BASIC#`.
- Do not remove the DKLab compatibility bridge until a later accepted build proves no active BASIC# workflow depends on it.

## Self-hosting runway

Current truthful claim:

```text
v0.1.80 proved the first bounded compiler-domain component authored in BASIC#.
v0.1.81 made BASIC# BSBC control bounded native parser dispatch.
v0.1.82 made BASIC# BSBC control bounded semantic routing.
v0.1.83 adds bounded BASIC#-authored symbol-resolution decisions.
Ruby remains the bootstrap compiler and separate referee authority.
BASIC# is not fully self-hosted.
```

The v0.1.72 Milestone 2 proposal is now implemented through semantic resolver independence, independent BSBC encoding, independent loading, independent BSharp VM execution, integrated pipeline independence, real artifact round trip, the first BASIC#-authored compiler decision kernel, and active native parser dispatch integration.

## Game-making runway

v0.1.73 established direct creator actions including open, close, lock, and take. v0.1.81 preserves those game-making semantics unchanged while the compiler machinery underneath them becomes more self-directed.

## Next direction after v0.1.83

1. Expand BASIC#-authored compiler ownership only where accepted BASIC# can express real compiler work without contaminating creator-facing syntax.
2. Keep Ruby as referee until BASIC#-authored components reproduce locked outputs strongly enough to earn further replacement.
3. Continue meaningful creator/game-making capability expansion when that lane is selected.
4. Repair any proven validation or release defect before new functionality.

No new governance/audit system is planned unless a demonstrated failure requires it.

## Public proof-application ladder

1. Calculator
2. Text Adventure / choose-your-own-adventure
3. Pong
4. Breakout
5. Solitaire
6. Larger 2D Game
7. Media Player

These are future proof programs, not permission to interrupt the active compiler/runtime lane. Solitaire remains intended as a free noncommercial BASIC# showcase while Derek's Demon Killer card/deck artwork remains separately protected.

## Release-hardening runway

```text
tools/native_parser_dispatch_integration.rb
tools/native_semantic_routing_integration.rb
tools/native_symbol_resolution_integration.rb
tools/deterministic_fixture_hash_sweep.rb
tools/release_package_preflight.rb
tools/release_forensic_overlay.rb
tools/trial_by_fire_inventory.rb
tools/trial_by_fire_gauntlet.rb
```

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
spec/self_hosting/BASIC_SHARP_NATIVE_PARSER_DISPATCH_INTEGRATION_v1.json
spec/self_hosting/BASIC_SHARP_NATIVE_SEMANTIC_ROUTING_INTEGRATION_v1.json
spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_BSBC_PARITY_HARNESS_v1.json
spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_BSBC_EXECUTION_PARITY_v1.json
spec/self_hosting/BASIC_SHARP_SELF_HOSTING_FIXTURE_CORPUS_v1.json
spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_RUNTIME_SMOKE_v1.json
spec/self_hosting/BASIC_SHARP_BOOTSTRAP_BOUNDARY_AUDIT_v1.json
spec/self_hosting/BASIC_SHARP_README_CURRENT_RELEASE_TRUTH_v1.json
spec/self_hosting/BASIC_SHARP_SELF_HOSTING_MILESTONE_1_v1.json
docs/self_hosting/BASIC_SHARP_SELF_HOSTING_MILESTONE_2_PROPOSAL_v0_1_72.md
```
