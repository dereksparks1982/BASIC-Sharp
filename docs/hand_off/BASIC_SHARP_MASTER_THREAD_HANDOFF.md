# BASIC# Master Thread Handoff

## Current state

- **Accepted release:** v0.0.84 Self-Hosting Milestone 2 Slice 11: Native Action Routing Integration.
- **Accepted release commit:** `14dd3e0f9134ed55cdb71bb69b8a2f3c555206c9`.
- **Accepted release tag:** `v0.0.84`.
- **Branch:** `main`.
- **Next build:** v0.0.85.
- **Release state:** v0.0.84 passed acceptance and closeout. The earlier rejected v0.0.84 package remains rejected evidence and is not a baseline.

## v0.0.84 purpose

v0.0.81 put BASIC# bytecode into active parser dispatch. v0.0.82 added active BASIC# semantic-family routing. v0.0.83 added active BASIC# symbol-resolution decisions. v0.0.84 preserves all three and adds a fourth authority boundary: `compiler/small_compiler_subset_native_action_routing.rb` executes `compiler/native/first_bsharp_action_router.bsbc`, and the independent semantic resolver must obey the BASIC# action-family decision or fail visibly.

Primary bounded path:

```text
BASIC# source
-> TokenizerReader
-> v0.0.81 BASIC# native parser dispatch
-> SmallCompilerSubsetParser
-> v0.0.82 BASIC# native semantic routing
-> v0.0.83 BASIC# native symbol resolution
-> v0.0.84 BASIC# native action routing
-> SmallCompilerSubsetSemanticResolver
-> BSharp IR
-> independent BSBC encoder
-> independent BSBC loader
-> independent BSharp VM
```

## Critical acceptance evidence

The v0.0.84 gate must prove all accepted official action words route through BASIC# BSBC, native action invocation counts are observable, wrong-family sabotage fails closed without Ruby family fallback, v0.0.81 parser dispatch/v0.0.82 semantic routing/v0.0.83 symbol resolution remain active upstream, production compiler constructors and Ruby Runtime remain unavailable on the primary proof path, independent source-to-BSIR/BSBC/execution preserves referee parity, and generation #1 / generation #2 action-router output is byte-identical. The repaired candidate must also pass `tools/company_bible_audit.rb` after the rejected v0.0.84 current-reference failure.

## Canonical Company Bible

`docs/company_bible/BASIC_SHARP_COMPANY_BIBLE.md` is the single canonical BASIC# Company Bible and remains mandatory for build, validation, packaging, rollback, and closeout conduct. Canonical self-hosting contract: `spec/self_hosting/BASIC_SHARP_SELF_HOSTING_SUBSET_v1.json`.

## Language and runtime boundary

No new creator-facing syntax and no Profile 8. Profiles 1 through 7, BSBC binary layout, Save meaning, ASK, input behavior, event ordering, and accepted game-making semantics remain protected. Ruby remains the bootstrap compiler and separate referee authority. Do not claim BASIC# is fully self-hosted or that Ruby is retired.

## Current validation floor

Accepted v0.0.84 validation floor:

```text
86 test files
687 runs
10,134 assertions
0 failures
0 errors
0 skips
74 required tools
370 sealed artifacts
14 protected artifacts
```

Accepted v0.0.84 inventory:

```text
87 test files
75 required tools
386 sealed artifacts
14 protected artifacts
```

Complete normal and no-locale suites, every sealed required tool, deterministic sweep, release preflight, forensic overlay, whole-language gauntlet, and full-count Trial by Fire remain mandatory before `FINAL PASS`.

## Release workflow

1. Run the single self-contained versioned `.sh` installer against exact accepted v0.0.83.
2. Verify exact v0.0.83 HEAD/tag/branch/clean tree and all base-file hashes before mutation.
3. Materialize the embedded changed-file payload outside the project, verify hashes, and run pre-mutation forensic checks.
4. Capture rollback bytes, install only declared paths, and validate syntax/JSON/whitespace/package scope plus Company Bible/current-reference integrity.
5. Run native parser dispatch, native semantic routing, native symbol resolution, and native action routing proofs; complete normal/no-locale suites; every sealed required tool; stress lanes; deterministic sweep; preflight; forensic overlay; whole-language gauntlet; and full-count Trial by Fire.
6. Require one unmistakable `FINAL PASS`.
7. After the project creator sees FINAL PASS: accepted snapshot first, then local commit/annotated tag, then GitHub SSH push and peeled-tag verification.

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
spec/self_hosting/BASIC_SHARP_NATIVE_ACTION_ROUTING_INTEGRATION_v1.json
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

v0.0.84 Native Action Routing Integration is accepted and closed. The next build is v0.0.85. Profiles 1 through 7 remain protected; no Profile 8 is implied. Ruby remains bootstrap/referee authority until later boundaries are independently replaced and proven.
