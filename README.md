# BASIC# Language Foundation / DKScript Ruby Bootstrap Compiler v0.1.11

**Public language name:** BASIC#  
**Pronounced:** Basic Sharp  
**Current technical bootstrap name:** DKScript

BASIC# is a new beginner-first language. The current Ruby compiler is temporary construction scaffolding. The creator writes clear world-language while the compiler, runtime, future virtual machine, and engine carry the mechanical weight.

> The creator should be able to drive, make simple repairs, and enjoy the ride without becoming the mechanic who built the engine.

The repository, command names, Ruby module names, package prefix, and current compiler banner remain `DKScript` in v0.1.11. Their technical rename is deliberately deferred to a separate owner-approved migration so this documentation build does not destabilize the working compiler.

## Compile the sample

```bash
ruby compiler/dks.rb samples/first_room.dks
```

## Run an exact WHEN event

```bash
ruby compiler/dks.rb samples/first_room.dks --run "player attacks ember"
```

## Run a Kind Trigger

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

When the event says `player attacks henry`, the runtime confirms that Henry is a guard, remembers Henry for that Trigger, and uses Henry wherever the Connector lines say `that guard`.

## Run an existing DKIR file

```bash
ruby compiler/dks.rb samples/first_room.ir.json --run "player attacks henry"
```

This proves that saved DKIR keeps the Trigger context information needed by the runtime.

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

## What v0.1.11 records

- The owner-selected public language name is BASIC#.
- BASIC# remains a new language that follows its own rules.
- The compiler and engine do the heavy lifting while the creator enjoys the ride.
- Historical BASIC research is preserved without copying traditional BASIC syntax.
- ASK-style introspection, visible execution tracing, plain recovery, hidden internal modules, and example-first teaching are recorded as future lanes.
- Capitalization and harmless-spacing tolerance are recorded for later design review, not silently implemented.
- Grok's outside analysis is logged and evaluated.
- The Copilot project brief is preserved inside project documentation.
- v0.1.10 Runtime Trigger Context is carried forward unchanged.
- No new syntax or official words are added.

## Run all tests

```bash
ruby -w -Itest -Itests -e 'Dir["tests/test_*.rb"].sort.each { |file| require_relative file }'
```

## Not included

- No repository, file, Ruby module, or command rename.
- No new syntax.
- No new official words.
- No dictionary replacement or duplicate dictionary.
- No Kind Families.
- No multiple selected Things.
- No event queue.
- No ASK syntax.
- No trace interface.
- No recovery syntax.
- No bytecode, VM, DK Engine, or Studio implementation.
