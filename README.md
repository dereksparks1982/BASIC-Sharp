# BASIC# Ruby Bootstrap Compiler v0.1.19

**Language name:** BASIC#  
**Pronounced:** Basic Sharp  
**Ruby namespace:** `BasicSharp`  
**Creator source extension:** `.bsharp`

> A scripting language made for non-programmers, by non-programmers.

BASIC# lets a creator describe what exists and what should happen without first becoming a conventional programmer. The compiler and runtime carry the mechanical weight.

v0.1.19 adds a deliberately small number foundation: whole-number values attached to Things, explicit damage amounts, exact value assignment, and exact-value IF conditions. It does not add equations, variables, decimals, percentages, or hidden combat formulas.

## Value example

```text
START
[henry has 10 health
 brass bell has 3 charges].

WHEN
[player sounds brass bell
<then> (damage henry by 3
<then> (change charges of brass bell to 2].

IF
[henry has 3 damage
<then> (change henry to angry].
```

## Whole-number contract

BASIC# v0.1.19 accepts whole numbers from:

```text
0 through 2147483647
```

Use digits without commas. Negative numbers, decimals, fractions, number words, and scientific notation are not part of this build.

Damage amounts must be at least 1. Starting values and exact value assignments may be 0.

## Values belong to Things

```text
henry has 10 health
brass bell has 3 charges
```

A value name is one plain word. Custom values must be established in START before an exact value-change action uses them. `damage` is built in and begins at 0 for every Thing.

## Damage amounts

These are equivalent:

```text
(damage henry
(damage henry by 1
```

An explicit amount adds to cumulative damage:

```text
(damage henry by 3
```

Damage does not secretly subtract health. Health, armor, death, healing, and combat formulas remain separate creator decisions.

## Exact value assignment

```text
(change health of henry to 7
(change courage of every guard to 0
```

This replaces the named value. It does not add or subtract.

Set value changes validate every selected Thing before changing anyone. Missing values or overflow cause no partial mutation.

## Exact-value IF

```text
IF
[henry has 3 damage
<then> (change henry to angry].
```

This uses the existing reactive IF contract: false-to-true wake-up, quiet while true, re-arm after false, full WHEN body before IF settlement, deterministic source order, and loop protection.

## Multiple selections remain deterministic

```text
(damage every guard by 3
(change courage of every guard to 0
```

Direct and inherited Kind matches are selected in creator definition order. One action line finishes across its complete selection before the next action line begins. Singular `that Kind` event context remains singular.

## Current Heads

```text
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
```

## Compile the samples

```bash
ruby compiler/basic_sharp.rb samples/first_room.bsharp
ruby compiler/basic_sharp.rb samples/every_guard.bsharp
ruby compiler/basic_sharp.rb samples/values_and_amounts.bsharp
```

## Run the value sample

```bash
ruby compiler/basic_sharp.rb samples/values_and_amounts.bsharp --run "player sounds brass bell"
```

## Run the complete test suite

```bash
ruby -w -Itest -Itests -e 'Dir["tests/test_*.rb"].sort.each { |file| require_relative file }'
```

Current validated floor:

```text
135 runs
4,717 assertions
0 failures
0 errors
0 skips
```

## Stress lanes

```bash
ruby tools/runtime_stress.rb
ruby tools/kind_family_stress.rb
ruby tools/if_rule_stress.rb
ruby tools/multiple_selection_stress.rb
ruby tools/value_amount_stress.rb
```

The value-and-amount lane proves 1,024 Things, 768 direct and inherited guard targets, 100 repeated amount events, 76,800 explicit damage mutations and 76,800 exact value assignments per execution path, exact-value IF behavior, missing-value atomicity, overflow atomicity, no hidden health subtraction, source/saved-DKIR parity, runtime isolation, and deterministic replay.

Timing is observational only. A slower correct machine does not fail.

## Saved-DKIR compatibility

Valid accepted fixtures from v0.1.13, v0.1.15, v0.1.16, v0.1.17, and v0.1.18 remain executable. Older damage actions without an `amount` continue to mean one damage.

## Company Bible

The complete imported DK LAB Company Bible set is stored at:

```text
docs/company_bible/
```

Read it end-to-end before proposing or building the next BASIC# version.

## Contracts

```text
docs/parser_contract_v0_1_19.md
docs/runtime_contract_v0_1_19.md
docs/ir/DKIR_MEANING_CONTRACT_v0_1_19.md
```

## Not included

- No negative numbers, decimals, fractions, number words, percentages, or units.
- No arithmetic expressions, variables, constants, value copying, or arbitrary add/subtract actions.
- No greater-than, less-than, ranges, AND, or OR.
- No automatic health subtraction, death, armor, healing, or combat formulas.
- No new official words, event queue, time, repetition, save/load, ASK, bytecode, VM, engine bridge, or self-hosting work.
