# BASIC# Roadmap

## Current accepted base

```text
v0.1.80: Self-Hosting Milestone 2 Slice 7 - First BASIC#-Authored Compiler Component
commit 62b8a3ffc2eb80d785f80e5b6ba61fa210c5a336
tag v0.1.80
```

v0.1.80 is the accepted rollback point. It proved that a real compiler-domain decision component can be authored in BASIC#, compiled by the bounded independent compiler path into persisted BSBC, reloaded through the independent loader, executed through the independent BSharp VM, and compared against production and Ruby referees.

## Current candidate

```text
v0.1.81: Self-Hosting Milestone 2 Slice 8 - Native Parser Dispatch Integration
```

v0.1.81 makes the accepted BASIC#-authored compiler component participate in the bounded independent compiler path. `SmallCompilerSubsetParser` no longer owns a Ruby table of the nine accepted top-level heads. It asks `SmallCompilerSubsetNativeDispatch`, which executes `compiler/native/first_bsharp_compiler_component.bsbc` and returns the parser decision.

The candidate path is:

```text
BASIC# source
-> TokenizerReader
-> SmallCompilerSubsetParser
-> SmallCompilerSubsetNativeDispatch
-> BASIC#-authored first_bsharp_compiler_component.bsbc
-> SmallCompilerSubsetBSBCLoader
-> SmallCompilerSubsetBSBCVirtualMachine
-> parser decision
-> bounded parser continuation
-> SmallCompilerSubsetSemanticResolver
-> BSharp IR
-> BSBC
-> independent BSharp VM
```

The nine accepted heads remain `KINDS`, `DEFINE`, `START`, `WHEN`, `IF`, `OTHERWISE`, `CONTROLS`, `HOVER`, and `CONTEXT`.

Acceptance requires all of the following:

- native artifact load through independent machinery;
- exact dispatch decisions for all nine accepted heads;
- observable native dispatch invocation counts;
- no silent Ruby head-table fallback;
- invalid/unmatched head rejection;
- deliberate wrong-dispatch sabotage must fail visibly;
- production Parser and production compiler constructors unavailable on the primary integration proof path;
- Ruby Runtime unavailable on the primary integration proof path;
- independent source-to-BSBC compilation and independent BSBC execution;
- production and Ruby referee parity;
- controlled v0.1.80 bootstrap artifact fencing;
- generation #1 and generation #2 byte-identical fixed point.

Reference: `spec/self_hosting/BASIC_SHARP_NATIVE_PARSER_DISPATCH_INTEGRATION_v1.json`.
Reference: `docs/self_hosting/BASIC_SHARP_NATIVE_PARSER_DISPATCH_INTEGRATION_v0_1_81.md`.
Reference: `compiler/small_compiler_subset_native_dispatch.rb`.
Reference: `tools/native_parser_dispatch_integration.rb`.
Reference: `spec/self_hosting/BASIC_SHARP_SELF_HOSTING_SUBSET_v1.json`.

Ruby remains the bootstrap compiler and separate referee authority. v0.1.81 is not full self-hosting and does not retire Ruby. Profiles 1 through 7 and creator-facing syntax remain unchanged.

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
v0.1.81 makes that BASIC# BSBC component control bounded native parser dispatch.
Ruby remains the bootstrap compiler and separate referee authority.
BASIC# is not fully self-hosted.
```

The v0.1.72 Milestone 2 proposal is now implemented through semantic resolver independence, independent BSBC encoding, independent loading, independent BSharp VM execution, integrated pipeline independence, real artifact round trip, the first BASIC#-authored compiler decision kernel, and active native parser dispatch integration.

## Game-making runway

v0.1.73 established direct creator actions including open, close, lock, and take. v0.1.81 preserves those game-making semantics unchanged while the compiler machinery underneath them becomes more self-directed.

## Next direction after v0.1.81

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
spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_BSBC_PARITY_HARNESS_v1.json
spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_BSBC_EXECUTION_PARITY_v1.json
spec/self_hosting/BASIC_SHARP_SELF_HOSTING_FIXTURE_CORPUS_v1.json
spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_RUNTIME_SMOKE_v1.json
spec/self_hosting/BASIC_SHARP_BOOTSTRAP_BOUNDARY_AUDIT_v1.json
spec/self_hosting/BASIC_SHARP_README_CURRENT_RELEASE_TRUTH_v1.json
spec/self_hosting/BASIC_SHARP_SELF_HOSTING_MILESTONE_1_v1.json
docs/self_hosting/BASIC_SHARP_SELF_HOSTING_MILESTONE_2_PROPOSAL_v0_1_72.md
```
