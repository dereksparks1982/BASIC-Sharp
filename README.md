# DKScript Ruby Bootstrap Compiler v0.1.05

**The scripting language for non-programmers.**

DKScript is being built so game logic can be written in clear world-language first, then compiled into a runtime-friendly form later. The design goal is direct: readable enough for a non-programmer to grasp, strict enough for a compiler to trust.

Slogan candidates being tracked:

- The scripting language for non-programmers.
- So easy a caveman could grasp it.

This is the standalone DKScript Stage 0 bootstrap compiler. It is written in Ruby so DKScript can be shaped quickly before it becomes self-hosting later.

## Run the sample

```bash
ruby compiler/dks.rb samples/first_room.dks
```

## Emit parser AST JSON

```bash
ruby compiler/dks.rb samples/first_room.dks --emit-ast
```

The old alias still works:

```bash
ruby compiler/dks.rb samples/first_room.dks --json
```

Write AST output to a file:

```bash
ruby compiler/dks.rb samples/first_room.dks --emit-ast --out samples/first_room.ast.json
```

## Emit DKIR debug JSON

```bash
ruby compiler/dks.rb samples/first_room.dks --emit-ir
```

Write DKIR output to a file:

```bash
ruby compiler/dks.rb samples/first_room.dks --emit-ir --out samples/first_room.ir.json
```

## Run tests

```bash
ruby tests/test_first_room.rb
ruby tests/test_resolver.rb
ruby tests/test_ir_output.rb
ruby tests/test_cli_output.rb
```

## What this build does

- Reads `.dks` files.
- Groups uppercase statement starters with `<` child lines.
- Accepts `<then>` and `<than>` as line-command tags.
- Detects dictionary action markers such as `(damage` and `(change`.
- Builds the parser AST.
- Resolves object names, kinds, actions, states, simple event verbs, and ambiguity.
- Resolves `the table` to a single defined table object when exactly one table exists.
- Warns when a definite reference such as `the table` names a known kind but no matching object was defined.
- Adds safer `--out` file writing for AST and DKIR output.
- Emits a human-readable DKIR debug JSON dump for future runtime work.

## What this build does not do

- No runtime execution.
- No bytecode.
- No self-hosted compiler.
- No DK Engine.
- No Godot integration.
- No full Inform/TADS dictionary import yet.
