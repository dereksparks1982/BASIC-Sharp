# BASIC# Ruby Bootstrap Compiler v0.1.29

> A scripting language made for non-programmers, by non-programmers.

BASIC# now has a complete first bytecode execution path:

```text
.bsharp source
-> BSharp IR
-> BSharp Bytecode (.bsbc)
-> complete loader validation
-> BSharp Virtual Machine
-> deterministic running world
```

## v0.1.29 First BSharp Virtual Machine

The VM interprets validated `bsharp.bytecode.v1` records directly. It does not reconstruct BSIR and does not call the reference `BasicSharp::Runtime` to execute instructions.

Run committed bytecode:

```bash
ruby compiler/basic_sharp.rb samples/first_room.bsbc --run "player attacks cinder"
```

Optionally verify the bytecode meaning first:

```bash
ruby compiler/basic_sharp.rb samples/first_room.bsbc \
  --against samples/first_room.bsharp \
  --run "player attacks cinder"
```

Validate without execution:

```bash
ruby compiler/basic_sharp.rb samples/first_room.bsbc
```

Disassemble validated bytecode:

```bash
ruby compiler/basic_sharp.rb samples/first_room.bsbc --disassemble-bytecode
```

## VM behavior included

- START states, relationships, and whole-number values
- exact named-Thing event priority
- nearest inherited-Kind matching and source-order ties
- singular `that Kind` binding
- definition-order `every Kind` actions
- damage, state changes, exact value changes, carry, unlock, and cause-event instructions
- reactive IF settlement and rearming
- first-created, first-run follow-up events
- IF-loop and 1,024-follow-up-event protection
- independent VM worlds over one immutable loaded program
- deterministic snapshots and canonical reports

## Deliberately excluded from v0.1.29

BSharp Save and ASK through the VM, replacement of the source/BSIR reference runtime, full VM stress hardening, optimization, JIT, native machine code, new language features, editor, IDE, engine bridge, and self-hosting.

## Main commands

```bash
ruby compiler/basic_sharp.rb samples/first_room.bsharp
ruby compiler/basic_sharp.rb samples/first_room.bsharp --run "player attacks cinder"
ruby compiler/basic_sharp.rb samples/first_room.bsharp --emit-ir
ruby compiler/basic_sharp.rb samples/first_room.bsharp --emit-bytecode
ruby tools/meaning_conformance.rb
ruby tools/company_bible_audit.rb
ruby tools/bytecode_contract.rb
ruby tools/bytecode_emitter.rb
ruby tools/bytecode_loader.rb
ruby tools/bytecode_virtual_machine.rb
```

## Canonical records

```text
docs/company_bible/BASIC_SHARP_COMPANY_BIBLE.md
docs/hand_off/BASIC_SHARP_MASTER_THREAD_HANDOFF.md
docs/roadmap/BASIC_SHARP_ROADMAP.md
docs/bytecode/BASIC_SHARP_FIRST_BSHARP_VIRTUAL_MACHINE_AND_PROFILE_1_EXECUTION_v0_1_29.md
docs/validation/BASIC_SHARP_VALIDATION_v0_1_29.md
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
Virtual machine: BSharp Virtual Machine / BSharp VM
Meaning profile: bsharp.meaning.v1
Bytecode profile: bsharp.bytecode.v1
Version: 0.1.29
```
