# BASIC# Ruby Bootstrap Compiler v0.1.16

**Language name:** BASIC#  
**Pronounced:** Basic Sharp  
**Ruby namespace:** `BasicSharp`  
**Creator source extension:** `.bsharp`

> A scripting language made for non-programmers, by non-programmers.

BASIC# lets a creator describe what exists and what should happen without first becoming a conventional programmer. The compiler and runtime carry the mechanical weight.

> The compiler and engine do the heavy lifting. The creator enjoys the ride.

v0.1.16 hardens the inherited Kind machinery added in v0.1.15. It adds a validated family-distance index, strict saved-DKIR family checks, deep-chain proofs, deterministic priority tests, and a dedicated Kind-family stress lane.

## Inherited Kind example

```text
KINDS
[creature is a thing
dragon is a creature
wyrm is a dragon].

DEFINE
[a wyrm named ember].

WHEN
[player attacks a creature
<then> (damage that creature].
```

The event below matches because a wyrm belongs to the creature family:

```text
player attacks ember
```

BASIC# follows:

```text
wyrm -> dragon -> creature -> thing
```

Exact named-Thing Triggers win first. Among Kind Triggers, the nearest compatible Kind wins. Source order breaks equal-distance ties.

## Current Heads

```text
KINDS
DEFINE
START
WHEN
IF
```

## Current official words

```text
(damage
(change
(carry
(unlock
```

The opening `(` is a creator-facing visual guide. It marks the point where BASIC# tells the world to do something.

## Compile the sample

```bash
ruby compiler/basic_sharp.rb samples/first_room.bsharp
```

## Run an inherited Kind Trigger

```bash
ruby compiler/basic_sharp.rb samples/first_room.bsharp --run "player attacks cinder"
```

## Run an exact event

```bash
ruby compiler/basic_sharp.rb samples/first_room.bsharp --run "player attacks ember"
```

## Run an existing DKIR file

```bash
ruby compiler/basic_sharp.rb samples/first_room.ir.json --run "player attacks cinder"
```

The v0.1.16 runtime remains compatible with accepted saved-DKIR fixtures from v0.1.13 and v0.1.15.

## Run the complete test suite

```bash
ruby -w -Itest -Itests -e 'Dir["tests/test_*.rb"].sort.each { |file| require_relative file }'
```

## Run the focused runtime stress test

```bash
ruby tools/runtime_stress.rb
```

Default runtime stress load:

```text
504 Things
10,003 events through source-built DKIR
10,003 events through saved DKIR
20,006 total event executions
```

## Run the Kind-family stress test

```bash
ruby tools/kind_family_stress.rb
```

Default Kind-family stress load:

```text
256-level Kind chain
64 overlapping ancestor Triggers
500 descendant Things
2,000 repeated events through source-built DKIR
2,000 repeated events through saved DKIR
```

Timing is reported for observation only. Correct behavior is not rejected merely because a machine is slower.

## Company Bible

The complete imported DK LAB Company Bible set is stored at:

```text
docs/company_bible/
```

Read it end-to-end before proposing or building the next BASIC# version.

## Contracts

```text
docs/parser_contract_v0_1_16.md
docs/runtime_contract_v0_1_16.md
docs/ir/DKIR_MEANING_CONTRACT_v0_1_16.md
```

DKIR remains readable debug JSON rather than final bytecode.

## What v0.1.16 changes

- Precomputes validated Kind-to-ancestor distances once per runtime.
- Invalidates parser-side Kind-family caches whenever a parent is added.
- Proves iterative matching through a 256-level family chain.
- Proves nearest, exact, and equal-distance source-order priority.
- Rejects malformed, duplicate, conflicting, unknown-parent, circular, and non-text Kind entries in saved DKIR.
- Rejects Things that claim an unknown Kind.
- Preserves source and saved-DKIR parity, deterministic replay, and per-event context isolation.
- Preserves valid v0.1.13 and v0.1.15 saved DKIR.

## Not included

- No new `KINDS` syntax.
- No multiple inheritance.
- No new Heads, Connectors, or official words.
- No values, amounts, time, repetition, event queue, ASK, bytecode, VM, engine bridge, or self-hosting work.
