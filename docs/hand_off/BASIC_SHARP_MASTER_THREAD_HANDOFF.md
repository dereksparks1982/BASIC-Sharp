# BASIC# Master Thread Handoff

## Current state

- **Accepted base:** v0.1.77 at commit `5e7d15512322d7aef4237e4cd5d9d605b6966f3d`, tag `v0.1.77`.
- **Candidate:** v0.1.78 Self-Hosting Milestone 2 Slice 5: Integrated Independent Compiler Pipeline.
- **Rollback:** reset to tag `v0.1.77` and remove only v0.1.78 added paths before applying a repaired candidate.
- **Package:** `BASIC_Sharp_Ruby_Bootstrap_Compiler_v0_1_78_SELF_HOSTING_MILESTONE_2_INTEGRATED_INDEPENDENT_COMPILER_PIPELINE_CHANGED_FILES_ONLY.zip`.

## v0.1.78 purpose

BSharp Compiler Subset 0 gains `SmallCompilerSubsetPipeline` as one bounded source-to-world orchestration path. It connects `TokenizerReader`, `SmallCompilerSubsetParser`, `SmallCompilerSubsetSemanticResolver`, BSharp IR, `SmallCompilerSubsetBSBCEncoder`, `SmallCompilerSubsetBSBCLoader`, and `SmallCompilerSubsetBSBCVirtualMachine` without using production compiler constructors on the primary path.

`TokenizerReader` now owns its primary line/comment record generation. The production `Lexer` remains available only as a separate exact-parity referee. Production `Parser`, `SemanticResolver`, `BytecodeEmitter`, `BytecodeLoader`, `BytecodeVirtualMachine`, and `Runtime` likewise remain separate referees.

The dedicated Profile 7 pipeline fixture exercises Kind inheritance, creator text, whole-number values, `(open`, `(close`, `(lock`, `(take`, IF/OTHERWISE, multiple selection, exact/Kind selectors, and follow-up events. No new creator-facing syntax is introduced.

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

v0.1.78 must run the integrated pipeline independence regression, tokenizer/reader regression, README truth regression, VM independence regression, loader independence regression, emitter independence regression, complete normal suite, complete no-locale suite, the entire sealed tool inventory, deterministic fixture sweep, release package preflight, release forensic overlay, whole-language gauntlet contract, and full Trial by Fire.

The accepted v0.1.77 floor of 622 runs / 9,717 assertions may not shrink. The new pipeline-independence tests increase the suite.

## Release closeout

After unmistakable `FINAL PASS`, create the accepted snapshot first. Then local Git commit/tag. Then GitHub push and peeled-tag verification. Do not reorder these stages.

## Current continuation point

Apply and validate the v0.1.78 candidate. If any gate fails, preserve the failure as evidence, return to the accepted v0.1.77 rollback point, repair the same version, and rerun the complete validation lane.
