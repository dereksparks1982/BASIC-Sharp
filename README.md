# BASIC# Ruby Bootstrap Compiler v0.1.84

BASIC# v0.1.84 adds Self-Hosting Milestone 2 Slice 11: Native Action Routing Integration.


v0.1.84 moves another bounded compiler decision out of Ruby: accepted official action words are now classified into damage, change, number-change, cause, object-interaction, or generic resolver families by checked-in BASIC# BSBC through `compiler/small_compiler_subset_native_action_routing.rb` and `compiler/native/first_bsharp_action_router.bsharp`. v0.1.81 parser dispatch, v0.1.82 semantic routing, and v0.1.83 symbol resolution remain active upstream. This preserves Self-Hosting Milestone 2 Slice 10 Native Symbol Resolution Integration as the accepted upstream symbol boundary. Contradictory native action routing fails closed rather than falling back to a Ruby verb-family table. Ruby remains the bootstrap compiler and separate referee authority; this is active bounded self-hosting progress, not full self-hosting.

v0.1.83 moves BASIC#-authored compiler authority into bounded symbol resolution by requiring checked-in BASIC# BSBC decisions for Kind, Thing, PLAYER, action, value, duplicate, unknown, and Kind-link observations while v0.1.81 native parser dispatch and v0.1.82 native semantic routing remain active upstream. Self-Hosting Milestone 2 Slice 8 remains the accepted Native Parser Dispatch Integration, and Self-Hosting Milestone 2 Slice 9 remains the accepted Native Semantic Routing Integration.

The current symbol decisions explicitly cover Kind identity, Thing identity, action identities, and value identities.

The active path keeps `compiler/small_compiler_subset_native_dispatch.rb`, `compiler/native/first_bsharp_compiler_component.bsharp`, `compiler/small_compiler_subset_native_semantic_routing.rb`, and `compiler/native/first_bsharp_semantic_router.bsharp`, then adds `compiler/small_compiler_subset_native_symbol_resolution.rb` backed by `compiler/native/first_bsharp_symbol_resolver.bsharp`. The BASIC# symbol component uses fifteen bounded probe decisions and is checked in as `.bsharp`, `.bsbc`, and readable disassembly evidence. The existing nine accepted compiler block heads and eight accepted semantic families remain protected upstream.

`SmallCompilerSubsetDriver`, `SmallCompilerSubsetPipeline`, `SmallCompilerSubsetSymbolTableContract`, and `SmallCompilerSubsetSemanticResolver` expose native activity while `SmallCompilerSubsetBSBCLoader` and `SmallCompilerSubsetBSBCVirtualMachine` remain independent execution machinery. The native symbol boundary accepts neutral lookup observations such as whether a dictionary contains a Kind or Thing from Ruby bootstrap plumbing, but the bounded accept/reject symbol decision comes from BASIC# bytecode. There is no hidden Ruby decision fallback. The production `Lexer`, production `Parser`, production `SemanticResolver`, production `BytecodeEmitter`, production compiler constructors, and Ruby Runtime remain unavailable on the primary integration proof path and remain separate referee authority. Ruby remains the bootstrap compiler. This is active bounded self-hosting progress, not full self-hosting.

The symbol integration is fail-closed. The prior wrong-route sabotage for semantic routing remains independently protected. Validation observes the native symbol invocation count and requires wrong-known-symbol sabotage, wrong-unknown-symbol sabotage, duplicate-symbol sabotage, and wrong-Kind-link sabotage to fail visibly. It also verifies builtin PLAYER, action, and value decisions. The v0.1.81 native dispatch invocation count and v0.1.82 native semantic invocation count remain independently tested. A controlled bootstrap fence compiles the v0.1.83 symbol component as generation #1 from the accepted v0.1.82 machinery, recompiles it through the v0.1.83 machinery as generation #2, and requires byte-identical output.

No new creator-facing syntax is introduced. Profiles 1 through 7 remain sealed, there is no Profile 8, and creator-facing BASIC# meaning is unchanged.

Current release truth remains under Elderedd Softworks LLC and Elderedd Laboratory. The Elderedd identity migration remains active, with the DKLab compatibility layer retained only for compatibility, rollback, migration, and historical path support. BCS means BSharp Creator Services and remains future service work rather than part of this build. The Company Bible header version remains machine-checked against `BasicSharp::VERSION`.

Release hardening remains active: Elderedd path direction, UTF-8 source reading, minimal/no-locale Ruby validation, release package preflight, deterministic fixture hash sweep, payload SHA-256 checks, changed-file scope checks, release forensic overlay, pre-mutation forensic overlay, and the sealed validation inventory must report all mismatches together. The whole-language test gauntlet remains at 128,000 event paths, 128,000 platform frames, 384 generated programs, and 3,072 mutations.

## v0.1.84 active gates

```text
spec/self_hosting/BASIC_SHARP_NATIVE_ACTION_ROUTING_INTEGRATION_v1.json
compiler/small_compiler_subset_native_action_routing.rb
compiler/native/first_bsharp_action_router.bsharp
compiler/native/first_bsharp_action_router.bsbc
compiler/native/first_bsharp_action_router.bsbc.txt
docs/self_hosting/BASIC_SHARP_NATIVE_ACTION_ROUTING_INTEGRATION_v0_1_84.md
tools/native_action_routing_integration.rb
tests/test_native_action_routing_integration.rb
```

## v0.1.83 active gates

```text
spec/self_hosting/BASIC_SHARP_NATIVE_SYMBOL_RESOLUTION_INTEGRATION_v1.json
compiler/small_compiler_subset_native_symbol_resolution.rb
compiler/native/first_bsharp_symbol_resolver.bsharp
compiler/native/first_bsharp_symbol_resolver.bsbc
compiler/native/first_bsharp_symbol_resolver.bsbc.txt
docs/self_hosting/BASIC_SHARP_NATIVE_SYMBOL_RESOLUTION_INTEGRATION_v0_1_83.md
tools/native_symbol_resolution_integration.rb
tests/test_native_symbol_resolution_integration.rb
spec/self_hosting/BASIC_SHARP_NATIVE_SEMANTIC_ROUTING_INTEGRATION_v1.json
compiler/small_compiler_subset_native_semantic_routing.rb
compiler/native/first_bsharp_semantic_router.bsharp
compiler/native/first_bsharp_semantic_router.bsbc
compiler/native/first_bsharp_semantic_router.bsbc.txt
docs/self_hosting/BASIC_SHARP_NATIVE_SEMANTIC_ROUTING_INTEGRATION_v0_1_82.md
tools/native_semantic_routing_integration.rb
tests/test_native_semantic_routing_integration.rb
spec/self_hosting/BASIC_SHARP_NATIVE_PARSER_DISPATCH_INTEGRATION_v1.json
compiler/small_compiler_subset_native_dispatch.rb
docs/self_hosting/BASIC_SHARP_NATIVE_PARSER_DISPATCH_INTEGRATION_v0_1_81.md
tools/native_parser_dispatch_integration.rb
tests/test_native_parser_dispatch_integration.rb
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
spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_DRIVER_INDEPENDENCE_v1.json
docs/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_DRIVER_INDEPENDENCE_v0_1_79.md
compiler/small_compiler_subset_driver.rb
tools/small_compiler_subset_driver_independence.rb
tests/test_small_compiler_subset_driver_independence.rb
spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_ARTIFACT_ROUND_TRIP_v1.json
tools/small_compiler_subset_artifact_round_trip.rb
tests/test_small_compiler_subset_artifact_round_trip.rb
spec/self_hosting/BASIC_SHARP_FIRST_NATIVE_COMPILER_COMPONENT_v1.json
compiler/native/first_bsharp_compiler_component.bsharp
compiler/native/first_bsharp_compiler_component.bsbc
compiler/native/first_bsharp_compiler_component.bsbc.txt
docs/self_hosting/BASIC_SHARP_FIRST_NATIVE_COMPILER_COMPONENT_v0_1_80.md
tools/first_native_compiler_component.rb
tests/test_first_native_compiler_component.rb
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
spec/self_hosting/BASIC_SHARP_FIRST_NATIVE_COMPILER_COMPONENT_v1.json
compiler/native/first_bsharp_compiler_component.bsharp
compiler/native/first_bsharp_compiler_component.bsbc
docs/self_hosting/BASIC_SHARP_FIRST_NATIVE_COMPILER_COMPONENT_v0_1_80.md
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
ruby tools/first_native_compiler_component.rb
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
Current self-hosting milestone: v0.1.84 Self-Hosting Milestone 2 Slice 11 under Ruby referee control
Current build: v0.1.84 Self-Hosting Milestone 2 Slice 11 Native Action Routing Integration
Parent company: Elderedd Softworks LLC
Laboratory: Elderedd Laboratory
Internal shorthand: ELDL
Service layer: BCS, BSharp Creator Services
DKLab status: retired active identity; allowed only as compatibility, rollback, migration, or archival history
Canonical future path: ~/Elderedd/Projects/BASIC#
Legacy compatibility path: ~/DKLab/Projects/BASIC#
UTF-8 source reading: hardened and validated under minimal/no-locale Ruby
Release hardening: forensic overlay, package preflight, and deterministic fixture sweep active
Version: 0.1.84
```

## v0.1.72 release hardening note

v0.1.72 records Derek's release closeout rule: the installer and full native validation must prove the build before acceptance; the accepted snapshot comes before local Git commit/tag; GitHub closeout comes after local acceptance; and future assistants must follow the proven project transcript instead of guessing at SSH keys, HTTPS password prompts, or giant token blocks.
