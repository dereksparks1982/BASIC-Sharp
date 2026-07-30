# DKScript Ruby Bootstrap Compiler v0.1.09

**The scripting language for non-programmers.**

DKScript lets a creator write what should happen in clear world-language. The compiler reads it, checks it, turns it into DKIR, and the first runtime can now carry out a small working set.

## Compile the sample

```bash
ruby compiler/dks.rb samples/first_room.dks
```

## Run one WHEN event

```bash
ruby compiler/dks.rb samples/first_room.dks --run "player attacks ember"
```

The runtime creates the defined Things, applies the START facts, checks the existing IF rule once, matches the requested WHEN Trigger, follows `<then>` or `<than>`, runs the official words, and prints the changed world state.

## Run an existing DKIR file

```bash
ruby compiler/dks.rb samples/first_room.ir.json --run "player attacks ember"
```

This proves the runtime can load DKIR that was already written to disk instead of requiring the source to be compiled again.

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

## Current DKScript structure

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

`(damage` is the official word. `ember` is the Thing declared earlier that DKScript uses when that word runs.

## Official words run by v0.1.09

```text
(damage
(change
(carry
(unlock
```

The runtime does not add new DKScript syntax or new official words. It runs the words that were already present in v0.1.08.

## What v0.1.09 adds

- First executable DKScript runtime foundation.
- Loads the existing DKIR structure.
- Creates all defined Things, including the built-in player.
- Applies START facts.
- Checks current IF rules once after START facts.
- Receives and matches one WHEN event from the command line.
- Follows `<then>` and `<than>` identically.
- Runs `(damage`, `(change`, `(carry`, and `(unlock`.
- Prints the changed world state.
- Corrects user-facing terminology so `<then>` is a Connector and `(damage` is an official word.

## Run all tests

```bash
ruby -Itest -Itests -e 'Dir["tests/test_*.rb"].sort.each { |file| require_relative file }'
```

## Not included

- No new syntax.
- No new official words.
- No Kind Families.
- No dictionary expansion.
- No bytecode.
- No VM.
- No continuous event queue.
- No full health or combat model.
- No DK Engine.
- No Godot integration.
