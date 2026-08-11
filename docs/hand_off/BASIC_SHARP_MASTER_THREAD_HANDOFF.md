# BASIC# Master Thread Handoff

## Current state

- **Accepted base:** v0.1.75 at commit `e711ee4e7d4b8c0bbd2f845c1e955423bbc739f3`, tag `v0.1.75`.
- **Candidate:** v0.1.76 Self-Hosting Milestone 2 Slice 3: BSBC Loader Independence.
- **Rollback:** reset to tag `v0.1.75` and remove only v0.1.76 added paths before applying a repaired candidate.
- **Package:** `BASIC_Sharp_Ruby_Bootstrap_Compiler_v0_1_76_README_TRUTH_GATE_REPAIR_SELF_HOSTING_MILESTONE_2_BSBC_LOADER_INDEPENDENCE_CHANGED_FILES_ONLY.zip`.

## v0.1.76 purpose

BSharp Compiler Subset 0 gains `SmallCompilerSubsetBSBCLoader` as an independent BSBC trust boundary. The production Ruby `BytecodeLoader` remains loaded only as a separate referee for exact model, summary, fingerprint, disassembly, and malformed-artifact rejection comparison.

The bounded proof path is:

```text
TokenizerReader
-> SmallCompilerSubsetParser
-> SmallCompilerSubsetSemanticResolver
-> BSharp IR
-> SmallCompilerSubsetBSBCEncoder
-> BSharp Bytecode
-> SmallCompilerSubsetBSBCLoader
-> BSharp Virtual Machine execution engine
```

The independent loader must not require `compiler/bytecode_loader.rb`, call or instantiate `BytecodeLoader.new`, or inherit from `BytecodeLoader`. A bootstrap-only VM adapter in the execution-parity lane feeds the subset-validated trusted model into the unchanged BSharp VM execution implementation.

The dedicated v0.1.76 fixture combines Kind inheritance, creator text, whole-number values, `(open`, `(close`, `(lock`, `(take`, IF/OTHERWISE, and exact/Kind selectors. It must emit and load Profile 7 BSBC independently, match the production loader trusted model exactly, execute through the BSharp VM engine, and match the Ruby referee runtime.

The malformed campaign contains 16 sealed mutations and requires deterministic rejection-message parity with the production loader.

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

v0.1.76 must run the BSBC loader independence regression lane, complete normal suite, complete no-locale suite, the entire sealed tool inventory, deterministic fixture sweep, release package preflight, release forensic overlay, whole-language gauntlet contract, and full Trial by Fire.

The accepted v0.1.75 floor of 599 runs / 9,503 assertions may not shrink. The new BSBC loader independence tests increase the suite.

## Release closeout

After unmistakable `FINAL PASS`, create the accepted snapshot first. Then local Git commit/tag. Then GitHub push and peeled-tag verification. Do not reorder these stages.

## Current continuation point

Apply and validate the v0.1.76 candidate. If any gate fails, preserve the failure as evidence, return to the accepted v0.1.75 rollback point, repair the same version, and rerun the complete validation lane.
