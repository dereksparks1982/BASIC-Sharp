# BASIC# Ruby Bootstrap Compiler v0.1.68

> A scripting language made for non-programmers, by non-programmers.

BASIC# v0.1.68 adds plain-English input action mapping while preserving 2D and 3D movement intent, BSBC execution, and runtime behaviour proof while release gates check deterministic fixture hashes, sealed inventory byte counts, package payload hashes, and changed-file scope before acceptance testing.

This continues the Elderedd identity migration while preserving the DKLab compatibility layer as a retired bridge for old commands, rollback support, and migration history.

Elderedd Softworks LLC is the parent company identity, Elderedd Laboratory is the active research/build laboratory, ELDL is internal shorthand only, and BCS means BSharp Creator Services. DKLab is retired as active identity and may appear only as retired history, compatibility bridge wording, rollback support, or archival evidence.

The release package preflight gate verifies the manifest, package identity, installer identity, changed-file scope, payload byte counts, payload SHA-256 values, and validation-inventory inclusion for the new release-hardening tools.

The deterministic fixture hash sweep gate runs the full version-sensitive fixture family together, including text values, number changes, compound IF, OTHERWISE, and BSBC execution parity. This blocks single-goblin repairs where one stale hash is fixed while another is left behind.

The expanded BSBC execution parity lane extends the Self-Hosting Milestone 1 foundation into a larger sealed execution corpus with stronger runtime behaviour proof by showing more small compiler subset programs can travel from source to BSharp IR to BSBC bytes, execute inside the BSharp Virtual Machine, and match the Ruby referee runtime for event results, final snapshots, and BSharp Save documents.

v0.1.68 teaches declared player actions such as jump, attack, interact, and pause. Keyboard, mouse, PS5, Xbox, and generic gamepad inputs can now emit the same engine-neutral `input_action` command underneath the creator-facing meaning. It preserves the v0.1.67 proof that 2D and 3D movement intent are separate, that W can mean forward in 3D contexts, and that the BSBC execution corpus remains sealed at 17 fixtures and 55 event executions.

v0.1.68 preserves `move_3d` for 3D world movement and adds action mapping so physical devices can trigger the same plain-English game action without separate BASIC# scripts.

The README Current Release Truth Gate remains active so the public-facing README cannot drift away from the current accepted build.

The Elderedd path direction, UTF-8 source reading, minimal/no-locale Ruby validation, and roadmap discipline remain active carry-forward gates from v0.1.63.

This is not full self-hosting. Ruby remains the bootstrap compiler, production parser authority, production resolver authority, runtime authority, and reference referee. v0.1.68 does not retire Ruby, does not add Profile 8, does not change production runtime behaviour, does not remove the DKLab compatibility bridge, and does not rename bytecode or BSBC.

## v0.1.68 active gates

```text
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
```

## Self-hosting runway records

```text
spec/self_hosting/BASIC_SHARP_SELF_HOSTING_SUBSET_v1.json
spec/self_hosting/BASIC_SHARP_TOKENIZER_READER_CONTRACT_v1.json
docs/self_hosting/BASIC_SHARP_TOKENIZER_READER_CONTRACT_v0_1_47.md
compiler/tokenizer_reader.rb
spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_PARSER_v1.json
docs/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_PARSER_v0_1_49.md
compiler/small_compiler_subset_parser.rb
spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_IR_EMITTER_v1.json
docs/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_IR_EMITTER_v0_1_50.md
compiler/small_compiler_subset_ir_emitter.rb
spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_IR_PARITY_HARNESS_v1.json
spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_ERROR_CONTRACT_v1.json
spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_SCENE_BLOCK_EXPANSION_v1.json
spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_SYMBOL_TABLE_CONTRACT_v1.json
spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_BSBC_EMITTER_v1.json
spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_BSBC_PARITY_HARNESS_v1.json
spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_BSBC_EXECUTION_PARITY_v1.json
spec/self_hosting/BASIC_SHARP_SELF_HOSTING_FIXTURE_CORPUS_v1.json
spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_RUNTIME_SMOKE_v1.json
spec/self_hosting/BASIC_SHARP_BOOTSTRAP_BOUNDARY_AUDIT_v1.json
spec/self_hosting/BASIC_SHARP_README_CURRENT_RELEASE_TRUTH_v1.json
spec/self_hosting/BASIC_SHARP_SELF_HOSTING_MILESTONE_1_v1.json
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

## Current runtime path

```text
.bsharp source -> Ruby bootstrap parser/resolver -> BSharp IR -> BSharp Bytecode -> validated BSharp VM
```

## Main commands

```bash
ruby compiler/basic_sharp.rb samples/text_values.bsharp --run "player sounds brass bell"
ruby compiler/basic_sharp.rb samples/text_values.bsharp --verify-runtime-parity --run "player sounds brass bell"
ruby compiler/basic_sharp.rb samples/text_values.bsbc --disassemble-bytecode
ruby tools/release_package_preflight.rb
ruby tools/deterministic_fixture_hash_sweep.rb
ruby tools/elderedd_identity_contract.rb
ruby tools/elderedd_path_bridge_contract.rb
ruby tools/utf8_source_reading_contract.rb
ruby tools/readme_current_release_truth.rb
ruby tools/tokenizer_reader_contract.rb
ruby tools/small_compiler_subset_parser.rb
ruby tools/small_compiler_subset_ir_emitter.rb
ruby tools/small_compiler_subset_ir_parity_harness.rb
ruby tools/small_compiler_subset_bsbc_emitter.rb
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
Milestone: v0.1.68 Self-Hosting Milestone 1 under Ruby referee control
Parent company: Elderedd Softworks LLC
Laboratory: Elderedd Laboratory
Internal shorthand: ELDL
Service layer: BCS, BSharp Creator Services
DKLab status: retired active identity; allowed only as compatibility, rollback, migration, or archival history
Canonical future path: ~/Elderedd/Projects/BASIC#
Legacy compatibility path: ~/DKLab/Projects/BASIC#
UTF-8 source reading: hardened and validated under minimal/no-locale Ruby
Release hardening: package preflight and deterministic fixture sweep active
Version: 0.1.68
```

## v0.1.68 release hardening note

v0.1.68 records the v0.1.63 rejected-candidate lesson: where one stale deterministic hash exists, more may exist. The package must sweep the whole family and audit final payload bytes before acceptance testing.
