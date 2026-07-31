# BASIC# Ruby Bootstrap Compiler v0.1.32

> A scripting language made for non-programmers, by non-programmers.

BASIC# v0.1.32 adds creator-facing text values through the complete preferred-runtime pipeline:

```text
.bsharp source -> BSharp IR -> BSharp Bytecode -> validated BSharp VM
quoted text     -> exact UTF-8 value -> Save, ASK, restore, and parity
```

Ruby remains the bootstrap host. The BSharp VM is the preferred runtime, while `BasicSharp::Runtime` remains the protected reference oracle used by explicit diagnostic and shadow-parity modes.

## Creator-facing text values

Text is written between straight double quotes and followed by a one-word value name:

```bsharp
START
[north gate has "North Gate — CLOSED" label].

WHEN
[player sounds brass bell
<then> (change label of every gate to "OPEN — RubyVM!"].

IF
[north gate has "OPEN — RubyVM!" label
<then> (damage player by 1].
```

Text preserves UTF-8, case, punctuation, and spaces exactly. v0.1.32 does not add interpolation, concatenation, escape sequences, multiline text, arithmetic on text, or text-based event matching.

## Profile selection and compatibility

- Programs using only accepted Profile 1 meaning remain `bsharp.meaning.v1` and emit `bsharp.bytecode.v1`.
- Any creator-facing text value selects `bsharp.meaning.v2` and emits `bsharp.bytecode.v2`.
- Profile 1 source, BSIR meaning fingerprints, committed `.bsbc` bytes, and disassembly remain compatible.
- Profile 2 adds `START_TEXT_VALUE`, `CHANGE_TEXT_VALUE`, and `TEXT_VALUE_EQUALS`.
- Identifier strings remain canonical lowercase; creator text strings retain their exact spelling through role-aware validation.

## Main commands

```bash
ruby compiler/basic_sharp.rb samples/text_values.bsharp --run "player sounds brass bell"
ruby compiler/basic_sharp.rb samples/text_values.bsharp --verify-runtime-parity --run "player sounds brass bell"
ruby compiler/basic_sharp.rb samples/text_values.bsbc --disassemble-bytecode
ruby compiler/basic_sharp.rb samples/text_values.bsharp --ask "what is north gate"
```

## Validation lanes

```bash
ruby tools/meaning_conformance.rb
ruby tools/meaning_profile_2.rb
ruby tools/company_bible_audit.rb
ruby tools/bytecode_contract.rb
ruby tools/bytecode_emitter.rb
ruby tools/bytecode_loader.rb
ruby tools/bytecode_virtual_machine.rb
ruby tools/bytecode_vm_stress.rb
ruby tools/runtime_transition.rb
ruby tools/text_value_stress.rb
```

## Canonical current records

```text
docs/company_bible/BASIC_SHARP_COMPANY_BIBLE.md
docs/hand_off/BASIC_SHARP_MASTER_THREAD_HANDOFF.md
docs/roadmap/BASIC_SHARP_ROADMAP.md
docs/language/BASIC_SHARP_CREATOR_FACING_TEXT_VALUES_v0_1_32.md
docs/specification/BASIC_SHARP_STABLE_MEANING_SPECIFICATION_v2.md
docs/bytecode/BASIC_SHARP_BYTECODE_PROFILE_2_v0_1_32.md
docs/runtime_contract_v0_1_32.md
docs/validation/BASIC_SHARP_VALIDATION_v0_1_32.md
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
Meaning profiles: bsharp.meaning.v1 and bsharp.meaning.v2
Bytecode profiles: bsharp.bytecode.v1 and bsharp.bytecode.v2
Version: 0.1.32
```
