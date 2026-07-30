# DKScript Ruby Bootstrap Compiler v0.1.04

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

## Emit DKIR debug JSON

```bash
ruby compiler/dks.rb samples/first_room.dks --emit-ir
```

Write it to a file:

```bash
ruby compiler/dks.rb samples/first_room.dks --emit-ir --out samples/first_room.ir.json
```

## Run tests

```bash
ruby tests/test_first_room.rb
ruby tests/test_resolver.rb
ruby tests/test_ir_output.rb
```

## What this build does

- Reads `.dks` files.
- Groups uppercase statement starters with `<` child lines.
- Accepts `<then>` and `<than>` as line-command tags.
- Detects dictionary action markers such as `(damage` and `(change`.
- Builds the parser AST.
- Adds a semantic resolver for object names, kinds, actions, states, simple event verbs, and ambiguity.
- Emits a human-readable DKIR debug JSON dump for future runtime work.

## What this build does not do

- No runtime execution.
- No bytecode.
- No self-hosted compiler.
- No DK Engine.
- No Godot integration.
- No full Inform/TADS dictionary import yet.
