# BASIC# Ruby Bootstrap Compiler v0.1.23

**Language name:** BASIC#  
**Pronounced:** Basic Sharp  
**Safe written form:** BSharp  
**Ruby namespace:** `BasicSharp`  
**Creator source extension:** `.bsharp`  
**Intermediate representation:** BSharp Intermediate Representation, normally **BSharp IR** or **BSIR**  
**World-save format:** BSharp Save, using `.bsave.json`  
**Inspection format:** BSharp ASK, using `bsharp.ask.json`

> A scripting language made for non-programmers, by non-programmers.

BASIC# lets a creator describe what exists, what should happen, and now ask what the program or current world means without first becoming a conventional programmer.

## v0.1.23 ASK introspection

ASK is a bootstrap-tool inspection command. It is not a Head, official word, event, or world action.

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

ASK is case-insensitive but does not pretend to understand unrestricted English. Unknown or unsupported questions receive plain explanations.

### Inspect without changing

```bash
ruby compiler/basic_sharp.rb samples/ask_demo.bsharp \
  --ask "what happens when player attacks henry"
```

Event inspection uses the same exact-Thing, inherited-Kind, nearest-Kind, and source-order rules as runtime execution. It reports the selected WHEN rule and actions without running them.

ASK does not change Things, values, states, relationships, IF activity, event lines, or save readiness.

### Inspect after an event

```bash
ruby compiler/basic_sharp.rb samples/ask_demo.bsharp \
  --run "player attacks henry" \
  --ask "what IF rules are true" \
  --ask "what is henry"
```

The requested event and all IF/follow-up settlement finish before ASK answers.

### Inspect a restored world

```bash
ruby compiler/basic_sharp.rb samples/ask_demo.bsharp \
  --load-world samples/ask_demo.bsave.json \
  --ask "what is the save" \
  --ask "what is henry"
```

### Machine-readable answers

```bash
ruby compiler/basic_sharp.rb samples/ask_demo.bsharp \
  --ask "what is henry" \
  --ask "what Things are guards" \
  --ask-json
```

The result uses:

```json
{
  "format": "bsharp.ask.json",
  "format_version": 1,
  "created_by_basic_sharp": "0.1.23",
  "answers": []
}
```

ASK JSON has no timestamps, random identifiers, machine paths, or unstable ordering. Identical worlds and questions produce byte-identical JSON. Up to 256 questions may be asked in one command.

Human output shows at most 50 Things or 50 true IF rules in one answer. `--ask-json` remains complete.

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

A loaded world does not rerun START, startup IF rules, or startup follow-up events. Save files preserve Thing order and identity, Kinds, states, relationships, values, damage, IF activity, and a normalized program fingerprint.

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

- `KINDS`, `DEFINE`, `START`, `WHEN`, and `IF` Heads.
- Things and inherited Kind families.
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
- Damage and health remain independent unless a creator explicitly connects them.

## Current executable official words

```text
(damage
(change
(carry
(unlock
(cause
```

v0.1.23 adds no language word. ASK is a toolchain inspection surface.

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
  "version": "0.1.23",
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
212 runs
5,043 assertions
0 failures
0 errors
0 skips
```

Stress lanes:

```bash
ruby tools/runtime_stress.rb
ruby tools/kind_family_stress.rb
ruby tools/if_rule_stress.rb
ruby tools/multiple_selection_stress.rb
ruby tools/value_amount_stress.rb
ruby tools/follow_up_event_stress.rb
ruby tools/world_save_stress.rb
ruby tools/ask_stress.rb
```

Timing is observational only. A slower correct machine does not fail.

## Company Bible

The imported DK LAB Company Bible is stored under `docs/company_bible/`. Read it end-to-end before proposing or building another BASIC# version. Historical filenames remain historical and are not active BASIC# branding.

## Current contracts

```text
docs/ask/BASIC_SHARP_ASK_CONTRACT_v0_1_23.md
docs/parser_contract_v0_1_23.md
docs/runtime_contract_v0_1_23.md
docs/ir/BSIR_MEANING_CONTRACT_v0_1_23.md
docs/save/BSHARP_SAVE_CONTRACT_v0_1_23.md
```

## Not included

- No ASK Head or `(ask` official word.
- No unrestricted natural-language interpretation or spelling correction.
- No event execution or outcome simulation during ASK inspection.
- No automatic saves, slots, file picker, cloud, compression, or encryption.
- No pending-event serialization or mid-chain saves.
- No dynamic Thing creation or deletion.
- No negative numbers, decimals, fractions, percentages, or arithmetic expressions.
- No bytecode or virtual machine.
- No GUI editor or IDE.
- No game-engine bridge.
- No self-hosting compiler.
