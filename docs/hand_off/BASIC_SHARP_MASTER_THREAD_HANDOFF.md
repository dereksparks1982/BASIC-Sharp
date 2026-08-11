# BASIC# Master Thread Handoff

## Current state

- **Accepted base:** v0.1.76 at commit `9b0069e175a62d4250b3801a0ed864a7e4cf08e2`, tag `v0.1.76`.
- **Candidate:** v0.1.77 Self-Hosting Milestone 2 Slice 4: BSharp VM Execution Independence.
- **Rollback:** reset to tag `v0.1.76` and remove only v0.1.77 added paths before applying a repaired candidate.
- **Package:** `BASIC_Sharp_Ruby_Bootstrap_Compiler_v0_1_77_SELF_HOSTING_MILESTONE_2_BSHARP_VM_EXECUTION_INDEPENDENCE_CHANGED_FILES_ONLY.zip`.

## v0.1.77 purpose

BSharp Compiler Subset 0 gains `SmallCompilerSubsetBSBCVirtualMachine` as an independent execution engine. The production Ruby `BytecodeVirtualMachine` and `BasicSharp::Runtime` remain separate referees for event-result, world-state, Save, follow-up-event, loop-protection, and deterministic replay parity.

The bounded proof path is:

```text
TokenizerReader
-> SmallCompilerSubsetParser
-> SmallCompilerSubsetSemanticResolver
-> BSharp IR
-> SmallCompilerSubsetBSBCEncoder
-> BSharp Bytecode
-> SmallCompilerSubsetBSBCLoader
-> SmallCompilerSubsetBSBCVirtualMachine
```

The independent VM must not require `compiler/bytecode_virtual_machine.rb`, call or instantiate `BytecodeVirtualMachine.new`, or inherit from `BytecodeVirtualMachine`. Normal production execution routing remains unchanged.

The dedicated v0.1.77 fixture combines Kind inheritance, creator text, whole-number values, `(open`, `(close`, `(lock`, `(take`, IF/OTHERWISE, multiple selection, exact/Kind selectors, and follow-up events. It must execute through the full bounded independent path and match the production VM and Ruby runtime referees.

The execution-independence gate also requires 1,024-event high-volume deterministic parity and exact 1,024 follow-up-event loop-protection parity.

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

v0.1.77 must run the BSharp VM independence regression lane, README truth regression, loader independence regression, emitter independence regression, complete normal suite, complete no-locale suite, the entire sealed tool inventory, deterministic fixture sweep, release package preflight, release forensic overlay, whole-language gauntlet contract, and full Trial by Fire.

The accepted v0.1.76 floor of 611 runs / 9,558 assertions may not shrink. The new BSharp VM independence tests increase the suite.

## Release closeout

After unmistakable `FINAL PASS`, create the accepted snapshot first. Then local Git commit/tag. Then GitHub push and peeled-tag verification. Do not reorder these stages.

## Current continuation point

Apply and validate the v0.1.77 candidate. If any gate fails, preserve the failure as evidence, return to the accepted v0.1.76 rollback point, repair the same version, and rerun the complete validation lane.
