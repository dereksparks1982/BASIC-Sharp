# BASIC# Ruby Bootstrap Compiler v0.1.61

> A scripting language made for non-programmers, by non-programmers.

BASIC# v0.1.61 Self-Hosting Milestone 1 seals the first protected self-hosting foothold for BSharp Compiler Subset 0. BASIC# can now read, parse, validate, emit BSharp IR, emit BSBC, compare golden artifacts, and run selected runtime smoke checks for the sealed small compiler subset under Ruby referee control.

BASIC# v0.1.61 seals Self-Hosting Milestone 1 for BSharp Compiler Subset 0 under Ruby referee control, and adds a README Current Release Truth Gate so GitHub shows the active build instead of stale carried-forward release text.

This is not full self-hosting. Ruby remains the bootstrap compiler, production parser authority, production resolver authority, runtime authority, and reference referee. v0.1.61 does not retire Ruby, does not add Profile 8, does not change production runtime behaviour, and does not rename bytecode or BSBC.

## v0.1.61 active gates

```text
spec/self_hosting/BASIC_SHARP_SELF_HOSTING_MILESTONE_1_v1.json
compiler/self_hosting_milestone_1.rb
tools/self_hosting_milestone_1.rb
tests/test_self_hosting_milestone_1.rb
spec/self_hosting/BASIC_SHARP_README_CURRENT_RELEASE_TRUTH_v1.json
compiler/readme_current_release_truth.rb
tools/readme_current_release_truth.rb
tests/test_readme_current_release_truth.rb
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
ruby tools/readme_current_release_truth.rb
ruby tools/tokenizer_reader_contract.rb
ruby tools/small_compiler_subset_parser.rb
ruby tools/small_compiler_subset_ir_emitter.rb
ruby tools/small_compiler_subset_ir_parity_harness.rb
ruby tools/small_compiler_subset_bsbc_emitter.rb
ruby tools/small_compiler_subset_bsbc_parity_harness.rb
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
Milestone: v0.1.61 Self-Hosting Milestone 1 under Ruby referee control
Input contract: keyboard, mouse/keyboard, PS5, Xbox, generic gamepad
Company: Elderred Softworks LLC
Internal workspace/lab: DKLab, retained as homage to Demon Killer
Version: 0.1.61
```
