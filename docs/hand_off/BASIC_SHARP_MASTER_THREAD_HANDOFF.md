# BASIC# Master Thread Handoff

## Current state

- **Accepted base:** v0.1.78 at commit `fac658396e719188b1a980d4d23e34ff81e7e86a`, tag `v0.1.78`.
- **Candidate:** v0.1.79 Self-Hosting Milestone 2 Slice 6: Independent Compiler Driver + BSBC Artifact Round Trip.
- **Rollback:** reset to tag `v0.1.78` and remove only v0.1.79 added paths before applying a repaired candidate.
- **Package:** `BASIC_Sharp_Ruby_Bootstrap_Compiler_v0_1_79_SELF_HOSTING_MILESTONE_2_INDEPENDENT_COMPILER_DRIVER_AND_BSBC_ARTIFACT_ROUND_TRIP_CHANGED_FILES_ONLY.zip`.

## v0.1.79 purpose

BSharp Compiler Subset 0 gains `SmallCompilerSubsetDriver` as a bounded source-file compiler boundary in front of the accepted v0.1.78 `SmallCompilerSubsetPipeline`.

The primary candidate path accepts BASIC# source text or a `.bsharp` file, routes compilation through the independent integrated pipeline, writes a real `.bsbc` artifact through the independent encoder atomic-write path, reloads that saved artifact through `SmallCompilerSubsetBSBCLoader`, and executes it through `SmallCompilerSubsetBSBCVirtualMachine`.

The artifact round-trip proof requires the saved bytes and readable disassembly to be deterministic, requires source-free execution after a successful compile, requires failed source compilation to preserve an already accepted artifact, and requires exact in-memory/artifact/referee parity for event results, final world state, BSharp Save, and deterministic replay.

Production `Lexer`, `Parser`, `SemanticResolver`, `BytecodeEmitter`, `BytecodeLoader`, `BytecodeVirtualMachine`, and `Runtime` remain separate referees. The driver-independence gate disables their constructors and requires the primary compiler-driver path to continue working. Ruby remains the bootstrap compiler and referee.

No new creator-facing syntax is introduced. Profiles 1 through 7 and the accepted BASIC# statement boundaries, action-word visual guides, written action order, and BSBC binary layout remain unchanged.

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

The single canonical Company Bible remains `docs/company_bible/BASIC_SHARP_COMPANY_BIBLE.md`. Current build, release, validation, rollback, approval, and no-password GitHub closeout rules must remain synchronized there.

## Validation floor

v0.1.79 must run the independent compiler-driver regression, BSBC artifact round-trip regression, integrated pipeline independence regression, README truth regression, VM independence regression, loader independence regression, emitter independence regression, complete normal suite, complete no-locale suite, the entire sealed tool inventory, deterministic fixture sweep, release package preflight, release forensic overlay, whole-language gauntlet contract, and full Trial by Fire.

The accepted v0.1.78 floor of 633 runs / 9,786 assertions may not shrink. The new driver and artifact-round-trip tests increase the suite.

## Release closeout

After unmistakable `FINAL PASS`, create the accepted snapshot first. Then local Git commit/tag. Then GitHub push and peeled-tag verification. Do not reorder these stages.

## Current continuation point

Apply and validate the v0.1.79 candidate. If any gate fails, preserve the failure as evidence, return to the accepted v0.1.78 rollback point, repair the same version, and rerun the complete validation lane.
