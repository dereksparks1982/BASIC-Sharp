# DKScript Ruby Bootstrap Compiler v0.1.07

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
ruby tests/test_diagnostics_samples.rb
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
- Adds bad-script samples for unknown objects, unknown kinds, unknown states, unknown actions, ambiguous references, and bad line commands.
- Adds a diagnostics sample test harness so compiler errors stay understandable for non-programmers.
- Deduplicates diagnostics so the same mistake is not reported twice.
- Cleans parser-to-resolver cascades so syntax recovery does not create noisy follow-up errors.
- Keeps diagnostics ordered by source line, with errors before warnings on the same line.

## What this build does not do

- No runtime execution.
- No bytecode.
- No self-hosted compiler.
- No DK Engine.
- No Godot integration.
- No full Inform/TADS dictionary import yet.


## Bad-script diagnostic samples

v0.1.06 added small broken `.dks` files under `samples/errors/`.

v0.1.07 cleans the diagnostic output from those samples so each mistake is reported once, in plain language.

The error samples are not game content. They are compiler teaching targets: each one proves DKScript explains a mistake in plain words instead of failing like a cryptic machine cave.

Examples covered:

- `unknown_object.dks`
- `unknown_kind.dks`
- `unknown_state.dks`
- `unknown_action.dks`
- `ambiguous_door.dks`
- `bad_line_command.dks`
