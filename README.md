# BASIC# Ruby Bootstrap Compiler v0.1.78

BASIC# v0.1.78 adds Self-Hosting Milestone 2 Slice 5: Integrated Independent Compiler Pipeline.

v0.1.78 connects the bounded Subset 0 reader, parser, semantic resolver, BSharp IR emitter, independent BSBC encoder, independent BSBC loader, and independent BSharp VM behind one `SmallCompilerSubsetPipeline` source-to-world path. The pipeline accepts BASIC# source and produces the same BSharp IR, BSBC bytes, event results, final world, and BSharp Save document as the separate production and Ruby referee paths.

`TokenizerReader` now produces its primary line/comment records without invoking the production `Lexer`; exact Lexer comparison remains available only as a referee check. The integrated primary pipeline is required to keep working when production `Lexer`, `Parser`, `SemanticResolver`, `BytecodeEmitter`, `BytecodeLoader`, `BytecodeVirtualMachine`, and `Runtime` constructors are disabled.

The bounded proof path is now `TokenizerReader -> SmallCompilerSubsetParser -> SmallCompilerSubsetSemanticResolver -> BSharp IR -> SmallCompilerSubsetBSBCEncoder -> BSharp Bytecode -> SmallCompilerSubsetBSBCLoader -> SmallCompilerSubsetBSBCVirtualMachine`, orchestrated by `SmallCompilerSubsetPipeline`.

This is Self-Hosting Milestone 2 Slice 5, not full self-hosting. Ruby remains the bootstrap compiler and referee authority. Normal BASIC# production compilation and runtime routing remain unchanged.

No new creator-facing syntax is introduced in v0.1.78. Existing BASIC# statement boundaries, action words such as `(open`, `(close`, `(lock`, `(take`, and written action order remain unchanged. Compiler complexity stays inside the compiler rather than being pushed onto the creator.

The dedicated integrated-pipeline fixture remains Profile 7 and exercises Kind inheritance, creator text, whole-number values, multiple selection, exact and Kind selectors, object interaction, IF/OTHERWISE, follow-up events, and deterministic replay. Profiles 1 through 7 remain unchanged.

Current release truth: Elderedd identity migration remains active under Elderedd Softworks LLC and Elderedd Laboratory. The DKLab compatibility layer remains for compatibility, rollback, migration, and historical path support only. BCS means BSharp Creator Services and remains a future service layer, not part of this build. The README Current Release Truth Gate remains active.

Release hardening remains active: Elderedd path direction, UTF-8 source reading, minimal/no-locale Ruby validation, release package preflight, deterministic fixture hash sweep, payload SHA-256 checks, changed-file scope checks, release forensic overlay, pre-mutation forensic overlay, and the sealed validation inventory must report all mismatches together.

The whole-language test gauntlet remains at 128,000 event paths, 128,000 platform frames, 384 generated programs, and 3,072 mutations. v0.1.78 changes bounded compiler orchestration only and preserves creator-facing language meaning, the BSBC binary format, Save, ASK, input behaviour, and normal production runtime behaviour.

## v0.1.78 active gates

```text
spec/release/BASIC_SHARP_RELEASE_FORENSIC_OVERLAY_v1.json
tools/release_forensic_overlay.rb
tests/test_release_forensic_overlay.rb
spec/release/BASIC_SHARP_RELEASE_PACKAGE_PREFLIGHT_v1.json
tools/release_package_preflight.rb
tests/test_release_package_preflight.rb
spec/release/BASIC_SHARP_DETERMINISTIC_FIXTURE_HASH_SWEEP_v1.json
tools/deterministic_fixture_hash_sweep.rb
tests/test_deterministic_fixture_hash_sweep.rb
spec/governance/BASIC_SHARP_ELDEREDD_IDENTITY_CONTRACT_v1.json
tools/elderedd_identity_contract.rb
tests/test_elderedd_identity_contract.rb
spec/self_hosting/BASIC_SHARP_README_CURRENT_RELEASE_TRUTH_v1.json
compiler/readme_current_release_truth.rb
tools/readme_current_release_truth.rb
tests/test_readme_current_release_truth.rb
spec/governance/BASIC_SHARP_ELDEREDD_PATH_BRIDGE_CONTRACT_v1.json
tools/elderedd_path_bridge_contract.rb
tests/test_elderedd_path_bridge_contract.rb
spec/governance/BASIC_SHARP_UTF8_SOURCE_READING_CONTRACT_v1.json
tools/utf8_source_reading_contract.rb
tests/test_utf8_source_reading_contract.rb
spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_BSBC_EXECUTION_PARITY_v1.json
compiler/small_compiler_subset_bsbc_execution_parity.rb
tools/small_compiler_subset_bsbc_execution_parity.rb
tests/test_small_compiler_subset_bsbc_execution_parity.rb
spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_EXECUTION_CORPUS_v1.json
compiler/small_compiler_subset_execution_corpus.rb
tools/small_compiler_subset_execution_corpus.rb
tests/test_small_compiler_subset_execution_corpus.rb
spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_SEMANTIC_RESOLVER_v1.json
compiler/small_compiler_subset_semantic_resolver.rb
tools/small_compiler_subset_semantic_resolver.rb
tests/test_small_compiler_subset_semantic_resolver.rb
spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_BSBC_EMITTER_INDEPENDENCE_v1.json
compiler/small_compiler_subset_bsbc_encoder.rb
spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_BSBC_EMITTER_INDEPENDENCE_v1.json
docs/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_BSBC_EMITTER_INDEPENDENCE_v0_1_75.md
compiler/small_compiler_subset_bsbc_encoder.rb
tools/small_compiler_subset_bsbc_emitter_independence.rb
tests/test_small_compiler_subset_bsbc_emitter_independence.rb
spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_BSBC_LOADER_INDEPENDENCE_v1.json
docs/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_BSBC_LOADER_INDEPENDENCE_v0_1_76.md
compiler/small_compiler_subset_bsbc_loader.rb
tools/small_compiler_subset_bsbc_loader_independence.rb
tests/test_small_compiler_subset_bsbc_loader_independence.rb
spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_BSBC_VM_INDEPENDENCE_v1.json
docs/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_BSBC_VM_INDEPENDENCE_v0_1_77.md
compiler/small_compiler_subset_bsbc_virtual_machine.rb
tools/small_compiler_subset_bsbc_vm_independence.rb
tests/test_small_compiler_subset_bsbc_vm_independence.rb
spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_PIPELINE_INDEPENDENCE_v1.json
docs/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_PIPELINE_INDEPENDENCE_v0_1_78.md
compiler/small_compiler_subset_pipeline.rb
tools/small_compiler_subset_pipeline_independence.rb
tests/test_small_compiler_subset_pipeline_independence.rb
```

## Self-hosting runway records

```text
spec/self_hosting/BASIC_SHARP_SELF_HOSTING_SUBSET_v1.json
spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_SEMANTIC_RESOLVER_v1.json
spec/self_hosting/BASIC_SHARP_TOKENIZER_READER_CONTRACT_v1.json
docs/self_hosting/BASIC_SHARP_TOKENIZER_READER_CONTRACT_v0_1_47.md
compiler/tokenizer_reader.rb
spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_PARSER_v1.json
docs/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_PARSER_v0_1_49.md
compiler/small_compiler_subset_parser.rb
spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_IR_EMITTER_v1.json
docs/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_IR_EMITTER_v0_1_50.md
compiler/small_compiler_subset_ir_emitter.rb
spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_SEMANTIC_RESOLVER_v1.json
docs/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_SEMANTIC_RESOLVER_v0_1_74.md
compiler/small_compiler_subset_semantic_resolver.rb
spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_IR_PARITY_HARNESS_v1.json
spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_ERROR_CONTRACT_v1.json
spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_SCENE_BLOCK_EXPANSION_v1.json
spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_SYMBOL_TABLE_CONTRACT_v1.json
spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_BSBC_EMITTER_v1.json
spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_BSBC_EMITTER_INDEPENDENCE_v1.json
docs/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_BSBC_EMITTER_INDEPENDENCE_v0_1_75.md
compiler/small_compiler_subset_bsbc_encoder.rb
spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_BSBC_PARITY_HARNESS_v1.json
spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_BSBC_EXECUTION_PARITY_v1.json
spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_PIPELINE_INDEPENDENCE_v1.json
spec/self_hosting/BASIC_SHARP_SELF_HOSTING_FIXTURE_CORPUS_v1.json
spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_RUNTIME_SMOKE_v1.json
spec/self_hosting/BASIC_SHARP_BOOTSTRAP_BOUNDARY_AUDIT_v1.json
spec/self_hosting/BASIC_SHARP_README_CURRENT_RELEASE_TRUTH_v1.json
spec/self_hosting/BASIC_SHARP_SELF_HOSTING_MILESTONE_1_v1.json
docs/self_hosting/BASIC_SHARP_SELF_HOSTING_MILESTONE_2_PROPOSAL_v0_1_72.md
```

## What Milestone 1 means

```text
Allowed claim:
BSharp Compiler Subset 0 has a sealed reader, parser, IR emitter, BSBC emitter,
fixture corpus, parity harnesses, runtime smoke lane, bootstrap boundary audit,
and milestone gate under Ruby referee control.

Forbidden claim:
BASIC# is fully self-hosted or Ruby has been retired.
```

## What the Milestone 2 proposal means

```text
Allowed claim:
v0.1.72 proposes the next self-hosting expansion direction and identifies the
records that must be repaired before implementation.

Forbidden claim:
v0.1.72 does not implement Self-Hosting Milestone 2, does not make BASIC#
self-hosted, and does not retire Ruby.
```

## Current runtime path

```text
.bsharp source -> Ruby bootstrap parser/resolver -> BSharp IR -> BSharp Bytecode -> validated BSharp VM
```

## Main commands

```bash
ruby compiler/basic_sharp.rb samples/text_values.bsharp --run "player sounds brass bell"
ruby compiler/basic_sharp.rb samples/text_values.bsharp --verify-runtime-parity --run "player sounds brass bell"
ruby compiler/basic_sharp.rb samples/text_values.bsbc --disassemble-bytecode
ruby tools/release_forensic_overlay.rb
ruby tools/release_package_preflight.rb
ruby tools/deterministic_fixture_hash_sweep.rb
ruby tools/elderedd_identity_contract.rb
ruby tools/elderedd_path_bridge_contract.rb
ruby tools/utf8_source_reading_contract.rb
ruby tools/readme_current_release_truth.rb
ruby tools/tokenizer_reader_contract.rb
ruby tools/small_compiler_subset_parser.rb
ruby tools/small_compiler_subset_ir_emitter.rb
ruby tools/small_compiler_subset_semantic_resolver.rb
ruby tools/small_compiler_subset_ir_parity_harness.rb
ruby tools/small_compiler_subset_bsbc_emitter.rb
ruby tools/small_compiler_subset_bsbc_loader_independence.rb
ruby tools/small_compiler_subset_bsbc_vm_independence.rb
ruby tools/small_compiler_subset_bsbc_parity_harness.rb
ruby tools/small_compiler_subset_bsbc_execution_parity.rb
ruby tools/self_hosting_fixture_corpus.rb
ruby tools/small_compiler_subset_runtime_smoke.rb
ruby tools/bootstrap_boundary_audit.rb
ruby tools/self_hosting_milestone_1.rb
ruby tools/self_hosting_contract.rb
ruby tools/input_device_contract.rb
ruby tools/trial_by_fire_gauntlet.rb
```

## Universal standard doctrine

```text
Compatibility before conquest.
Validation before replacement.
Performance before hype.
Creator clarity before programmer tradition.
```

## Canonical records

```text
docs/company_bible/BASIC_SHARP_COMPANY_BIBLE.md
docs/hand_off/BASIC_SHARP_MASTER_THREAD_HANDOFF.md
docs/roadmap/BASIC_SHARP_ROADMAP.md
docs/self_hosting/BASIC_SHARP_SELF_HOSTING_MILESTONE_2_PROPOSAL_v0_1_72.md
spec/release/BASIC_SHARP_RELEASE_FORENSIC_OVERLAY_v1.json
spec/release/BASIC_SHARP_RELEASE_PACKAGE_PREFLIGHT_v1.json
spec/release/BASIC_SHARP_DETERMINISTIC_FIXTURE_HASH_SWEEP_v1.json
spec/governance/BASIC_SHARP_ELDEREDD_IDENTITY_CONTRACT_v1.json
spec/governance/BASIC_SHARP_ELDEREDD_PATH_BRIDGE_CONTRACT_v1.json
spec/governance/BASIC_SHARP_UTF8_SOURCE_READING_CONTRACT_v1.json
spec/self_hosting/BASIC_SHARP_SELF_HOSTING_SUBSET_v1.json
spec/trial_by_fire/BASIC_SHARP_TRIAL_BY_FIRE_VALIDATION_INVENTORY_v1.json
```

## Current identity

```text
Language: BASIC#
Safe technical form: BSharp / basic_sharp
Source: .bsharp
Intermediate representation: BSharp IR / BSIR
World save: BSharp Save
Inspection: BSharp ASK
Bytecode: BSharp Bytecode / BSBC / .bsbc
Preferred runtime: BSharp Virtual Machine / BSharp VM
Reference oracle: BasicSharp::Runtime
Meaning profiles: bsharp.meaning.v1 through bsharp.meaning.v7
Bytecode profiles: bsharp.bytecode.v1 through bsharp.bytecode.v7
Self-hosting contract: BSharp Compiler Subset 0
Current self-hosting milestone: v0.1.78 Self-Hosting Milestone 2 Slice 5 under Ruby referee control
Current build: v0.1.78 Self-Hosting Milestone 2 Slice 5 Integrated Independent Compiler Pipeline
Parent company: Elderedd Softworks LLC
Laboratory: Elderedd Laboratory
Internal shorthand: ELDL
Service layer: BCS, BSharp Creator Services
DKLab status: retired active identity; allowed only as compatibility, rollback, migration, or archival history
Canonical future path: ~/Elderedd/Projects/BASIC#
Legacy compatibility path: ~/DKLab/Projects/BASIC#
UTF-8 source reading: hardened and validated under minimal/no-locale Ruby
Release hardening: forensic overlay, package preflight, and deterministic fixture sweep active
Version: 0.1.72
```

## v0.1.72 release hardening note

v0.1.72 records Derek's release closeout rule: the installer and full native validation must prove the build before acceptance; the accepted snapshot comes before local Git commit/tag; GitHub closeout comes after local acceptance; and future assistants must follow the proven project transcript instead of guessing at SSH keys, HTTPS password prompts, or giant token blocks.
