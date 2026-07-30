# BASIC# Ruby Bootstrap Compiler v0.1.20

**Language name:** BASIC#  
**Pronounced:** Basic Sharp  
**Safe written form:** BSharp  
**Ruby namespace:** `BasicSharp`  
**Creator source extension:** `.bsharp`  
**Intermediate representation:** BSharp Intermediate Representation, normally **BSharp IR** or **BSIR**

> A scripting language made for non-programmers, by non-programmers.

BASIC# lets a creator describe what exists and what should happen without first becoming a conventional programmer. The compiler and runtime carry the mechanical weight.

## v0.1.20 identity migration

v0.1.20 gives the language's internal representation its permanent BASIC# identity:

```text
DKIR                         -> BSharp IR / BSIR
dkir.debug.json              -> bsir.debug.json
*.ir.json                    -> *.bsir.json
DK_PATCH_MANIFEST.json       -> BASIC_SHARP_PATCH_MANIFEST.json
DK_CHANGED_FILES_PATCH       -> BASIC_SHARP_CHANGED_FILES_PATCH
```

All current samples, fixtures, tests, tools, contracts, diagnostics, manifests, and documentation use the new identity. Imported Company Bible files remain untouched historical records.

There is no DKIR compatibility layer. A retired-format document receives exactly:

```text
This file uses the retired DKIR format.
BASIC# v0.1.20 uses BSharp IR.
Recompile the original .bsharp source to create a new BSIR file.
```

Recompile the original `.bsharp` source to create a current `.bsir.json` file.

## Compiler flow

```text
BASIC# source
    -> Ruby bootstrap parser and resolver
    -> BSharp IR debug document
    -> BASIC# runtime
    -> deterministic world changes and plain-language trace
```

## Current language foundation

- `KINDS`, `DEFINE`, `START`, `WHEN`, and `IF` Heads.
- Things and inherited Kind families.
- Exact and Kind-based event matching.
- Singular `that Kind` event context.
- `every Kind` deterministic action selections.
- Reactive IF rules with re-arming, cascades, and loop protection.
- Whole-number Thing values from 0 through 2,147,483,647.
- Default and explicit damage amounts.
- Exact value assignment.
- Exact-value IF conditions.
- Atomic set validation for missing values and overflow.
- Damage and health remain independent unless a creator explicitly connects them.

## Current executable official words

```text
(damage
(change
(carry
(unlock
```

## Compile samples

```bash
ruby compiler/basic_sharp.rb samples/first_room.bsharp
ruby compiler/basic_sharp.rb samples/every_guard.bsharp
ruby compiler/basic_sharp.rb samples/values_and_amounts.bsharp
```

## Emit BSharp IR

```bash
ruby compiler/basic_sharp.rb samples/first_room.bsharp \
  --emit-ir \
  --out samples/first_room.bsir.json
```

A current debug document begins with:

```json
{
  "version": "0.1.20",
  "format": "bsir.debug.json"
}
```

## Run source or saved BSIR

```bash
ruby compiler/basic_sharp.rb samples/first_room.bsharp --run "player attacks ember"
ruby compiler/basic_sharp.rb samples/first_room.bsir.json --run "player attacks ember"
```

## Validation

```bash
ruby -w -Itest -Itests -e 'Dir["tests/test_*.rb"].sort.each { |file| require_relative file }'
```

Current validated floor:

```text
139 runs
4,739 assertions
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
```

All five lanes require source/saved-BSharp-IR parity, separate runtime isolation, and deterministic replay where applicable. Timing is observational only.

## Company Bible

The imported DK LAB Company Bible is stored under:

```text
docs/company_bible/
```

Read it end-to-end before proposing or building another BASIC# version. Those imported files preserve their historical names and are not active BASIC# component branding.

## Current contracts

```text
docs/parser_contract_v0_1_20.md
docs/runtime_contract_v0_1_20.md
docs/ir/BSIR_MEANING_CONTRACT_v0_1_20.md
```

## Not included

- No event queue or follow-up event design.
- No time, scheduling, repetition, or world save/load.
- No ASK system.
- No arithmetic expressions, variables, decimals, percentages, or units.
- No bytecode or virtual machine.
- No GUI editor or IDE.
- No game-engine bridge.
- No self-hosting compiler.
