# BASIC# Ruby Bootstrap Compiler v0.1.37

> A scripting language made for non-programmers, by non-programmers.

BASIC# v0.1.37 adds plain-English whole-number changes and comparisons for score, health, lives, ammunition, and other creator-defined values:

```text
.bsharp source -> BSharp IR -> BSharp Bytecode -> validated BSharp VM
quoted text     -> exact UTF-8 value -> Save, ASK, restore, and parity
number words    -> Profile 5 -> atomic changes and reactive thresholds
```

Ruby remains the bootstrap host. The BSharp VM is the preferred runtime, while `BasicSharp::Runtime` remains the protected reference oracle used by explicit diagnostic and shadow-parity modes.

## Canonical visual grammar

```bsharp
KINDS
[
    #gate is a #door
].

DEFINE
[
    @north gate is a #gate
].

START
[
    PLAYER has 3 speed
    @north gate has "North Gate — CLOSED" label
].

WHEN PLAYER opens @north gate
[
    |then (change it to open
].
```

Comments begin with `//` and end with `/.`; `[` opens every Body and `].` closes it.

## Plain-English platform movement

```bsharp
CONTROLS for PLAYER
[
    A moves PLAYER left at 6 speed
    D moves PLAYER right at 6 speed
    SPACE makes PLAYER jump at 10 speed
].
```

The host supplies frame time and collision facts. BASIC# emits one deterministic `move_with_collisions` command per frame, cancels opposing directions, applies built-in gravity, allows one grounded jump per keypress, and responds to landings, walls, and ceilings.

## Plain-English number changes and comparisons

```bsharp
WHEN PLAYER takes @gold coin
[
    |then (increase score of PLAYER by 10
].

WHEN PLAYER attacks @spikes
[
    |then (decrease health of PLAYER by 3
].

IF PLAYER has at least 100 score
[
    |then (change PLAYER to friendly
].
```

`increase` and `decrease` work on existing whole-number values. Overflow, underflow, missing values, and type mismatches stop the entire action before anything changes. Threshold conditions support `at least`, `more than`, `at most`, and `less than`; existing exact equality remains unchanged.

## Profile selection and compatibility

- Programs using only accepted Profile 1 meaning remain `bsharp.meaning.v1` and emit `bsharp.bytecode.v1`.
- Any creator-facing text value selects `bsharp.meaning.v2` and emits `bsharp.bytecode.v2`.
- Controls, hover, or context declarations select `bsharp.meaning.v3` and emit `bsharp.bytecode.v3`.
- Platform left/right/jump declarations select `bsharp.meaning.v4` and emit `bsharp.bytecode.v4`.
- Number increase/decrease actions or threshold comparisons select `bsharp.meaning.v5` and emit `bsharp.bytecode.v5`.
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
ruby tools/meaning_profile_3.rb
ruby tools/meaning_profile_4.rb
ruby tools/meaning_profile_5.rb
ruby tools/company_bible_audit.rb
ruby tools/bytecode_contract.rb
ruby tools/bytecode_emitter.rb
ruby tools/bytecode_loader.rb
ruby tools/bytecode_virtual_machine.rb
ruby tools/bytecode_vm_stress.rb
ruby tools/runtime_transition.rb
ruby tools/text_value_stress.rb
ruby tools/bytecode_profile_4.rb
ruby tools/platform_movement_stress.rb
ruby tools/bytecode_profile_5.rb
ruby tools/number_change_stress.rb
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
docs/language/BASIC_SHARP_COMMENT_SYNTAX_v0_1_33.md
docs/language/BASIC_SHARP_DEMON_KILLER_CONTROLS_HOVER_AND_CONTEXT_v0_1_33.md
docs/bytecode/BASIC_SHARP_BYTECODE_PROFILE_3_v0_1_33.md
docs/language/BASIC_SHARP_PLAIN_ENGLISH_PLATFORM_MOVEMENT_v0_1_36.md
docs/bytecode/BASIC_SHARP_BYTECODE_PROFILE_4_v0_1_36.md
docs/language/BASIC_SHARP_PLAIN_ENGLISH_NUMBER_CHANGES_AND_COMPARISONS_v0_1_37.md
docs/bytecode/BASIC_SHARP_BYTECODE_PROFILE_5_v0_1_37.md
docs/validation/BASIC_SHARP_VALIDATION_v0_1_37.md
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
Meaning profiles: bsharp.meaning.v1 through bsharp.meaning.v5
Bytecode profiles: bsharp.bytecode.v1 through bsharp.bytecode.v5
Version: 0.1.37
```
