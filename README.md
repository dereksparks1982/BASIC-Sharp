# BASIC# Ruby Bootstrap Compiler v0.1.27

**Language name:** BASIC#  
**Pronounced:** Basic Sharp  
**Safe written form:** BSharp  
**Ruby namespace:** `BasicSharp`  
**Creator source extension:** `.bsharp`  
**Intermediate representation:** BSharp Intermediate Representation, normally **BSharp IR** or **BSIR**  
**World-save format:** BSharp Save, using `.bsave.json`  
**Inspection format:** BSharp ASK, using `bsharp.ask.json`  
**Stable meaning profile:** `bsharp.meaning.v1`  
**Execution artifact:** BSharp Bytecode, normally **BSBC**, using `.bsbc`  
**Bytecode profile:** `bsharp.bytecode.v1`

> A scripting language made for non-programmers, by non-programmers.

BASIC# lets a creator describe what exists, what should happen, preserve a settled world, ask what the program currently means, and now compile that resolved meaning into deterministic bytecode.

## v0.1.27 BSharp Bytecode Emitter and Deterministic Disassembly 1

v0.1.27 creates the first real BSharp Bytecode files while remaining non-executing:

```text
BASIC# source
    -> Ruby bootstrap parser and resolver
    -> BSharp IR
    -> BSharp Bytecode emitter
    -> BSharp Bytecode (.bsbc)
    -> future bytecode loader and BASIC# VM
```

Emit from source:

```bash
ruby compiler/basic_sharp.rb samples/first_room.bsharp --emit-bytecode
```

Emit from saved BSIR:

```bash
ruby compiler/basic_sharp.rb samples/first_room.bsir.json --emit-bytecode
```

Both commands create byte-identical files when their normalized meaning is identical:

```text
samples/first_room.bsbc
samples/first_room.bsbc.txt
```

A custom output path uses the existing `--out` option and must end in `.bsbc`:

```bash
ruby compiler/basic_sharp.rb samples/first_room.bsharp \
  --emit-bytecode \
  --out /tmp/first_room.bsbc
```

The `.bsbc.txt` companion is deterministic diagnostic disassembly. It is not creator-facing BASIC# syntax.

Run the emitter lane:

```bash
ruby tools/bytecode_emitter.rb
```

Run the machine contract audit:

```bash
ruby tools/bytecode_contract.rb
```

Normative records:

```text
spec/bytecode_v1/BASIC_SHARP_BYTECODE_PROFILE_v1.json
spec/bytecode_v1/BASIC_SHARP_BYTECODE_EMITTER_FIXTURES_v1.json
docs/bytecode/BASIC_SHARP_BYTECODE_ARCHITECTURE_v0_1_26.md
docs/bytecode/BASIC_SHARP_BYTECODE_FORMAT_AND_INSTRUCTION_CONTRACT_v0_1_26.md
docs/bytecode/BASIC_SHARP_BYTECODE_COMPATIBILITY_POLICY_v0_1_26.md
docs/bytecode/BASIC_SHARP_BYTECODE_EMITTER_AND_DETERMINISTIC_DISASSEMBLY_v0_1_27.md
```

The emitter writes atomically, rejects programs with errors or warnings, rejects unsupported Profile 1 meaning, and never serializes Ruby classes, machine paths, timestamps, or object identities.

## Canonical Company Bible

The sole active authority remains:

```text
docs/company_bible/BASIC_SHARP_COMPANY_BIBLE.md
```

Run its integrity audit:

```bash
ruby tools/company_bible_audit.rb
```

## Stable Meaning Profile 1

BSharp Meaning Profile 1 remains the implementation-neutral meaning target that the Ruby bootstrap, bytecode emitter, and future BASIC# virtual machine must reproduce.

```text
bsharp.meaning.v1
```

Run:

```bash
ruby tools/meaning_conformance.rb
```

## The five current Heads

```text
KINDS
DEFINE
START
WHEN
IF
```

Six abandoned starter names remain outside the accepted Head set:

```text
WORLD
STATES
RELATIONS
ACTIONS
WHILE
OTHERWISE
```

## Current executable official words

```text
(damage
(change
(carry
(unlock
(cause
```

v0.1.27 adds no creator-facing Head, Connector, official word, event behavior, IF behavior, number behavior, BSIR schema, Save schema, ASK schema, loader, VM, or bytecode execution.

## Current language foundation

- Things and one-parent inherited Kind families.
- Exact and Kind-based event matching.
- Singular `that Kind` event context.
- `every Kind` deterministic action selections.
- Reactive IF rules with re-arming, cascades, and loop protection.
- Explicit `(cause` follow-up events with deterministic order.
- Whole-number Thing values from 0 through 2,147,483,647.
- Deterministic BSharp Save files.
- Read-only ASK inspection with deterministic answers.
- Stable Meaning Profile 1 conformance fixtures.
- BSharp Bytecode architecture, machine-readable contract, deterministic emitter, and readable disassembly.

## Compile samples

```bash
ruby compiler/basic_sharp.rb samples/first_room.bsharp
ruby compiler/basic_sharp.rb samples/every_guard.bsharp
ruby compiler/basic_sharp.rb samples/values_and_amounts.bsharp
ruby compiler/basic_sharp.rb samples/follow_up_events.bsharp
ruby compiler/basic_sharp.rb samples/world_save_demo.bsharp
ruby compiler/basic_sharp.rb samples/ask_demo.bsharp
```

## Emit BSharp IR

```bash
ruby compiler/basic_sharp.rb samples/ask_demo.bsharp \
  --emit-ir \
  --out samples/ask_demo.bsir.json
```

A current debug document begins with:

```json
{
  "version": "0.1.27",
  "format": "bsir.debug.json"
}
```

## Retired DKIR files

There is no DKIR compatibility layer. A retired-format document receives exactly:

```text
This file uses the retired DKIR format.
BASIC# v0.1.20 uses BSharp IR.
Recompile the original .bsharp source to create a new BSIR file.
```

## Validation

```bash
ruby -w -Itest -Itests -e 'Dir["tests/test_*.rb"].sort.each { |file| require_relative file }'
```

Current validated suite totals are recorded in:

```text
docs/validation/BASIC_SHARP_VALIDATION_v0_1_27.md
```

Full lanes:

```bash
ruby tools/runtime_stress.rb
ruby tools/kind_family_stress.rb
ruby tools/if_rule_stress.rb
ruby tools/multiple_selection_stress.rb
ruby tools/value_amount_stress.rb
ruby tools/follow_up_event_stress.rb
ruby tools/world_save_stress.rb
ruby tools/ask_stress.rb
ruby tools/meaning_conformance.rb
ruby tools/company_bible_audit.rb
ruby tools/bytecode_contract.rb
ruby tools/bytecode_emitter.rb
```

Timing is observational only. A slower correct machine does not fail.

## Not included

- No arbitrary `.bsbc` loader, virtual machine, or bytecode execution.
- No Ruby runtime replacement.
- No optimization or compression.
- No creator-facing Head, Connector, official word, or syntax change.
- No capitalization, spacing, contraction, or spelling-tolerance expansion.
- No arithmetic expressions, negative numbers, decimals, fractions, or percentages.
- No BSIR, BSharp Save, or BSharp ASK schema migration.
- No editor, IDE, engine bridge, self-hosting, pricing, licensing, activation, or subscription implementation.
