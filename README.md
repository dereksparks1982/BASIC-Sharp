# BASIC# Ruby Bootstrap Compiler v0.1.59

> A scripting language made for non-programmers, by non-programmers.

BASIC# v0.1.59 adds the first **small compiler subset IR golden parity harness** while preserving all accepted Profiles 1 through 7, BSharp Bytecode Profiles 1 through 7, the BSharp VM preferred runtime, the movement/input layer, the tokenizer/reader path, the small compiler subset parser, and the small compiler subset IR emitter.

Ruby remains the bootstrap compiler, production parser authority, production resolver authority, and reference referee. v0.1.59 adds `compiler/small_compiler_subset_ir_parity_harness.rb` beside the existing compiler path and proves locked golden BSharp IR digests against the Ruby Parser plus SemanticResolver referee before any future bytecode-emission migration.

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

The v0.1.59 emitter exposes deterministic records:

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
Version: 0.1.59
```

Small compiler subset IR emitter spec: `spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_IR_EMITTER_v1.json`

### v0.1.59 self-hosting bridge

- `spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_IR_PARITY_HARNESS_v1.json`
- `docs/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_IR_PARITY_HARNESS_v0_1_52.md`
- `compiler/small_compiler_subset_ir_parity_harness.rb`
- `tools/small_compiler_subset_ir_parity_harness.rb`

v0.1.59 locks golden BSharp IR parity digests for the small compiler subset. It is not the production compiler path and does not claim BASIC# is self-hosted.

### v0.1.59 self-hosting bridge

- `spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_ERROR_CONTRACT_v1.json`
- `docs/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_ERROR_CONTRACT_v0_1_52.md`
- `compiler/small_compiler_subset_error_contract.rb`
- `tools/small_compiler_subset_error_contract.rb`

v0.1.59 locks stable, plain-English, creator-facing errors for invalid small compiler subset examples. It is not the production compiler path and does not claim BASIC# is self-hosted.


## Documentation front door

Start with:

1. `README.md`
2. `docs/hand_off/BASIC_SHARP_MASTER_THREAD_HANDOFF.md`
3. `docs/roadmap/BASIC_SHARP_ROADMAP.md`
4. `docs/BASIC_SHARP_DOCUMENTATION_MAP.md`
5. `docs/company_bible/BASIC_SHARP_COMPANY_BIBLE.md`

The Company Bible now preserves the BASIC# Five Point Paradigm: Huge Human Problem, Radical Human Bridge, Breakthrough Machine, Proof Under Fire, and Creator Ownership. The centre statement is: turn human intent into real software behaviour.


### v0.1.59 scene/block expansion

- `spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_SCENE_BLOCK_EXPANSION_v1.json`
- `compiler/small_compiler_subset_scene_block_expansion.rb`
- `tools/small_compiler_subset_scene_block_expansion.rb`
- `tests/test_small_compiler_subset_scene_block_expansion.rb`
- `docs/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_SCENE_BLOCK_EXPANSION_v0_1_53.md`

v0.1.59 expands the sealed small compiler subset to larger ordered scene/block fixtures while preserving Ruby as production parser, resolver, compiler path, and referee.


Symbol table contract spec: `spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_SYMBOL_TABLE_CONTRACT_v1.json`.


ByteTide decision record: the name was considered as a creator-facing metaphor for bytecode flow, then passed on for now. Official system terms remain bytecode and BSBC.

Reference: `docs/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_SYMBOL_TABLE_CONTRACT_v0_1_54.md`.


### v0.1.59 small compiler subset BSBC emission

BASIC# v0.1.59 adds the first small compiler subset lane that emits real BSBC bytecode under Ruby referee control. It proves source -> BSharp IR -> BSBC bytes -> bytecode loader for sealed fixtures without replacing Ruby and without claiming BASIC# is self-hosted.

Reference: `spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_BSBC_EMITTER_v1.json`.
Reference: `docs/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_BSBC_EMITTER_v0_1_55.md`.


### v0.1.59 small compiler subset BSBC golden parity

BASIC# v0.1.59 adds the BSBC Golden Parity Harness under Ruby referee control. It locks approved subset source -> BSharp IR -> BSBC bytes -> bytecode loader summaries against sealed golden expectations without replacing Ruby and without claiming BASIC# is self-hosted.

Reference: `spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_BSBC_PARITY_HARNESS_v1.json`.
Reference: `docs/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_BSBC_PARITY_HARNESS_v0_1_56.md`.


## v0.1.59 Self-Hosting Fixture Corpus

- Spec: `spec/self_hosting/BASIC_SHARP_SELF_HOSTING_FIXTURE_CORPUS_v1.json`
- Doc: `docs/self_hosting/BASIC_SHARP_SELF_HOSTING_FIXTURE_CORPUS_v0_1_57.md`
- Implementation: `compiler/self_hosting_fixture_corpus.rb`
- Tool: `tools/self_hosting_fixture_corpus.rb`
- Test: `tests/test_self_hosting_fixture_corpus.rb`
- DKLab is retained as the internal workspace and lab name in homage to Demon Killer. Elderred Softworks LLC remains the official company identity.
- v0.1.59 adds Small Compiler Subset Runtime Smoke so selected fixture corpus programs can enter the verifying runtime, run smoke events, snapshot, and save under Ruby referee control.


- v0.1.59 adds the Bootstrap Boundary Audit so the project records exactly where Ruby remains referee, where BASIC# subset artifacts participate, and which boundaries must stay locked before v0.1.60.
