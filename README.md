# BASIC# Ruby Bootstrap Compiler v0.1.15

**Language name:** BASIC#
**Pronounced:** Basic Sharp
**Ruby namespace:** `BasicSharp`
**Creator source extension:** `.bsharp`

> A scripting language made for non-programmers, by non-programmers.

BASIC# lets a creator describe what exists and what should happen without first becoming a conventional programmer. The compiler, runtime, future virtual machine, and engine carry the mechanical weight.

> The compiler and engine do the heavy lifting. The creator enjoys the ride.

v0.1.15 gives the existing `KINDS` parent declarations real runtime meaning. A Thing can now answer to its direct Kind and every stored parent above it.

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

The event below now matches because a wyrm belongs to the creature family:

```text
player attacks ember
```

BASIC# follows:

```text
wyrm -> dragon -> creature -> thing
```

Exact named-Thing Triggers still win first. Among Kind Triggers, the nearest matching Kind wins. Source order breaks ties at the same family distance.

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

The v0.1.15 runtime remains compatible with the accepted saved v0.1.13 DKIR fixture.

## Run the complete test suite

```bash
ruby -w -Itest -Itests -e 'Dir["tests/test_*.rb"].sort.each { |file| require_relative file }'
```

## Run the focused runtime stress test

```bash
ruby tools/runtime_stress.rb
```

Default stress load:

```text
504 Things
10,003 events through source-built DKIR
10,003 events through saved DKIR
20,006 total event executions
```

## Company Bible

The complete imported DK LAB Company Bible set is stored at:

```text
docs/company_bible/
```

Read it end-to-end before proposing or building the next BASIC# version.

## Contracts

```text
docs/parser_contract_v0_1_15.md
docs/runtime_contract_v0_1_15.md
docs/ir/DKIR_MEANING_CONTRACT_v0_1_15.md
```

DKIR remains readable debug JSON rather than final bytecode.

## What v0.1.15 changes

- Walks the existing one-parent Kind chain during Trigger matching.
- Lets descendant Things match direct parents, grandparents, and the stored root.
- Preserves exact named-Thing Trigger priority.
- Prefers the nearest compatible Kind Trigger over a more distant ancestor.
- Keeps `that Kind` context bound to the Thing selected by the Trigger.
- Lets resolver Kind selectors include descendant Things.
- Rejects unknown Kind parents and circular Kind families in plain language.
- Preserves source and saved-DKIR execution parity.

## Not included

- No multiple inheritance.
- No standalone root-declaration syntax.
- No new Heads or official words.
- No values, amounts, time, repetition, event queue, ASK, bytecode, VM, engine bridge, or self-hosting work.
