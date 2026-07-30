# BASIC# Build Handshake v0.1.19

## Project and version

- **Project:** BASIC# Ruby Bootstrap Compiler
- **Build:** v0.1.19 Whole-Number Values and Damage Amounts
- **Required base:** accepted v0.1.18 Multiple Selected Things and Deterministic Set Actions
- **Required commit:** `05eaf68`
- **Required tag:** `v0.1.18`
- **Target version:** `v0.1.19`
- **Project path:** `/home/dereksparks1982/DKLab/Projects/BASIC#`

## Exact package

`BASIC_Sharp_Ruby_Bootstrap_Compiler_v0_1_19_WHOLE_NUMBER_VALUES_AND_DAMAGE_AMOUNTS_CHANGED_FILES_ONLY.zip`

## Completed changes

- Added whole-number values attached to Things through START facts such as `henry has 10 health`.
- Added a portable whole-number range of 0 through 2,147,483,647.
- Formalized `damage` as a built-in value beginning at 0 for every Thing.
- Preserved `(damage Thing` as one damage and added `(damage Thing by N`.
- Added exact assignment through `(change value of Thing to N`.
- Added exact-value IF conditions such as `henry has 3 damage`.
- Preserved reactive IF false-to-true wake-up, re-arming, source order, full-WHEN-body settlement, and loop protection.
- Preserved deterministic multiple selections and singular `that Kind` context.
- Added full-set preflight so missing values and overflow never partially mutate a selection.
- Preserved health independently from damage; no hidden combat formula was introduced.
- Added strict saved-DKIR numeric validation before START mutation.
- Preserved old saved-DKIR damage actions without `amount` as one damage.
- Added value samples, tests, v0.1.18 compatibility fixture, and a 1,024-Thing value-and-amount stress lane.

## Excluded work

- No negative values, decimals, fractions, percentages, units, or number words.
- No variables, constants, equations, arbitrary arithmetic, value copying, or comparison ranges.
- No automatic health subtraction, death, healing, armor, or combat formulas.
- No new official words, event queue, time, repetition, save/load, ASK, bytecode, VM, engine bridge, or self-hosting work.

## Changed code areas

- `compiler/ast_nodes.rb`
- `compiler/parser.rb`
- `compiler/resolver.rb`
- `compiler/runtime.rb`
- focused tests, samples, stress tool, contracts, logs, handoffs, README, roadmap, and patch manifest

## Validation results

```text
135 runs
4,717 assertions
0 failures
0 errors
0 skips
```

```text
Runtime stress: PASS
Kind-family stress: PASS
IF-rule stress: PASS
Multiple-selection stress: PASS
Value-and-amount stress: PASS
```

```text
1,024 Things
768 direct and inherited guard matches
100 repeated amount events per path
76,800 explicit amount mutations per path
76,800 exact value assignments per path
missing-value atomicity
overflow atomicity
no hidden health subtraction
source/saved-DKIR parity
runtime isolation
deterministic replay
```

## Known risks

- A custom value must be established before exact assignment; missing values are errors rather than silent zeroes.
- The 32-bit-safe ceiling is part of BASIC# meaning even though Ruby can hold larger integers.
- Damage and health remain deliberately independent.
- Large set actions retain complete structured results while human output remains bounded.
- Timing is observational only and is not an acceptance gate.

## Rollback point

```text
commit 05eaf68
tag v0.1.18
```

The installer must reset and clean back to `v0.1.18` if installation or validation fails.

## Current continuation point

Candidate built and internally validated. Derek must install, inspect, and accept or reject it before commit and tag.

## Next planned work

After v0.1.19 acceptance, read the updated roadmap and handoff, then present the complete v0.1.20 proposal before implementation. The current roadmap continuation is event ordering and queue design unless Derek changes direction.
