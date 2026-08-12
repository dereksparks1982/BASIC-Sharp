# BASIC# Master Thread Handoff

## Current state

- **Accepted base:** v0.1.80 at commit `62b8a3ffc2eb80d785f80e5b6ba61fa210c5a336`, annotated tag `v0.1.80`.
- **Candidate:** v0.1.81 Self-Hosting Milestone 2 Slice 8: Native Parser Dispatch Integration.
- **Rollback:** restore exact v0.1.80 and remove only v0.1.81 added paths before applying a repaired v0.1.81 candidate.
- **Package:** `BASIC_Sharp_Ruby_Bootstrap_Compiler_v0_1_81_SELF_HOSTING_MILESTONE_2_NATIVE_PARSER_DISPATCH_INTEGRATION_CHANGED_FILES_ONLY.zip`.

## v0.1.81 purpose

v0.1.80 proved that BASIC# can author a bounded compiler-domain component. v0.1.81 makes that component participate in the active bounded independent compiler path.

`compiler/small_compiler_subset_parser.rb` now requests top-level parse routing from `compiler/small_compiler_subset_native_dispatch.rb`. The native dispatcher executes the checked-in BASIC# artifact `compiler/native/first_bsharp_compiler_component.bsbc` through the independent loader/VM and returns one of the locked parser decisions.

The nine accepted heads remain:

```text
KINDS
DEFINE
START
WHEN
IF
OTHERWISE
CONTROLS
HOVER
CONTEXT
```

Primary bounded path:

```text
BASIC# source
-> TokenizerReader
-> SmallCompilerSubsetParser
-> SmallCompilerSubsetNativeDispatch
-> BASIC#-authored BSBC component
-> native parser decision
-> parser continuation
-> independent semantic resolver
-> BSharp IR
-> independent BSBC encoder
-> independent BSBC loader
-> independent BSharp VM
```

## Critical acceptance evidence

The v0.1.81 gate must prove:

- the native dispatch artifact loads;
- all nine accepted heads return their exact locked decisions;
- parser requests are counted through the native dispatcher;
- invalid/unmatched heads are rejected;
- a deliberately wrong native dispatcher causes visible parser failure;
- no Ruby head-table fallback rescues the sabotage case;
- production Parser and production compiler constructors are unavailable on the primary proof path;
- Ruby Runtime is unavailable on the primary proof path;
- independent source-to-BSBC compilation succeeds;
- independent BSBC execution succeeds;
- production and Ruby referee results match;
- the accepted v0.1.80 artifact can bootstrap v0.1.81 generation #1;
- generation #1 can bootstrap generation #2;
- generation #1 and generation #2 are byte-identical.

The native BSBC binary remains deterministic at SHA-256 `cbebf931b65acc7d8ff75409a08d78624bdd9589b60c9c06cbbf66270a19d297`. The readable disassembly remains SHA-256 `fbd05ee0cbe94fd4a0fa17e4b257afbd2faa6a1df4ebda0dc2fd9b431ae1c20c`.

## Canonical Company Bible

```text
docs/company_bible/BASIC_SHARP_COMPANY_BIBLE.md
```

This is the single canonical BASIC# Company Bible and remains mandatory for build, validation, packaging, rollback, and closeout conduct.

Canonical self-hosting contract: `spec/self_hosting/BASIC_SHARP_SELF_HOSTING_SUBSET_v1.json`.

## Language and runtime boundary

No new creator-facing syntax is added. No Profile 8 is added. Profiles 1 through 7, BSBC binary layout, Save meaning, ASK, input behavior, event ordering, and accepted game-making semantics remain protected.

Ruby remains the bootstrap compiler and separate referee authority. Do not claim BASIC# is fully self-hosted or that Ruby is retired.

## Current validation floor

Accepted v0.1.80 floor:

```text
83 test files
660 runs
9,998 assertions
0 failures
0 errors
0 skips
71 required tools
325 sealed artifacts
14 protected artifacts
```

Current v0.1.81 build-side candidate has reached:

```text
84 test files
670 runs
10,052 assertions
0 failures
0 errors
0 skips
72 required tools
330+ sealed artifacts before final release-record sealing
14 protected artifacts
```

Both complete normal and no-locale suites have passed. The native parser dispatch integration tool has also passed against the preserved accepted v0.1.80 bootstrap artifact, including sabotage and fixed-point proofs. Native installer validation remains authoritative for release acceptance.

## Release workflow

1. Build-side package must be changed-files-only with direct project-relative paths.
2. Installer verifies exact v0.1.80 HEAD/tag/branch/clean tree and base-file hashes before mutation.
3. Installer runs pre-mutation forensic overlay over the candidate payload before changing the active tree.
4. Installer applies the payload and runs Ruby syntax, JSON parse, sealed inventory, native dispatch integration, full normal suite, full no-locale suite, all required tools, stress lanes, deterministic sweep, package preflight, release forensic overlay, whole-language gauntlet, and full-count Trial by Fire.
5. Installer must end in one unmistakable `FINAL PASS`.
6. After Derek sees final PASS, create the accepted snapshot first.
7. Then local commit plus annotated tag.
8. Then SSH GitHub push and peeled annotated-tag verification.

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

The v0.1.81 implementation is built and in release-hardening/packaging validation. Do not begin v0.1.82 until v0.1.81 has passed native acceptance and full closeout.
