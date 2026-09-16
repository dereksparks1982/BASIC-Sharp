# BASIC# Roadmap

## Current accepted base

```text
v0.1.83: Self-Hosting Milestone 2 Slice 10 - Native Symbol Resolution Integration
commit ac8bb906239ed2f199c437d4c3321b18fff1fcab
tag v0.1.83
```

v0.1.83 is the accepted rollback point. It preserves v0.1.81 BASIC#-authored parser dispatch and v0.1.82 BASIC#-authored semantic routing, adds active BASIC#-authored symbol decisions, passed native acceptance, and is the only valid base for v0.1.84.

## Current candidate

```text
v0.1.84: Self-Hosting Milestone 2 Slice 11 - Native Action Routing Integration
```

v0.1.84 preserves the accepted parser, semantic, and symbol stages, then requires the bounded independent semantic resolver to obtain official-action family selection from `compiler/native/first_bsharp_action_router.bsbc` through `compiler/small_compiler_subset_native_action_routing.rb`. Wrong or contradictory native action-family decisions fail closed instead of falling back to a Ruby verb-family choice.

The candidate path is:

```text
BASIC# source
-> TokenizerReader
-> BASIC# native parser dispatch [v0.1.81]
-> SmallCompilerSubsetParser
-> BASIC# native semantic routing [v0.1.82]
-> BASIC# native symbol resolution [v0.1.83]
-> BASIC# native action routing [v0.1.84]
-> SmallCompilerSubsetSemanticResolver
-> BSharp IR
-> independent BSBC encoder
-> independent BSBC loader
-> independent BSharp VM
```

Ruby remains bootstrap/referee authority while this bounded action decision moves into BASIC#. Acceptance requires all accepted official actions to route through BASIC# BSBC, observable invocation counts, wrong-family sabotage rejection, preserved upstream native boundaries, exact downstream parity, and a byte-identical generation #1 / generation #2 fixed point.

## Canonical Company Bible

```text
docs/company_bible/BASIC_SHARP_COMPANY_BIBLE.md
```

This is the single canonical Company Bible for BASIC# conduct, release, validation, rollback, packaging, GitHub closeout, and Elderedd migration rules. Its header version must match `BasicSharp::VERSION`.

## Release closeout order

Every accepted BASIC# build follows the same release path:

1. Run the self-contained versioned `.sh` installer supplied with the download; use a changed-files ZIP only when Derek explicitly requests that packaging path.
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

## Next direction after v0.1.84

1. Continue transferring real compiler authority from Ruby into BASIC# until the production compiler chain no longer requires Ruby decisions.
2. Next likely bounded targets are condition interpretation, event interpretation, selector/reference resolution, semantic transformation, IR construction/emission, source reading/token processing, and compiler orchestration.
3. Keep Ruby as separate bootstrap/referee authority until each replacement boundary earns removal through locked parity and sabotage validation.
4. Do not contaminate creator-facing BASIC# syntax merely to imitate conventional programming languages.
5. Repair any proven validation or release defect inside the current candidate before beginning a later version.

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
