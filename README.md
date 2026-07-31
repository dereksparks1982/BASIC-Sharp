# BASIC# Ruby Bootstrap Compiler v0.1.22

**Language name:** BASIC#  
**Pronounced:** Basic Sharp  
**Safe written form:** BSharp  
**Ruby namespace:** `BasicSharp`  
**Creator source extension:** `.bsharp`  
**Intermediate representation:** BSharp Intermediate Representation, normally **BSharp IR** or **BSIR**  
**World-save format:** BSharp Save, using `.bsave.json`

> A scripting language made for non-programmers, by non-programmers.

BASIC# lets a creator describe what exists and what should happen without first becoming a conventional programmer. The compiler and runtime carry the mechanical weight.

## v0.1.22 BSharp Save files

v0.1.22 adds deterministic world saving and restoring without turning the save file into another program format.

```text
BASIC# source or BSharp IR
          +
       BSharp Save
          -> restored living world
```

BSharp IR stores program rules. BSharp Save stores one fully settled world created by those rules.

### Save the world after START

```bash
ruby compiler/basic_sharp.rb samples/world_save_demo.bsharp \
  --save-world saves/world_save_demo.bsave.json
```

### Run an event and save afterward

```bash
ruby compiler/basic_sharp.rb samples/world_save_demo.bsharp \
  --run "player attacks henry" \
  --save-world saves/world_save_demo.bsave.json
```

### Load and continue

```bash
ruby compiler/basic_sharp.rb samples/world_save_demo.bsharp \
  --load-world saves/world_save_demo.bsave.json \
  --run "henry attacks player"
```

The matching saved BSIR can be used instead of source:

```bash
ruby compiler/basic_sharp.rb samples/world_save_demo.bsir.json \
  --load-world saves/world_save_demo.bsave.json \
  --run "henry attacks player"
```

A loaded world does not rerun START, startup IF rules, or startup follow-up events.

## What a BSharp Save preserves

- Thing definition order and identity.
- Kind and built-in identity.
- Current states and relationships.
- All whole-number values, including authoritative damage.
- Reactive IF active/inactive state.
- A normalized program fingerprint.
- Confirmation that the saved world was fully settled.

The same program and same settled world produce byte-for-byte identical save contents. Saves contain no timestamps, random identifiers, machine paths, or pending event queues.

## Safe restore rules

The complete save is validated before runtime state changes. BASIC# rejects:

- invalid JSON;
- the wrong document type;
- unsupported save-format versions;
- saves from a different program;
- missing, reordered, renamed, or re-Kinded Things;
- invalid values;
- missing relationship targets;
- contradictory states;
- IF-active records that disagree with the restored world.

Writes use a temporary file in the destination directory and replace the previous save only after the new save is complete. A failed write leaves the previous save untouched.

A save file cannot be run as program rules:

```text
A BSharp Save contains world state, not program rules.
Start BASIC# with the matching .bsharp or .bsir.json file and use --load-world.
```

## v0.1.21 follow-up events

The explicit official word `(cause` creates deterministic follow-up events:

```text
WHEN
[player attacks a guard
<then> (damage that guard
<then> (cause that guard attacks player
<then> (change that guard to angry].
```

BASIC# completes the current action body, settles reactive IF rules, then runs follow-up events first-created, first-run. Nested events join the end of the existing line. No damage, state, relationship, or value change secretly invents an event.

One externally supplied event may run at most 1,024 follow-up events.

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
- Atomic set validation for missing values and overflow.
- BSharp Save files with deterministic atomic restore.
- Damage and health remain independent unless a creator explicitly connects them.

## Current executable official words

```text
(damage
(change
(carry
(unlock
(cause
```

v0.1.22 adds no new language word. Save/load are toolchain commands, not creator-world actions.

## Compile samples

```bash
ruby compiler/basic_sharp.rb samples/first_room.bsharp
ruby compiler/basic_sharp.rb samples/every_guard.bsharp
ruby compiler/basic_sharp.rb samples/values_and_amounts.bsharp
ruby compiler/basic_sharp.rb samples/follow_up_events.bsharp
ruby compiler/basic_sharp.rb samples/world_save_demo.bsharp
```

## Emit BSharp IR

```bash
ruby compiler/basic_sharp.rb samples/world_save_demo.bsharp \
  --emit-ir \
  --out samples/world_save_demo.bsir.json
```

A current debug document begins with:

```json
{
  "version": "0.1.22",
  "format": "bsir.debug.json"
}
```

## BSharp Save identity

A current save begins with:

```json
{
  "format": "bsharp.save.json",
  "format_version": 1,
  "created_by_basic_sharp": "0.1.22"
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
182 runs
4,945 assertions
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
```

Timing is observational only. A slower correct machine does not fail.

## Company Bible

The imported DK LAB Company Bible is stored under:

```text
docs/company_bible/
```

Read it end-to-end before proposing or building another BASIC# version. Those imported files preserve their historical names and are not active BASIC# component branding.

## Current contracts

```text
docs/parser_contract_v0_1_22.md
docs/runtime_contract_v0_1_22.md
docs/ir/BSIR_MEANING_CONTRACT_v0_1_22.md
docs/save/BSHARP_SAVE_CONTRACT_v0_1_22.md
```

## Not included

- No `(save` or `(load` official words.
- No automatic saving, slots, file picker, cloud, compression, or encryption.
- No pending-event serialization or mid-chain saves.
- No cross-program or changed-program save migration.
- No dynamic Thing creation or deletion.
- No event-history or replay-log storage.
- No negative numbers, decimals, fractions, percentages, or arithmetic expressions.
- No ASK system.
- No bytecode or virtual machine.
- No GUI editor or IDE.
- No game-engine bridge.
- No self-hosting compiler.
