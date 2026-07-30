# BASIC# Ruby Bootstrap Compiler v0.1.14

**Language name:** BASIC#
**Pronounced:** Basic Sharp
**Ruby namespace:** `BasicSharp`
**Creator source extension:** `.bsharp`

> A scripting language made for non-programmers, by non-programmers.

BASIC# lets a creator describe what exists and what should happen without first becoming a conventional programmer. The compiler, runtime, future virtual machine, and engine carry the mechanical weight.

> The compiler and engine do the heavy lifting. The creator enjoys the ride.

v0.1.14 completes the technical identity migration. The former working name survives only in clearly marked historical records and old Git/package history.

## Current language shape

```text
KINDS
[dragon is a creature].

DEFINE
[a dragon named ember].

START
[ember is calm].

WHEN
[player attacks ember
<then> (damage ember].
```

The opening `[` belongs directly against the first Body word.

The opening `(` in an official word such as `(damage` is a creator-facing visual guide. It marks the point where BASIC# tells the world to do something.

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

## Compile the sample

```bash
ruby compiler/basic_sharp.rb samples/first_room.bsharp
```

## Run a Kind Trigger with a plain-language trace

```bash
ruby compiler/basic_sharp.rb samples/first_room.bsharp --run "player attacks henry"
```

## Run an exact event

```bash
ruby compiler/basic_sharp.rb samples/first_room.bsharp --run "player attacks ember"
```

## Run an existing DKIR file

```bash
ruby compiler/basic_sharp.rb samples/first_room.ir.json --run "player attacks henry"
```

The v0.1.14 runtime remains compatible with saved v0.1.13 DKIR debug JSON.

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
10,002 events through source-built DKIR
10,002 events through saved DKIR
20,004 total event executions
```

## Company Bible

The complete imported DK LAB Company Bible set is stored at:

```text
docs/company_bible/
```

Read it end-to-end before proposing or building the next BASIC# version. The BASIC# carryover record is:

```text
docs/company_bible/BASIC_SHARP_COMPANY_BIBLE_CARRYOVER_v0_1_14.md
```

## DKIR contract

```text
docs/ir/DKIR_MEANING_CONTRACT_v0_1_13.md
```

DKIR remains readable debug JSON rather than final bytecode. v0.1.14 changes project identity, not DKIR meaning.

## What v0.1.14 changes

- Renames the active project identity to BASIC# / Basic Sharp.
- Renames the Ruby namespace to `BasicSharp`.
- Renames the compiler entry point to `compiler/basic_sharp.rb`.
- Renames the IR source file to `compiler/basic_sharp_ir.rb`.
- Renames creator samples from `.dks` to `.bsharp`.
- Renames active documentation paths carrying the retired label.
- Imports the complete Company Bible set into project documentation.
- Corrects the accepted v0.1.13 baseline to commit `3ae88bb`, tag `v0.1.13`.
- Preserves all v0.1.13 language and runtime behavior.

## Not included

- No new `KINDS` syntax.
- No inherited Kind matching yet.
- No multiple inheritance.
- No new Heads or official words.
- No values, amounts, time, repetition, event queue, ASK, bytecode, VM, engine bridge, or self-hosting work.
