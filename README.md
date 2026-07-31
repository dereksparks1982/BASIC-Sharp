# BASIC# Ruby Bootstrap Compiler v0.1.24

**Language name:** BASIC#  
**Pronounced:** Basic Sharp  
**Safe written form:** BSharp  
**Ruby namespace:** `BasicSharp`  
**Creator source extension:** `.bsharp`  
**Intermediate representation:** BSharp Intermediate Representation, normally **BSharp IR** or **BSIR**  
**World-save format:** BSharp Save, using `.bsave.json`  
**Inspection format:** BSharp ASK, using `bsharp.ask.json`  
**Stable meaning profile:** `bsharp.meaning.v1`

> A scripting language made for non-programmers, by non-programmers.

BASIC# lets a creator describe what exists, what should happen, preserve a settled world, and ask what the program or world currently means.

## v0.1.24 Stable Meaning Specification

v0.1.24 establishes **BSharp Meaning Profile 1**. It is the implementation-neutral meaning target that the Ruby bootstrap, future bytecode runtime, and future BASIC# virtual machine must reproduce.

```text
BASIC# source
    -> BSharp Meaning Profile 1
    -> current Ruby compiler/runtime
    -> future bytecode and VM implementations
```

Profile identity:

```text
bsharp.meaning.v1
```

Run the conformance suite:

```bash
ruby tools/meaning_conformance.rb
```

Expected result:

```text
BASIC# Meaning Conformance Profile 1
Cases: 13

Source meaning: PASS
BSharp IR meaning: PASS
Runtime meaning: PASS
BSharp Save meaning: PASS
BSharp ASK meaning: PASS
Deterministic replay: PASS

PROFILE 1: PASS
```

The normative records are:

```text
docs/specification/BASIC_SHARP_STABLE_MEANING_SPECIFICATION_v1.md
docs/specification/BASIC_SHARP_TERMINOLOGY_v1.md
docs/specification/BASIC_SHARP_COMPATIBILITY_POLICY_v0_1_24.md
spec/meaning_v1/BASIC_SHARP_MEANING_PROFILE_v1.json
```

## The five current Heads

```text
KINDS
DEFINE
START
WHEN
IF
```

Six abandoned starter names were removed from the parser's accepted Head set:

```text
WORLD
STATES
RELATIONS
ACTIONS
WHILE
OTHERWISE
```

They never received complete accepted language meaning. A use now receives a plain message such as:

```text
BASIC# does not have a WORLD Head.

Current Heads are:
  KINDS
  DEFINE
  START
  WHEN
  IF
```

## Current executable official words

```text
(damage
(change
(carry
(unlock
(cause
```

v0.1.24 adds no creator-facing Head, Connector, official word, event behavior, IF behavior, number behavior, save schema, or ASK schema.

## ASK introspection

ASK is a bootstrap-tool inspection command, not a Head or official word.

```bash
ruby compiler/basic_sharp.rb samples/ask_demo.bsharp \
  --ask "what is henry"
```

Supported question shapes include:

```text
what is henry
what is Thing henry
what is Kind guard
what Kind is henry
what states does henry have
what values does henry have
what relationships does henry have
what Things are guards
what happens when player attacks henry
what IF rules are true
what is the world
what is the save
```

Machine-readable answers use `bsharp.ask.json`, format version 1. ASK is read-only and deterministic.

## BSharp Save files

BSharp IR stores program rules. BSharp Save stores one fully settled world created by those rules.

```bash
ruby compiler/basic_sharp.rb samples/world_save_demo.bsharp \
  --run "player attacks henry" \
  --save-world saves/world_save_demo.bsave.json
```

```bash
ruby compiler/basic_sharp.rb samples/world_save_demo.bsharp \
  --load-world saves/world_save_demo.bsave.json \
  --run "henry attacks player"
```

A loaded world does not rerun START, startup IF rules, or startup follow-up events. BSharp Save remains `bsharp.save.json`, format version 1.

## Follow-up events

The explicit official word `(cause` creates deterministic follow-up events:

```text
WHEN
[player attacks a guard
<then> (damage that guard
<then> (cause that guard attacks player
<then> (change that guard to angry].
```

BASIC# completes the current action body, settles reactive IF rules, then runs follow-up events first-created, first-run. One external event may run at most 1,024 follow-up events.

## Current language foundation

- Controlled Head and Body structure.
- Things and one-parent inherited Kind families.
- Exact and Kind-based event matching.
- Singular `that Kind` event context.
- `every Kind` deterministic action selections.
- Reactive IF rules with re-arming, cascades, and loop protection.
- Explicit `(cause` follow-up events with deterministic order.
- Whole-number Thing values from 0 through 2,147,483,647.
- Default and explicit damage amounts.
- Exact value assignment and exact-value IF conditions.
- Deterministic BSharp Save files.
- Read-only ASK inspection with deterministic human and JSON answers.
- Stable Meaning Profile 1 conformance fixtures.
- Damage and health remain independent unless a creator explicitly connects them.

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
  "version": "0.1.24",
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

Current validated floor:

```text
218 runs
5,102 assertions
0 failures
0 errors
0 skips
```

Stress and conformance lanes:

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
```

Timing is observational only. A slower correct machine does not fail.

## Company Bible

The imported DK LAB Company Bible is stored under `docs/company_bible/`. Read it end-to-end before proposing or building another BASIC# version. Historical filenames remain historical and are not active BASIC# branding.

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
```

## Not included

- No new creator-facing Head, Connector, or official word.
- No capitalization, spacing, contraction, or spelling-tolerance expansion.
- No unrestricted natural-language interpretation.
- No arithmetic expressions, negative numbers, decimals, fractions, or percentages.
- No BSIR, BSharp Save, or BSharp ASK format migration.
- No bytecode or virtual machine.
- No GUI editor or IDE.
- No game-engine bridge.
- No self-hosting compiler.
