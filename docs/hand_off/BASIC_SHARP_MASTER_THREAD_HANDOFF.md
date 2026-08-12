# BASIC# Master Thread Handoff

## Current state

- **Accepted base:** v0.1.81 at commit `1805102260cff3d42bd1a7a1229c06b4a9300bb9`, annotated tag `v0.1.81`, main synchronized to private GitHub by SSH.
- **Candidate:** v0.1.82 Self-Hosting Milestone 2 Slice 9: Native Semantic Routing Integration.
- **Rollback:** restore exact v0.1.81 and remove only v0.1.82 added paths before applying a repaired v0.1.82 candidate.
- **Package:** `BASIC_Sharp_Ruby_Bootstrap_Compiler_v0_1_82_SELF_HOSTING_MILESTONE_2_NATIVE_SEMANTIC_ROUTING_INTEGRATION_CHANGED_FILES_ONLY.zip`.

## v0.1.82 purpose

v0.1.81 put BASIC# bytecode into active parser dispatch. v0.1.82 keeps that gate and adds a second active BASIC# authority boundary inside the bounded independent semantic resolver. `compiler/small_compiler_subset_native_semantic_routing.rb` executes `compiler/native/first_bsharp_semantic_router.bsbc` and returns the route used by `SmallCompilerSubsetSemanticResolver`.

The eight accepted semantic families are Kind definitions, Thing definitions, starting facts, WHEN event rules, IF/OTHERWISE rules, CONTROLS declarations, HOVER declarations, and CONTEXT declarations.

Primary bounded path:

```text
BASIC# source
-> TokenizerReader
-> v0.1.81 BASIC# native parser dispatch
-> SmallCompilerSubsetParser
-> v0.1.82 BASIC# native semantic routing
-> SmallCompilerSubsetSemanticResolver
-> BSharp IR
-> independent BSBC encoder
-> independent BSBC loader
-> independent BSharp VM
```

## Critical acceptance evidence

The v0.1.82 gate must prove native semantic artifact loading, all eight exact routes, observed invocation counts, unknown-route rejection, wrong-route sabotage without Ruby fallback, preserved v0.1.81 native parser dispatch, production Parser/SemanticResolver/compiler constructors and Ruby Runtime unavailable on the primary path, independent source-to-BSIR/BSBC/execution, production and Ruby referee parity, and a byte-identical generation #1 / generation #2 fixed point bootstrapped from accepted v0.1.81.

## Canonical Company Bible

`docs/company_bible/BASIC_SHARP_COMPANY_BIBLE.md` is the single canonical BASIC# Company Bible and remains mandatory for build, validation, packaging, rollback, and closeout conduct. Canonical self-hosting contract: `spec/self_hosting/BASIC_SHARP_SELF_HOSTING_SUBSET_v1.json`.

## Language and runtime boundary

No new creator-facing syntax and no Profile 8. Profiles 1 through 7, BSBC binary layout, Save meaning, ASK, input behavior, event ordering, and accepted game-making semantics remain protected. Ruby remains the bootstrap compiler and separate referee authority. Do not claim BASIC# is fully self-hosted or that Ruby is retired.

## Current validation floor

Accepted v0.1.81 floor:

```text
84 test files
670 runs
10,052 assertions
0 failures
0 errors
0 skips
72 required tools
338 sealed artifacts
14 protected artifacts
```

Current v0.1.82 build-side candidate:

```text
85 test files
677 runs
10,078 assertions
0 failures
0 errors
0 skips
73 required tools
354 sealed artifacts
14 protected artifacts
```

Complete normal and no-locale suites have passed build-side. Native semantic sabotage/fixed-point proof, every sealed tool, and full-count Trial by Fire remain mandatory before package handoff.

## Release workflow

1. Build a direct-root changed-files-only package against exact accepted v0.1.81.
2. Verify exact v0.1.81 HEAD/tag/branch/clean tree and all base-file hashes before mutation.
3. Run pre-mutation forensic overlay over the candidate payload.
4. Capture rollback bytes, install only declared paths, and validate syntax/JSON/whitespace/package scope.
5. Run native parser dispatch and native semantic routing proofs, complete normal/no-locale suites, every sealed required tool, stress lanes, deterministic sweep, package preflight, forensic overlay, whole-language gauntlet, and full-count Trial by Fire.
6. Require one unmistakable `FINAL PASS`.
7. After Derek sees FINAL PASS: accepted snapshot first, then local commit/annotated tag, then private GitHub SSH push and peeled annotated-tag verification.

## Canonical contract reference ledger

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
spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_EXECUTION_CORPUS_v1.json
spec/self_hosting/BASIC_SHARP_SELF_HOSTING_FIXTURE_CORPUS_v1.json
spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_RUNTIME_SMOKE_v1.json
spec/self_hosting/BASIC_SHARP_BOOTSTRAP_BOUNDARY_AUDIT_v1.json
spec/self_hosting/BASIC_SHARP_README_CURRENT_RELEASE_TRUTH_v1.json
spec/self_hosting/BASIC_SHARP_SELF_HOSTING_MILESTONE_1_v1.json
```

## Continuation point

v0.1.82 Native Semantic Routing Integration is the active candidate. Continue release hardening and packaging only. Do not begin v0.1.83 until v0.1.82 has passed Derek-side native acceptance and full closeout.
