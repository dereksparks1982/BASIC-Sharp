# BASIC# Master Thread Handoff

## Current state

- **Accepted base:** v0.1.74 at commit `6ef4cae79c4e353b54a2bd6376f43200636748f2`, tag `v0.1.74`.
- **Candidate:** v0.1.75 Self-Hosting Milestone 2 Slice 2: BSBC Emitter Independence.
- **Rollback:** reset to tag `v0.1.74` and remove only v0.1.75 added paths before applying a repaired candidate.
- **Package:** `BASIC_Sharp_Ruby_Bootstrap_Compiler_v0_1_75_SELF_HOSTING_MILESTONE_2_BSBC_EMITTER_INDEPENDENCE_CHANGED_FILES_ONLY.zip`.

## v0.1.75 purpose

BSharp Compiler Subset 0 gains `SmallCompilerSubsetBSBCEncoder` as the primary producer of BSBC bytes. The production Ruby `BytecodeEmitter` remains loaded only as a separate referee for exact byte-for-byte comparison.

The bounded path is:

```text
TokenizerReader
-> SmallCompilerSubsetParser
-> SmallCompilerSubsetSemanticResolver
-> BSharp IR
-> SmallCompilerSubsetBSBCEncoder
-> BSharp Bytecode
-> BytecodeLoader
-> BSharp Virtual Machine
```

The independent encoder must not require `compiler/bytecode_emitter.rb` and must not call `BytecodeEmitter.new`. The orchestrator may construct the production emitter only on the explicit referee side.

The dedicated v0.1.75 fixture combines `(open`, `(close`, `(lock`, `(take`, whole-number increase, IF, and OTHERWISE. It must emit Profile 7 BSBC independently, match the production emitter byte for byte, load successfully, execute in the BSharp VM, and match the Ruby referee runtime.

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

v0.1.75 must run the BSBC emitter independence regression lane, complete normal suite, complete no-locale suite, the entire sealed tool inventory, deterministic fixture sweep, release package preflight, release forensic overlay, whole-language gauntlet contract, and full Trial by Fire.

The accepted v0.1.74 floor of 592 runs / 9,382 assertions may not shrink. The new BSBC independence tests increase the suite.

## Release closeout

After unmistakable `FINAL PASS`, create the accepted snapshot first. Then local Git commit/tag. Then GitHub push and peeled-tag verification. Do not reorder these stages.

## Current continuation point

Apply and validate the v0.1.75 candidate. If any gate fails, preserve the failure as evidence, return to the accepted v0.1.74 rollback point, repair the same version, and rerun the complete validation lane.
