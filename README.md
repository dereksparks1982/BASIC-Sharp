# BASIC# Ruby Bootstrap Compiler v0.1.46

> A scripting language made for non-programmers, by non-programmers.

BASIC# v0.1.46 defines the plain-English movement/input layer for keyboard, mouse/keyboard, PS5, Xbox, and generic gamepad input while preserving the creator-facing `CONTROLS for PLAYER` language.

Ruby remains the bootstrap compiler and reference authority. The BSharp VM remains the preferred runtime. Stable Meaning Profiles 1 through 7 and BSharp Bytecode Profiles 1 through 7 remain unchanged.

## Movement/input foundation

The new input contract lives here:

```text
docs/language/BASIC_SHARP_PLAIN_ENGLISH_MOVEMENT_AND_INPUT_v0_1_46.md
spec/input/BASIC_SHARP_INPUT_DEVICE_MAPPING_v1.json
tools/input_device_contract.rb
tests/test_input_device_contract.rb
```

The creator writes movement meaning once. Device-specific host events map underneath to the same engine-neutral commands.

The self-hosting foundation from v0.1.44 remains active and unchanged:

```text
docs/self_hosting/BASIC_SHARP_SELF_HOSTING_FOUNDATION_v0_1_44.md
spec/self_hosting/BASIC_SHARP_SELF_HOSTING_SUBSET_v1.json
tools/self_hosting_contract.rb
tests/test_self_hosting_contract.rb
```

Forbidden in this build:

- new creator syntax;
- Profile 8;
- controller remapping UI;
- platform-specific driver code;
- engine bridge work;
- graphics, haptics, or camera controls;
- replacing the Ruby bootstrap compiler.

## Repaired package note

This package is the repaired v0.1.46 installer. It corrects stale version-bearing fixture hashes that caused the earlier v0.1.46 changed-files-only package to reject itself during native stress validation.

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
ruby tools/input_device_contract.rb
ruby tools/trial_by_fire_gauntlet.rb
```

## Canonical records

```text
docs/company_bible/BASIC_SHARP_COMPANY_BIBLE.md
docs/hand_off/BASIC_SHARP_MASTER_THREAD_HANDOFF.md
docs/roadmap/BASIC_SHARP_ROADMAP.md
docs/language/BASIC_SHARP_PLAIN_ENGLISH_MOVEMENT_AND_INPUT_v0_1_46.md
spec/input/BASIC_SHARP_INPUT_DEVICE_MAPPING_v1.json
spec/self_hosting/BASIC_SHARP_SELF_HOSTING_SUBSET_v1.json
docs/validation/BASIC_SHARP_VALIDATION_v0_1_46.md
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
Input contract: keyboard, mouse/keyboard, PS5, Xbox, generic gamepad
Version: 0.1.46
```
