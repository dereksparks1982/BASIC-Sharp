# BASIC# Ruby Bootstrap Compiler v0.1.47

> A scripting language made for non-programmers, by non-programmers.

BASIC# v0.1.47 defines the tokenizer/reader contract for the self-hosting runway while preserving all accepted Profiles 1 through 7, BSharp Bytecode Profiles 1 through 7, the BSharp VM preferred runtime, and the v0.1.46 plain-English movement/input layer.

Ruby remains the bootstrap compiler, reader authority, and reference referee. v0.1.47 is contract-only for tokenizer/reader work: it adds validation, fixtures, doctrine, and documentation without replacing lexer/parser behavior.

## Tokenizer/reader foundation

The new tokenizer/reader contract lives here:

```text
spec/self_hosting/BASIC_SHARP_TOKENIZER_READER_CONTRACT_v1.json
docs/self_hosting/BASIC_SHARP_TOKENIZER_READER_CONTRACT_v0_1_47.md
tools/tokenizer_reader_contract.rb
tests/test_tokenizer_reader_contract.rb
```

The contract freezes deterministic reader records:

```text
number = one-based source line number
raw    = comment-stripped source line without trailing newline
text   = trimmed reader text
```

It also locks current comment behavior, current Head words, future token-record shape, and the rule that any later BASIC# implementation must use the Ruby bootstrap as referee before claiming parity.

## Universal standard doctrine

v0.1.47 records the long-term BASIC# / BSharp ambition here:

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
- replacing `compiler/lexer.rb` or `compiler/parser.rb` as authority;
- claiming BASIC# is self-hosted;
- new creator syntax;
- Profile 8;
- new runtime meaning, BSharp IR, BSharp Bytecode, Save format, or ASK behavior;
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
ruby tools/self_hosting_contract.rb
ruby tools/input_device_contract.rb
ruby tools/trial_by_fire_gauntlet.rb
```

## Canonical records

```text
docs/company_bible/BASIC_SHARP_COMPANY_BIBLE.md
docs/hand_off/BASIC_SHARP_MASTER_THREAD_HANDOFF.md
docs/roadmap/BASIC_SHARP_ROADMAP.md
spec/self_hosting/BASIC_SHARP_TOKENIZER_READER_CONTRACT_v1.json
docs/self_hosting/BASIC_SHARP_TOKENIZER_READER_CONTRACT_v0_1_47.md
docs/strategy/BASIC_SHARP_UNIVERSAL_STANDARD_AND_AI_TOOLING_DOCTRINE_v0_1_47.md
spec/input/BASIC_SHARP_INPUT_DEVICE_MAPPING_v1.json
spec/self_hosting/BASIC_SHARP_SELF_HOSTING_SUBSET_v1.json
docs/validation/BASIC_SHARP_VALIDATION_v0_1_47.md
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
Tokenizer/reader contract: contract-only deterministic reader records
Input contract: keyboard, mouse/keyboard, PS5, Xbox, generic gamepad
Version: 0.1.47
```
