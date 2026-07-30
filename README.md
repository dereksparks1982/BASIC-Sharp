# DKScript Ruby Bootstrap Compiler v0.1.08

**The scripting language for non-programmers.**

DKScript is being built so game logic can be written in clear world-language first, then compiled into a runtime-friendly form later.

## Run the sample

```bash
ruby compiler/dks.rb samples/first_room.dks
```

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
[ember is alive].

WHEN
[player attacks ember
<then> (damage ember
<than> (change ember to angry].
```

The official part names are:

```text
Head    KINDS / DEFINE / START / WHEN / IF
Body    [ ... ]
Kind    dragon is a creature
Thing   a dragon named ember
Fact    ember is alive
Trigger player attacks ember
Result  <then> or <than>
Order   (damage ember
End     ].
```

## What v0.1.08 adds

- Replaces the old repeated `<` child structure with one Body enclosed by `[` and `].`.
- Rejects the old child-line structure immediately.
- Adds the `KINDS` Head.
- Lets a script teach DKScript a new Kind such as `dragon is a creature`.
- Lets `DEFINE` create Things from user-defined Kinds.
- Emits user-defined Kinds in DKIR debug JSON.
- Accepts both `<then>` and `<than>` as Results.
- Records `there` and `their` as the approved location-word pair.
- Uses the plain part names Head, Body, Kind, Thing, Fact, Trigger, Result, Order, and End.

## Run tests

```bash
ruby tests/test_first_room.rb
ruby tests/test_resolver.rb
ruby tests/test_ir_output.rb
ruby tests/test_cli_output.rb
ruby tests/test_diagnostics_samples.rb
```

## Not included

- No runtime execution.
- No bytecode.
- No VM.
- No self-hosted compiler.
- No DK Engine.
- No Godot integration.
- No full Inform or TADS dictionary import.
