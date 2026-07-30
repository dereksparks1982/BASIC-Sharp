# DKScript Ruby Bootstrap Compiler v0.1.03

This is the first standalone DKScript compiler prototype. It is written in Ruby as a Stage 0 bootstrap compiler.

## Run the sample

```bash
ruby compiler/dks.rb samples/first_room.dks
```

## Run JSON output

```bash
ruby compiler/dks.rb samples/first_room.dks --json
```

## Run tests

```bash
ruby tests/test_first_room.rb
```

## What this build does

- Reads `.dks` files.
- Groups uppercase statement starters with `<` child lines.
- Accepts `<then>` and `<than>` as line-command tags.
- Detects dictionary action markers such as `(damage` and `(change`.
- Builds a first structured program model.
- Emits useful diagnostics.

## What this build does not do

- No runtime execution.
- No bytecode.
- No self-hosted compiler.
- No DK Engine.
- No Godot integration.
