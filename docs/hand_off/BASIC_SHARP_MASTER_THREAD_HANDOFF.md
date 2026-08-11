# BASIC# Master Thread Handoff

## Current build truth

- **Accepted base:** v0.1.73 / `f41d70a59f26def52ebb253ea1ad8f20c6e8bc0b`
- **Accepted base tag:** `v0.1.73`
- **Candidate:** v0.1.74 Self-Hosting Milestone 2 Slice 1: Semantic Resolver Independence
- **Package:** `BASIC_Sharp_Ruby_Bootstrap_Compiler_v0_1_74_SELF_HOSTING_MILESTONE_2_SEMANTIC_RESOLVER_INDEPENDENCE_CHANGED_FILES_ONLY.zip`
- **Rollback:** reset to tag `v0.1.73` and remove only v0.1.74 added paths before applying a repaired candidate.

## v0.1.74 purpose

BSharp Compiler Subset 0 now owns an independent semantic resolution stage. `compiler/small_compiler_subset_ir_emitter.rb` builds its primary document with `SmallCompilerSubsetSemanticResolver`. The production Ruby `SemanticResolver` remains a separate referee and must not be called or required by `compiler/small_compiler_subset_semantic_resolver.rb`.

The candidate pipeline is:

```text
TokenizerReader
-> SmallCompilerSubsetParser
-> SmallCompilerSubsetSemanticResolver
-> BSharp IR
-> SmallCompilerSubsetBSBCEmitter
-> BSharp VM
```

The new semantic resolver is required to match the production Ruby Parser plus SemanticResolver output exactly. This is Self-Hosting Milestone 2 Slice 1 under Ruby referee control, not full self-hosting and not Ruby retirement.

## v0.1.73 capability carried forward

The accepted creator words `(open`, `(close`, `(lock`, and `(take` remain executable. The v0.1.74 execution corpus includes a dedicated object-interaction fixture that proves those actions travel through the independent semantic resolver, BSBC, loader, BSharp VM, and Ruby referee path without semantic drift.

## Self-hosting contract reference ledger

The active machine-checked self-hosting references are:

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

The single canonical Company Bible remains `docs/company_bible/BASIC_SHARP_COMPANY_BIBLE.md`. Current build, release, validation, rollback, and approval rules must remain synchronized there.

## Validation floor

v0.1.74 must run the semantic resolver regression lane, complete normal suite, complete no-locale suite, the entire sealed tool inventory, deterministic fixture sweep, release package preflight, release forensic overlay, whole-language gauntlet contract, and full Trial by Fire.

The v0.1.73 floor of 583 runs / 9,320 assertions may not shrink. The new semantic resolver tests increase the suite.

## Release closeout

After unmistakable `FINAL PASS`, create the accepted snapshot first. Then local Git commit/tag. Then GitHub push and peeled-tag verification. Do not reorder these stages.

## Current continuation point

Apply and validate the v0.1.74 candidate. If any gate fails, preserve the failure as evidence, return to the accepted v0.1.73 rollback point, repair the same version, and rerun the complete validation lane.
