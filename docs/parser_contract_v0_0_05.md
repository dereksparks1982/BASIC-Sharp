# DKScript Parser Contract v0.0.05

> **Historical naming note:** This record predates the v0.0.14 technical identity migration. At the time recorded below, BASIC# still used the working technical name `DKScript`. Old package names, commands, paths, and Git messages are preserved as audit history.


## Purpose

v0.0.05 tightens semantic diagnostics and makes BSharp IR debug output easier to save from the command line.

This build keeps the same three visible compiler layers:

1. Parser: reads statement shape.
2. Semantic resolver: checks dictionary meaning, object references, actions, states, and ambiguity.
3. IR emitter: writes a neutral debug representation for future runtime work.

## Product positioning note

DKScript is being aimed at non-programmers: world-language first, compiler strictness underneath. Current slogan candidates are:

```text
The scripting language for non-programmers.
So easy a caveman could grasp it.
```

These are branding notes only. They do not change compiler behavior.

## Core syntax still accepted

```text
DEFINE
<a door named north door
<a key named brass key
<a table named oak table
<a guard named henry.

START
<north door is locked
<brass key is on the table
<henry is calm.

WHEN
<player attacks henry
<then> (damage henry
<then> (change henry to angry.
```

Because exactly one table exists, `the table` resolves to `oak table`.

## Commands

Emit BSharp IR debug JSON to the terminal:

```bash
ruby compiler/basic_sharp.rb samples/first_room.bsharp --emit-ir
```

Write BSharp IR debug JSON to a file:

```bash
ruby compiler/basic_sharp.rb samples/first_room.bsharp --emit-ir --out samples/first_room.bsir.json
```

Write AST JSON to a file:

```bash
ruby compiler/basic_sharp.rb samples/first_room.bsharp --emit-ast --out samples/first_room.ast.json
```

If `--out` is provided without a following path, the compiler exits with usage error 64.

## Semantic resolver responsibilities

The resolver must:

- load `DEFINE` objects into a symbol table through the core dictionary
- preserve the built-in `player` object
- resolve object names such as `henry`, `north door`, `brass key`, and `oak table`
- resolve definite kind references such as `the table` when exactly one matching object exists
- warn when a definite kind reference names a known kind but no object of that kind was defined
- detect ambiguous definite references when more than one matching object exists
- normalize simple event verbs such as `takes` to `take` and `attacks` to `attack`
- validate action markers such as `(damage`, `(change`, and `(unlock`
- validate states such as `locked`, `calm`, and `angry`
- preserve relational facts such as `brass key is on the table`

## Diagnostic examples

Unresolved definite reference:

```text
DEFINE
<a key named brass key.

START
<brass key is on the table.
```

Expected semantic warning:

```text
unresolved definite reference 'the table': no table object was defined
```

Ambiguous object:

```text
DEFINE
<a door named north door
<a door named cellar door.

IF
<the door is locked
<then> (unlock the door.
```

Expected semantic error:

```text
which door? found: north door, cellar door
```

Unknown state:

```text
START
<henry is sleepy.
```

Expected semantic error:

```text
unknown state 'sleepy'
```

Unknown action:

```text
WHEN
<player attacks henry
<then> (explode henry.
```

Expected semantic error:

```text
unknown action 'explode'
```

## Known exclusions

- No runtime execution.
- No bytecode.
- No binary compiler output.
- No DK Engine.
- No self-hosted DKScript compiler.
- No full Inform/TADS dictionary import yet.
