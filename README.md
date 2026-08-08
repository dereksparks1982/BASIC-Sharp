# BASIC# Ruby Bootstrap Compiler v0.1.50

> A scripting language made for non-programmers, by non-programmers.

BASIC# v0.1.50 adds the first **small compiler subset BSharp IR emitter** while preserving all accepted Profiles 1 through 7, BSharp Bytecode Profiles 1 through 7, the BSharp VM preferred runtime, the v0.1.46 movement/input layer, the v0.1.47 tokenizer/reader contract, the v0.1.48 tokenizer/reader implementation, and the v0.1.49 small compiler subset parser.

Ruby remains the bootstrap compiler, production parser authority, production resolver authority, and reference referee. v0.1.50 adds `compiler/small_compiler_subset_ir_emitter.rb` beside the existing compiler path and proves subset-emitted BSharp IR against the Ruby Parser plus SemanticResolver referee before any future compiler migration.

## Self-hosting runway records

```text
spec/self_hosting/BASIC_SHARP_TOKENIZER_READER_CONTRACT_v1.json
docs/self_hosting/BASIC_SHARP_TOKENIZER_READER_CONTRACT_v0_1_47.md
docs/self_hosting/BASIC_SHARP_TOKENIZER_READER_IMPLEMENTATION_v0_1_48.md
compiler/tokenizer_reader.rb
spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_PARSER_v1.json
docs/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_PARSER_v0_1_49.md
compiler/small_compiler_subset_parser.rb
spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_IR_EMITTER_v1.json
docs/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_IR_EMITTER_v0_1_50.md
compiler/small_compiler_subset_ir_emitter.rb
tools/tokenizer_reader_contract.rb
tools/small_compiler_subset_parser.rb
tools/small_compiler_subset_ir_emitter.rb
tests/test_tokenizer_reader_contract.rb
tests/test_tokenizer_reader_implementation.rb
tests/test_small_compiler_subset_parser.rb
tests/test_small_compiler_subset_ir_emitter.rb
```

The v0.1.50 emitter exposes deterministic records:

```text
format: bsharp.small_compiler_subset.ir_emitter.record
version: live BASIC# version
status: ir_emitter_under_ruby_referee
parser_ruby_referee_matches: true/false
ruby_referee_matches: true/false
bsharp_ir: resolved BSharp IR document
```

`compiler/small_compiler_subset_ir_emitter.rb` is not the production compiler path. Normal BASIC# compilation still routes through `compiler/parser.rb` and `compiler/resolver.rb`.

## Universal standard doctrine

The long-term BASIC# / BSharp ambition remains recorded here:

```text
docs/strategy/BASIC_SHARP_UNIVERSAL_STANDARD_AND_AI_TOOLING_DOCTRINE_v0_1_47.md
```

The doctrine is strategic, not an implementation shortcut:

```text
Compatibility before conquest.
Validation before replacement.
Performance before hype.
Creator clarity before programmer tradition.
```

BASIC# should first export to existing standards such as HTML, CSS, JavaScript, and later WebAssembly before any BASIC#/BSharp-native browser is considered.

## Existing active contracts

The v0.1.44 self-hosting foundation remains active:

```text
docs/self_hosting/BASIC_SHARP_SELF_HOSTING_FOUNDATION_v0_1_44.md
spec/self_hosting/BASIC_SHARP_SELF_HOSTING_SUBSET_v1.json
tools/self_hosting_contract.rb
tests/test_self_hosting_contract.rb
```

The v0.1.46 input-device contract remains active:

```text
docs/language/BASIC_SHARP_PLAIN_ENGLISH_MOVEMENT_AND_INPUT_v0_1_46.md
spec/input/BASIC_SHARP_INPUT_DEVICE_MAPPING_v1.json
tools/input_device_contract.rb
tests/test_input_device_contract.rb
```

Forbidden in this build:

- replacing the Ruby bootstrap compiler;
- replacing `compiler/lexer.rb`, `compiler/parser.rb`, or `compiler/resolver.rb` as production authority;
- routing production compilation through `compiler/tokenizer_reader.rb`, `compiler/small_compiler_subset_parser.rb`, or `compiler/small_compiler_subset_ir_emitter.rb`;
- claiming BASIC# is self-hosted;
- new creator syntax;
- Profile 8;
- production runtime meaning changes, BSharp Bytecode changes, Save format changes, or ASK behavior changes;
- controller remapping UI, platform-specific driver code, engine bridge work, graphics, haptics, camera controls, web export, browser work, licensing, funding claims, or OpenAI outreach.

## Current runtime path

```text
.bsharp source -> Ruby bootstrap parser/resolver -> BSharp IR -> BSharp Bytecode -> validated BSharp VM
```

`BasicSharp::Runtime` remains the protected reference oracle for explicit diagnostics and conformance testing. Shadow parity must stop on disagreement.

## Main commands

```bash
ruby compiler/basic_sharp.rb samples/text_values.bsharp --run "player sounds brass bell"
ruby compiler/basic_sharp.rb samples/text_values.bsharp --verify-runtime-parity --run "player sounds brass bell"
ruby compiler/basic_sharp.rb samples/text_values.bsbc --disassemble-bytecode
ruby tools/tokenizer_reader_contract.rb
ruby tools/small_compiler_subset_parser.rb
ruby tools/small_compiler_subset_ir_emitter.rb
ruby tools/self_hosting_contract.rb
ruby tools/input_device_contract.rb
ruby tools/trial_by_fire_gauntlet.rb
```

## Canonical records

```text
docs/company_bible/BASIC_SHARP_COMPANY_BIBLE.md
docs/hand_off/BASIC_SHARP_MASTER_THREAD_HANDOFF.md
docs/roadmap/BASIC_SHARP_ROADMAP.md
spec/self_hosting/BASIC_SHARP_SELF_HOSTING_SUBSET_v1.json
spec/self_hosting/BASIC_SHARP_TOKENIZER_READER_CONTRACT_v1.json
spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_PARSER_v1.json
spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_IR_EMITTER_v1.json
docs/self_hosting/BASIC_SHARP_TOKENIZER_READER_CONTRACT_v0_1_47.md
docs/self_hosting/BASIC_SHARP_TOKENIZER_READER_IMPLEMENTATION_v0_1_48.md
docs/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_PARSER_v0_1_49.md
docs/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_IR_EMITTER_v0_1_50.md
docs/strategy/BASIC_SHARP_UNIVERSAL_STANDARD_AND_AI_TOOLING_DOCTRINE_v0_1_47.md
spec/input/BASIC_SHARP_INPUT_DEVICE_MAPPING_v1.json
docs/validation/BASIC_SHARP_VALIDATION_v0_1_50.md
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
Tokenizer/reader implementation: implementation under Ruby referee
Small compiler subset parser: parser under Ruby referee
Small compiler subset IR emitter: IR emitter under Ruby referee
Input contract: keyboard, mouse/keyboard, PS5, Xbox, generic gamepad
Version: 0.1.50
```

Small compiler subset IR emitter spec: `spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_IR_EMITTER_v1.json`
