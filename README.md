# BASIC# Ruby Bootstrap Compiler v0.1.42

> A scripting language made for non-programmers, by non-programmers.

BASIC# v0.1.42 completely re-carries the failed v0.1.40 and v0.1.41 Trial-by-Fire work, repairs the complete known set of version-bearing runtime fixtures, and adds no creator-facing word. Trial by Fire attacks everything already accepted in Profiles 1–7 and hardens the BSharp VM boundary:

```text
.bsharp source -> BSharp IR -> BSharp Bytecode -> validated BSharp VM
fixed campaign -> independently locked trace -> source/BSIR/VM verification
seeded programs + hostile artifacts -> deterministic rejection and parity
```

Ruby remains the bootstrap host. The BSharp VM is the preferred runtime, while `BasicSharp::Runtime` remains the protected reference oracle used by explicit diagnostic and shadow-parity modes.

## Trial by Fire

The v0.1.40 native installer passed 448 tests and 8,012 assertions plus every earlier phase, then correctly stopped at `tools/text_value_stress.rb` because its package omitted the version-owned Save fixture update. Automatic rollback restored exact v0.1.39.

v0.1.41 repaired that gate and passed it, but later stopped at `tools/number_change_stress.rb`. The same audit found stale version stamps in number-change, compound-IF, and OTHERWISE expected results. Its installer again restored exact v0.1.39. v0.1.42 regenerates all four version-sensitive fixtures together and adds a canonical Company Bible rule requiring this complete audit before future packages are sealed.

The principal `samples/trial_by_fire.bsharp` program combines Kind ancestry, large selections, states, relationships, whole numbers, exact text, exact and inherited events, follow-ups, reactive IF/OTHERWISE rules, controls, platform movement declarations, ASK, and Save/restore. Its expected campaign is locked independently in `spec/trial_by_fire/BASIC_SHARP_TRIAL_BY_FIRE_GOLDEN_TRACE_v1.json`.

The native gauntlet defaults to 100,000 events on every execution path, 100,000 movement frames, 25,000 read-only ASK questions, 1,000 Save/restore checkpoints, 256 simultaneous worlds, all follow-up boundaries around 1,024, 256 seeded programs, 2,048 mutations at each of four artifact boundaries, and every truncated prefix of the principal BSBC. The same seed must reproduce byte-identical source, BSIR, BSBC, disassembly, and final hashes.

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

## Plain-English compound IF conditions

```bsharp
IF PLAYER has at least 100 score and @boss is defeated
[
    |then (change @exit gate to unlocked
].

IF PLAYER has less than 1 health or @bridge is broken
[
    |then (change PLAYER to defeated
].
```

`and` requires every clause; `or` requires at least one. The complete result wakes once on false-to-true and rearms after becoming false. State, relation, text, exact-number, and threshold clauses may be combined. Operator words inside quoted text remain literal. Mixing `and` and `or`, nesting groups, or using parentheses is rejected with a creator-facing explanation.

## Plain-English OTHERWISE branches

```bsharp
IF PLAYER has less than 1 health
[
    |then (change PLAYER to defeated
].
OTHERWISE
[
    |then (change PLAYER to alive
].
```

`OTHERWISE` directly follows its matching IF block, allowing only blank lines and comments between them. At START, the currently matching branch runs once. Later false-to-true transitions run the IF branch and true-to-false transitions run OTHERWISE; an unchanged result stays quiet. BASIC# deliberately uses **IF / OTHERWISE**, not IF / ELSE. `ELSE` is rejected with guidance to use `OTHERWISE`.

## Profile selection and compatibility

- Programs using only accepted Profile 1 meaning remain `bsharp.meaning.v1` and emit `bsharp.bytecode.v1`.
- Any creator-facing text value selects `bsharp.meaning.v2` and emits `bsharp.bytecode.v2`.
- Controls, hover, or context declarations select `bsharp.meaning.v3` and emit `bsharp.bytecode.v3`.
- Platform left/right/jump declarations select `bsharp.meaning.v4` and emit `bsharp.bytecode.v4`.
- Number increase/decrease actions or threshold comparisons select `bsharp.meaning.v5` and emit `bsharp.bytecode.v5`.
- Compound IF conditions select `bsharp.meaning.v6` and emit `bsharp.bytecode.v6`.
- IF rules with an OTHERWISE branch select `bsharp.meaning.v7` and emit `bsharp.bytecode.v7`.
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
ruby tools/meaning_profile_6.rb
ruby tools/meaning_profile_7.rb
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
ruby tools/bytecode_profile_6.rb
ruby tools/compound_if_stress.rb
ruby tools/bytecode_profile_7.rb
ruby tools/otherwise_branch_stress.rb
ruby tools/trial_by_fire_generator.rb
ruby tools/trial_by_fire_mutation.rb
ruby tools/trial_by_fire_gauntlet.rb
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
docs/language/BASIC_SHARP_PLAIN_ENGLISH_COMPOUND_IF_CONDITIONS_v0_1_38.md
docs/bytecode/BASIC_SHARP_BYTECODE_PROFILE_6_v0_1_38.md
docs/validation/BASIC_SHARP_VALIDATION_v0_1_38.md
docs/language/BASIC_SHARP_PLAIN_ENGLISH_OTHERWISE_BRANCHES_v0_1_39.md
docs/bytecode/BASIC_SHARP_BYTECODE_PROFILE_7_v0_1_39.md
docs/validation/BASIC_SHARP_VALIDATION_v0_1_39.md
docs/testing/BASIC_SHARP_TRIAL_BY_FIRE_v0_1_42.md
docs/validation/BASIC_SHARP_VALIDATION_v0_1_42.md
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
Version: 0.1.42
```
