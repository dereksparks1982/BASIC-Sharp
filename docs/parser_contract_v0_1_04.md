# DKScript Parser Contract v0.1.04

> **Historical naming note:** This record predates the v0.1.14 technical identity migration. At the time recorded below, BASIC# still used the working technical name `DKScript`. Old package names, commands, paths, and Git messages are preserved as audit history.


## Purpose

v0.1.04 keeps the Ruby Stage 0 compiler front end and adds the first semantic resolver plus a human-readable BSharp IR debug dump.

The compiler now has three visible layers:

1. Parser: reads statement shape.
2. Semantic resolver: checks dictionary meaning, object references, actions, states, and ambiguity.
3. IR emitter: writes a neutral debug representation for future runtime work.

## Core syntax still accepted

```text
DEFINE
<a door named north door
<a key named brass key
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

## New command

```bash
ruby compiler/basic_sharp.rb samples/first_room.bsharp --emit-ir
```

This emits BSharp IR debug JSON. JSON is temporary scaffolding, not the final soul of DKScript.

## Semantic resolver responsibilities

The resolver must:

- load `DEFINE` objects into a symbol table through the core dictionary
- preserve the built-in `player` object
- resolve object names such as `henry`, `north door`, and `brass key`
- resolve kind references such as `a guard`, `every guard`, and `that guard`
- resolve definite references such as `the door`
- detect ambiguous definite references when more than one matching object exists
- normalize simple event verbs such as `takes` to `take` and `attacks` to `attack`
- validate action markers such as `(damage`, `(change`, and `(unlock`
- validate states such as `locked`, `calm`, and `angry`
- preserve relational facts such as `brass key is on the table`

## Error examples

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
