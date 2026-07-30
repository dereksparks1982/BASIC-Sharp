# DKScript Parser Contract v0.1.03

> **Historical naming note:** This record predates the v0.1.14 technical identity migration. At the time recorded below, BASIC# still used the working technical name `DKScript`. Old package names, commands, paths, and Git messages are preserved as audit history.


## Purpose

This first compiler prototype proves that DKScript can be read as structured language before any runtime or DK Engine work begins.

## Current syntax rules

- Full uppercase is reserved for statement starters only.
- Child lines begin with `<`, which replaces indentation.
- Line commands use tag form, currently `<then>` and accepted alias `<than>`.
- Important dictionary actions use an opening parenthesis marker, such as `(damage` or `(change`.
- Only the final child line in a statement ends with a period.
- Proper names do not use `the`.
- Generic references can use `the`, `a`, `every`, and `that`.

## Statement starters

```text
START
DEFINE
WORLD
STATES
RELATIONS
ACTIONS
WHEN
IF
WHILE
OTHERWISE
```

## First accepted sample

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

## Compiler output for this prototype

The compiler should produce:

- statements
- definitions
- facts
- event rules
- if rules
- action calls
- diagnostics

## Known exclusions

- No runtime execution yet.
- No bytecode yet.
- No DK Engine integration yet.
- No self-hosted compiler yet.
- No full Inform/TADS dictionary mining yet.
