# BASIC# Ruby Bootstrap Compiler v0.1.18

**Language name:** BASIC#  
**Pronounced:** Basic Sharp  
**Ruby namespace:** `BasicSharp`  
**Creator source extension:** `.bsharp`

> A scripting language made for non-programmers, by non-programmers.

BASIC# lets a creator describe what exists and what should happen without first becoming a conventional programmer. The compiler and runtime carry the mechanical weight.

v0.1.18 activates the existing `every Kind` reference as an action target. One official-word line can now select every compatible Thing in deterministic definition order, including Things whose Kinds inherit from the requested Kind.

## Multiple-selection example

```text
KINDS
[captain is a guard].

DEFINE
[a guard named henry
 a captain named mara
 a guard named otto
 a device named brass bell].

WHEN
[player sounds brass bell
<then> (damage every guard
<then> (change every guard to angry].
```

The first action damages Henry, Mara, and Otto in definition order. The second action then changes Henry, Mara, and Otto to angry in the same order.

`that guard` remains singular event context. A plural action never replaces it with a list.

## Allowed position

`every Kind` is accepted as the target of an official word after `<then>` in `WHEN` and `IF` rules.

It is not yet accepted in START facts, WHEN Triggers, or IF conditions. BASIC# explains those cases instead of guessing all-versus-any meaning.

## Empty selections

A known Kind with no current Things is valid and nonfatal:

```text
<then> (damage every dragon
```

The runtime reports that nothing was selected and continues with later action lines. An unknown Kind remains a compiler error.

## Deterministic order

- Selection follows DKIR object order, normally creator DEFINE order.
- Direct and inherited Kind matches are included.
- One action line completes across its entire selection before the next action line begins.
- Each action line takes its own ordered selection snapshot.
- Serialized `candidates` are debug information only. Runtime selection is recalculated from loaded Things and the validated Kind-family index.

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
```

## Run the multiple-selection sample

```bash
ruby compiler/basic_sharp.rb samples/every_guard.bsharp --run "player sounds brass bell"
```

## Run the complete test suite

```bash
ruby -w -Itest -Itests -e 'Dir["tests/test_*.rb"].sort.each { |file| require_relative file }'
```

Current validated floor:

```text
114 runs
4,637 assertions
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
```

The multiple-selection lane proves 1,024 Things, 768 direct and inherited matches, 100 repeated multi-target events, 76,800 per-target mutations per execution path, bounded human traces, complete structured results, source/saved-DKIR parity, isolation, and deterministic replay.

Timing is observational only. A slower correct machine does not fail.

## Saved-DKIR compatibility

Valid accepted fixtures from v0.1.13, v0.1.15, v0.1.16, and v0.1.17 remain executable.

## Company Bible

The complete imported DK LAB Company Bible set is stored at:

```text
docs/company_bible/
```

Read it end-to-end before proposing or building the next BASIC# version.

## Contracts

```text
docs/parser_contract_v0_1_18.md
docs/runtime_contract_v0_1_18.md
docs/ir/DKIR_MEANING_CONTRACT_v0_1_18.md
```

## Not included

- No `all guards` alias or plural noun grammar.
- No `those guards` or set-valued `that Kind`.
- No `every Kind` in START, WHEN Triggers, or IF conditions.
- No `any Kind` or all-versus-any condition semantics.
- No new official words, values, amounts, event queue, time, repetition, save/load, ASK, bytecode, VM, engine bridge, or self-hosting work.
