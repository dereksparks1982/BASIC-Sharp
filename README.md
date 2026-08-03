# BASIC# Ruby Bootstrap Compiler v0.1.44

> A scripting language made for non-programmers, by non-programmers.

BASIC# v0.1.44 re-carries the self-hosting lane after the rejected v0.1.43 package and starts it by defining **BSharp Compiler Subset 0**. This is a foundation contract, not a compiler rewrite.

Ruby remains the bootstrap compiler and reference authority. The BSharp VM remains the preferred runtime. Stable Meaning Profiles 1 through 7 and BSharp Bytecode Profiles 1 through 7 remain unchanged.

## Self-hosting foundation

The new contract lives here:

```text
docs/self_hosting/BASIC_SHARP_SELF_HOSTING_FOUNDATION_v0_1_44.md
spec/self_hosting/BASIC_SHARP_SELF_HOSTING_SUBSET_v1.json
tools/self_hosting_contract.rb
tests/test_self_hosting_contract.rb
```

v0.1.44 explicitly does not claim BASIC# is self-hosted. It defines what future compiler-writing work may use and what remains forbidden until later approval.

Forbidden in this build:

- replacing the Ruby bootstrap compiler;
- claiming BASIC# is self-hosted;
- Profile 8;
- new creator syntax;
- new bytecode instructions;
- loops, functions, collections, or string interpolation;
- native code generation;
- engine bridge work;
- BSharp native document app work.

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
ruby tools/self_hosting_contract.rb
ruby tools/trial_by_fire_gauntlet.rb
```

## Canonical records

```text
docs/company_bible/BASIC_SHARP_COMPANY_BIBLE.md
docs/hand_off/BASIC_SHARP_MASTER_THREAD_HANDOFF.md
docs/roadmap/BASIC_SHARP_ROADMAP.md
docs/self_hosting/BASIC_SHARP_SELF_HOSTING_FOUNDATION_v0_1_44.md
spec/self_hosting/BASIC_SHARP_SELF_HOSTING_SUBSET_v1.json
docs/validation/BASIC_SHARP_VALIDATION_v0_1_44.md
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
Version: 0.1.44
```
