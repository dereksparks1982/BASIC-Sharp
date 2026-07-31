# BASIC# Ruby Bootstrap Compiler v0.1.31

> A scripting language made for non-programmers, by non-programmers.

BASIC# now uses the **BSharp Virtual Machine as its preferred Profile 1 runtime**:

```text
.bsharp source -> resolve -> BSBC in memory -> validate -> BSharp VM
.bsir.json     -> BSBC in memory -> validate -> BSharp VM
.bsbc          -> validate -> BSharp VM
```

Ruby remains the bootstrap host. The older `BasicSharp::Runtime` remains a protected reference oracle for conformance and regression diagnosis, but it is no longer the normal creator execution path.

## v0.1.31 preferred-runtime transition

Normal `.bsharp` and `.bsir.json` execution now:

- emits deterministic BSharp Bytecode in memory;
- validates the complete binary through `BytecodeLoader`;
- executes the trusted model through the BSharp VM;
- leaves no temporary `.bsbc` or `.bsbc.txt` artifacts;
- remains independent of the reference runtime.

Direct `.bsbc` execution continues through the same BSharp VM.

## Main commands

Run BASIC# through the preferred BSharp VM:

```bash
ruby compiler/basic_sharp.rb samples/first_room.bsharp --run "player attacks cinder"
```

Run saved BSIR through the preferred BSharp VM:

```bash
ruby compiler/basic_sharp.rb samples/first_room.bsir.json --run "player attacks cinder"
```

Use the reference runtime explicitly for diagnosis:

```bash
ruby compiler/basic_sharp.rb samples/first_room.bsharp \
  --reference-runtime \
  --run "player attacks cinder"
```

Run both engines and stop on any semantic disagreement:

```bash
ruby compiler/basic_sharp.rb samples/first_room.bsharp \
  --verify-runtime-parity \
  --run "player attacks cinder"
```

The parity mode compares startup behavior, events, world state, reactive IF state, follow-up order, ASK, Save, restore, and replay. Only the preferred VM report is shown when both paths agree.

## Validation lanes

```bash
ruby tools/meaning_conformance.rb
ruby tools/company_bible_audit.rb
ruby tools/bytecode_contract.rb
ruby tools/bytecode_emitter.rb
ruby tools/bytecode_loader.rb
ruby tools/bytecode_virtual_machine.rb
ruby tools/bytecode_vm_stress.rb
ruby tools/runtime_transition.rb
```

## Deliberately excluded from v0.1.31

The reference runtime is not deleted. This build does not add new BASIC# syntax or meaning, strings, arithmetic expressions, repetition, functions, collections, a new bytecode profile, binary-layout changes, optimization, JIT, native code, editor, IDE, engine bridge, self-hosting, licensing, or monetization.

## Canonical records

```text
docs/company_bible/BASIC_SHARP_COMPANY_BIBLE.md
docs/hand_off/BASIC_SHARP_MASTER_THREAD_HANDOFF.md
docs/roadmap/BASIC_SHARP_ROADMAP.md
docs/runtime/BASIC_SHARP_BSHARP_VM_PREFERRED_RUNTIME_TRANSITION_v0_1_31.md
docs/runtime_contract_v0_1_31.md
docs/validation/BASIC_SHARP_VALIDATION_v0_1_31.md
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
Meaning profile: bsharp.meaning.v1
Bytecode profile: bsharp.bytecode.v1
Version: 0.1.31
```
