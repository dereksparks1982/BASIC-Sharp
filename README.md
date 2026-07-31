# BASIC# Ruby Bootstrap Compiler v0.1.26

**Language name:** BASIC#  
**Pronounced:** Basic Sharp  
**Safe written form:** BSharp  
**Ruby namespace:** `BasicSharp`  
**Creator source extension:** `.bsharp`  
**Intermediate representation:** BSharp Intermediate Representation, normally **BSharp IR** or **BSIR**  
**World-save format:** BSharp Save, using `.bsave.json`  
**Inspection format:** BSharp ASK, using `bsharp.ask.json`  
**Stable meaning profile:** `bsharp.meaning.v1`  
**Future execution artifact:** BSharp Bytecode, normally **BSBC**, using `.bsbc`  
**Bytecode profile:** `bsharp.bytecode.v1`

> A scripting language made for non-programmers, by non-programmers.

BASIC# lets a creator describe what exists, what should happen, preserve a settled world, and ask what the program or world currently means.

## v0.1.26 BSharp Bytecode Architecture and Instruction Contract 1

v0.1.26 defines the first implementation-independent execution-artifact contract for BASIC# without yet creating a bytecode emitter, loader, or virtual machine.

```text
BASIC# source
    -> Ruby bootstrap parser and resolver
    -> BSharp IR
    -> future bytecode emitter
    -> BSharp Bytecode (.bsbc)
    -> future BASIC# VM
```

Identity:

```text
Name: BSharp Bytecode
Short name: BSBC
Extension: .bsbc
Magic bytes: BSBC
Binary format: bsharp.bytecode.bin
Bytecode profile: bsharp.bytecode.v1
Required meaning profile: bsharp.meaning.v1
Byte order: little-endian
```

Run the machine contract audit:

```bash
ruby tools/bytecode_contract.rb
```

Expected ending:

```text
Profile 1 coverage: PASS
Readable disassembly grammar: PASS
Malformed-bytecode rules: PASS
Deterministic contract: PASS
No Ruby-specific serialized data: PASS

BYTECODE CONTRACT: PASS
```

Normative records:

```text
spec/bytecode_v1/BASIC_SHARP_BYTECODE_PROFILE_v1.json
docs/bytecode/BASIC_SHARP_BYTECODE_ARCHITECTURE_v0_1_26.md
docs/bytecode/BASIC_SHARP_BYTECODE_FORMAT_AND_INSTRUCTION_CONTRACT_v0_1_26.md
docs/bytecode/BASIC_SHARP_BYTECODE_COMPATIBILITY_POLICY_v0_1_26.md
```

The contract defines eight required sections, fixed instruction identities, selectors, IF condition operators, deterministic string ordering, malformed-artifact rejection, and diagnostic disassembly. It does not execute bytecode.

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

BSharp Meaning Profile 1 remains the implementation-neutral meaning target that the Ruby bootstrap, future bytecode emitter, and future BASIC# virtual machine must reproduce.

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

v0.1.26 adds no creator-facing Head, Connector, official word, event behavior, IF behavior, number behavior, save schema, ASK schema, emitter, loader, VM, or bytecode execution.

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
- BSharp Bytecode architecture and machine-readable contract.

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
  "version": "0.1.26",
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

Current validated suite:

```text
234 runs
5,277 assertions
0 failures
0 errors
0 skips
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
```

Timing is observational only. A slower correct machine does not fail.

## Current contracts

```text
docs/specification/BASIC_SHARP_STABLE_MEANING_SPECIFICATION_v1.md
docs/specification/BASIC_SHARP_TERMINOLOGY_v1.md
docs/specification/BASIC_SHARP_COMPATIBILITY_POLICY_v0_1_24.md
docs/ask/BASIC_SHARP_ASK_CONTRACT_v0_1_24.md
docs/parser_contract_v0_1_24.md
docs/runtime_contract_v0_1_24.md
docs/ir/BSIR_MEANING_CONTRACT_v0_1_24.md
docs/save/BSHARP_SAVE_CONTRACT_v0_1_24.md
docs/bytecode/BASIC_SHARP_BYTECODE_FORMAT_AND_INSTRUCTION_CONTRACT_v0_1_26.md
```

## Not included

- No bytecode emitter, loader, virtual machine, or bytecode execution.
- No creator-facing Head, Connector, official word, or syntax change.
- No capitalization, spacing, contraction, or spelling-tolerance expansion.
- No arithmetic expressions, negative numbers, decimals, fractions, or percentages.
- No BSIR, BSharp Save, or BSharp ASK schema migration.
- No editor, IDE, engine bridge, self-hosting, pricing, licensing, activation, or subscription implementation.
