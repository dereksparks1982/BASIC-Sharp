# BASIC# Ruby Bootstrap Compiler v0.1.30

> A scripting language made for non-programmers, by non-programmers.

BASIC# now has a hardened three-path Profile 1 runtime:

```text
.bsharp source -> reference runtime
.bsharp source -> BSharp IR -> reference runtime
.bsharp source -> BSharp IR -> BSharp Bytecode -> loader -> BSharp VM
```

All three paths must reach the same settled world for equivalent program meaning and event sequences.

## v0.1.30 VM parity, Save, ASK, and hardening

The BSharp VM now supports the complete current Profile 1 operating boundary:

- deterministic BSharp Save writing from a VM world;
- validated BSharp Save restoration into a VM without replaying START;
- preserved reactive IF active state across restore;
- BSharp ASK over VM Things, Kinds, event matching, IF rules, world summaries, and save summaries;
- source / saved BSIR / validated BSBC world parity;
- repeated save, restore, and replay cycles;
- isolated mutable VM worlds over one deeply frozen loaded program;
- atomic failed-restore recovery;
- IF-loop and 1,024-follow-up-event protection;
- bounded performance reporting through the VM stress lane.

The VM continues to interpret validated bytecode directly. It does not reconstruct BSIR and does not call `BasicSharp::Runtime` to execute instructions.

## Main commands

Run BSharp Bytecode:

```bash
ruby compiler/basic_sharp.rb samples/first_room.bsbc --run "player attacks cinder"
```

Run, inspect, and save one VM world:

```bash
ruby compiler/basic_sharp.rb samples/ask_demo.bsbc \
  --run "player attacks henry" \
  --ask "what is the world" \
  --save-world /tmp/ask_demo.bsave.json
```

Restore and inspect a VM world:

```bash
ruby compiler/basic_sharp.rb samples/ask_demo.bsbc \
  --load-world /tmp/ask_demo.bsave.json \
  --ask "what is the save"
```

Run validation lanes:

```bash
ruby tools/meaning_conformance.rb
ruby tools/company_bible_audit.rb
ruby tools/bytecode_contract.rb
ruby tools/bytecode_emitter.rb
ruby tools/bytecode_loader.rb
ruby tools/bytecode_virtual_machine.rb
ruby tools/bytecode_vm_stress.rb
```

## Deliberately excluded from v0.1.30

The source/BSIR reference runtime is not removed. This build does not add a new bytecode profile, optimization, JIT, native machine code, new BASIC# syntax, strings, arithmetic expressions, repetition, functions, collections, editor, IDE, engine bridge, self-hosting, licensing, or monetization.

## Canonical records

```text
docs/company_bible/BASIC_SHARP_COMPANY_BIBLE.md
docs/hand_off/BASIC_SHARP_MASTER_THREAD_HANDOFF.md
docs/roadmap/BASIC_SHARP_ROADMAP.md
docs/bytecode/BASIC_SHARP_VM_PARITY_SAVE_ASK_AND_HARDENING_v0_1_30.md
docs/validation/BASIC_SHARP_VALIDATION_v0_1_30.md
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
Version: 0.1.30
```
