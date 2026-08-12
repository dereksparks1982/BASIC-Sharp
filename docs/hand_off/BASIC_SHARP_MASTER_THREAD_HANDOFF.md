# BASIC# Master Thread Handoff

## Current state

- **Accepted base:** v0.1.79 at commit `fdb8d17e6ea48e524cbe8713026a58902bd5da20`, tag `v0.1.79`.
- **Candidate:** v0.1.80 Self-Hosting Milestone 2 Slice 7: First BASIC#-Authored Compiler Component.
- **Rollback:** reset to tag `v0.1.79` and remove only v0.1.80 added paths before applying a repaired candidate.
- **Package:** `BASIC_Sharp_Ruby_Bootstrap_Compiler_v0_1_80_SELF_HOSTING_MILESTONE_2_FIRST_BASIC_SHARP_AUTHORED_COMPILER_COMPONENT_CHANGED_FILES_ONLY.zip`.

## v0.1.80 purpose

BSharp Compiler Subset 0 crosses the first bounded authorship boundary. `compiler/native/first_bsharp_compiler_component.bsharp` is real BASIC# source that owns compiler-domain decision rules for the nine accepted block heads: `KINDS`, `DEFINE`, `START`, `WHEN`, `IF`, `OTHERWISE`, `CONTROLS`, `HOVER`, and `CONTEXT`.

The accepted v0.1.79 `SmallCompilerSubsetDriver` compiles that source through the independent pipeline into `compiler/native/first_bsharp_compiler_component.bsbc`. The checked-in artifact must be byte-identical to independently recompiled output, must load through `SmallCompilerSubsetBSBCLoader`, and must execute through `SmallCompilerSubsetBSBCVirtualMachine` after the source copy used for compilation is removed.

The primary native-component gate disables production `Lexer`, `Parser`, `SemanticResolver`, `BytecodeEmitter`, `BytecodeLoader`, `BytecodeVirtualMachine`, and `Runtime` constructors while the BASIC# component is compiled and proven. Separate production BytecodeEmitter/BSharp VM and Ruby Runtime paths remain mandatory referees afterward.

This is the first BASIC#-authored compiler component, not full self-hosting. Ruby remains the bootstrap compiler and referee authority. No new creator-facing syntax is introduced; Profiles 1 through 7, the opening `(` action-word visual guide, and written action order remain unchanged.

The Company Bible header drift reported after v0.1.79 is repaired in v0.1.80. `tools/company_bible_audit.rb` now rejects a canonical Company Bible header version that does not exactly match `BasicSharp::VERSION`.

## Self-hosting contract reference ledger

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
spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_EXECUTION_CORPUS_v1.json
spec/self_hosting/BASIC_SHARP_SELF_HOSTING_FIXTURE_CORPUS_v1.json
spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_RUNTIME_SMOKE_v1.json
spec/self_hosting/BASIC_SHARP_BOOTSTRAP_BOUNDARY_AUDIT_v1.json
spec/self_hosting/BASIC_SHARP_README_CURRENT_RELEASE_TRUTH_v1.json
spec/self_hosting/BASIC_SHARP_SELF_HOSTING_MILESTONE_1_v1.json
```

## Canonical Company Bible

The single canonical Company Bible remains `docs/company_bible/BASIC_SHARP_COMPANY_BIBLE.md`. Its header version must equal the active BASIC# version.

## Validation floor

v0.1.80 must run the first BASIC#-authored compiler component regression, independent compiler-driver regression, BSBC artifact round-trip regression, integrated pipeline independence regression, README truth regression, Company Bible audit, VM independence regression, loader independence regression, emitter independence regression, complete normal suite, complete no-locale suite, the entire sealed tool inventory, deterministic fixture sweep, release package preflight, release forensic overlay, whole-language gauntlet contract, and full Trial by Fire.

The accepted v0.1.79 suite was 651 runs / 9,930 assertions with zero failures, errors, or skips. The v0.1.80 suite may grow but must not shrink below that accepted floor.

## Release closeout

After unmistakable `FINAL PASS`, create the accepted snapshot first. Then local Git commit/tag. Then GitHub push and peeled-tag verification. Do not reorder these stages.

## Current continuation point

Apply and validate the v0.1.80 candidate. If any gate fails, preserve the failure as evidence, return to accepted v0.1.79 at `fdb8d17e6ea48e524cbe8713026a58902bd5da20`, repair the same version, and rerun the complete validation lane.
