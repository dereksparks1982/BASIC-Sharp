# BASIC# / DKScript Ruby Bootstrap Compiler v0.1.12

**Public language name:** BASIC#  
**Pronounced:** Basic Sharp  
**Current technical bootstrap name:** DKScript

> A script language made for non-programmers, by non-programmers.

BASIC# is being built from scratch for people who do not already think like programmers. The creator describes what exists and what should happen. The compiler, runtime, future virtual machine, and engine carry the mechanical weight.

> The compiler and engine do the heavy lifting. The creator enjoys the ride.

The repository, command names, Ruby module names, package prefix, and current compiler banner remain `DKScript` in v0.1.12. Their technical rename remains a separate owner-approved migration.

## Compile the sample

```bash
ruby compiler/dks.rb samples/first_room.dks
```

## Run a Kind Trigger with a plain-language trace

```bash
ruby compiler/dks.rb samples/first_room.dks --run "player attacks henry"
```

The sample contains:

```text
WHEN
[player attacks a guard
<then> (damage that guard
<then> (change that guard to angry].
```

The runtime now explains the ride:

```text
what matched:
  player attacks a guard
what I understood:
  a guard means henry
  that guard means henry
what happened:
  (damage henry
  henry damage is now 1
  (change henry to angry
  henry is now angry
```

The creator does not need to learn terms such as binding, scope, or pattern matching.

## Run an exact event

```bash
ruby compiler/dks.rb samples/first_room.dks --run "player attacks ember"
```

Exact events also show what matched and what changed.

## Run an existing DKIR file

```bash
ruby compiler/dks.rb samples/first_room.ir.json --run "player attacks henry"
```

Source and saved DKIR produce the same trace and the same world state.

## Emit parser AST JSON

```bash
ruby compiler/dks.rb samples/first_room.dks --emit-ast
```

The older `--json` command still emits the parser AST.

## Emit DKIR debug JSON

```bash
ruby compiler/dks.rb samples/first_room.dks --emit-ir
```

Write DKIR output to a file:

```bash
ruby compiler/dks.rb samples/first_room.dks --emit-ir --out samples/first_room.ir.json
```

## Current language structure

```text
KINDS
[dragon is a creature].

DEFINE
[a dragon named ember].

START
[ember is calm].

WHEN
[player attacks ember
<then> (damage ember
<than> (change ember to angry].
```

The active part names are:

```text
Head          KINDS / DEFINE / START / WHEN / IF
Body          [ ... ]
Kind          dragon is a creature
Thing         a dragon named ember
Fact          ember is calm
Trigger       player attacks ember
Connector     <then> or <than>
Official word (damage or (change
End           ].
```

`(damage` is the official word. `ember` is a Thing declared earlier that the runtime uses when that word runs.

## Official words currently executed

```text
(damage
(change
(carry
(unlock
```

## What v0.1.12 adds

- Plain-language runtime tracing.
- The matched `WHEN`.
- The Thing selected by a direct Kind Trigger.
- The meaning of `that guard`.
- Each event official word that ran.
- The immediate world change caused by each event word.
- Source and saved-DKIR trace parity.
- The owner doctrine: “A script language made for non-programmers, by non-programmers.”
- A decision record for Copilot's review.

## Run all tests

```bash
ruby -w -Itest -Itests -e 'Dir["tests/test_*.rb"].sort.each { |file| require_relative file }'
```

## Not included

- No new syntax.
- No new official words.
- No Kind Families.
- No multiple selected Things.
- No event queue.
- No ASK syntax.
- No recovery syntax.
- No capitalization or spacing behavior change.
- No bytecode, VM, DK Engine, or Studio implementation.
- No technical rename from DKScript to BASIC#.
