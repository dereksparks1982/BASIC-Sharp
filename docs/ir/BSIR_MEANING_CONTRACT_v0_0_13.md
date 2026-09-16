# BSharp IR Meaning Contract v0.0.13

## Purpose

BSharp IR is the structured record of what the BASIC# bootstrap compiler understood.

```text
BASIC# source
-> parser
-> meaning checks
-> BSharp IR
-> runtime
```

BSharp IR is not Ruby source, not a Ruby object model, and not final bytecode. It is a language-neutral bridge that a later BASIC# compiler and virtual machine must be able to reproduce.

## Current format

```json
{
  "version": "0.0.13",
  "format": "bsir.debug.json",
  "kinds": [],
  "objects": [],
  "facts": [],
  "events": [],
  "if_rules": [],
  "diagnostics": []
}
```

The runtime requires `format` to equal:

```text
bsir.debug.json
```

The following top-level fields must be lists:

```text
objects
facts
events
if_rules
diagnostics
```

`kinds` is also emitted as a list and remains part of the contract, even though direct runtime Kind-family traversal is not implemented yet.

## Version

`version` records the compiler language version that emitted the BSharp IR.

v0.0.13 does not yet promise permanent cross-version compatibility. A future compatibility policy must be decided before BSharp IR becomes a public long-term save format or bytecode replacement.

## Kinds

Each current Kind entry records:

```text
name
parent
line_number
```

Current runtime matching checks only a Thing's direct Kind. Multi-level Kind Families are excluded from v0.0.13.

## Objects

Each object entry records:

```text
name
kind
builtin
line_number
```

Rules:

- `name` identifies one Thing.
- `kind` records the Thing's direct Kind.
- `builtin` marks compiler-supplied Things such as `player`.
- two normalized Things may not have the same name;
- duplicate names are rejected instead of silently overwriting one Thing.

## References

Current reference forms include:

```text
object
kind_one
kind
previous
```

### object

Names one defined Thing.

### kind_one / kind

Describes one named Thing expected to have a direct Kind.

Example source:

```text
a guard
```

Current event text still supplies the name:

```text
player attacks henry
```

The runtime checks that Henry exists and is directly a guard.

### previous

Refers to the Thing selected earlier in the same event.

Example:

```text
that guard
```

The selected Thing lives only for the current event execution. It does not leak into a later `WHEN`, a later event, or a separate runtime.

## Facts

A Fact records a starting state or relationship.

State example:

```text
ember is calm
```

Relationship example:

```text
brass key is on oak table
```

Current entries may contain:

```text
subject
relation
value
target
raw
line_number
```

`value` is used for states. `target` is used for relationships to another Thing.

## Events

An event entry contains:

```text
when
then
line_number
```

`when` records the Trigger understood by the compiler.

`then` contains official words that run when the Trigger matches.

The runtime checks exact Triggers before direct-Kind Triggers. The first matching rule runs.

## IF rules

An IF entry contains:

```text
if
then
line_number
```

Current IF rules are checked once while the runtime starts. They are not yet a general repeated condition system.

## Official words

Current executable official words:

```text
damage
change
carry
unlock
```

BSharp IR stores their names without the creator-facing opening `(` because BSharp IR records meaning rather than source decoration.

The source form remains:

```text
(damage
(change
(carry
(unlock
```

The opening `(` is an intentional visual guide for the creator.

## Diagnostics

Each diagnostic records a compiler error or warning.

BSharp IR containing an error diagnostic cannot run.

## Runtime hardening in v0.0.13

The runtime now rejects:

- a missing or unsupported BSharp IR format;
- top-level runtime lists that are not lists;
- more than one normalized Thing with the same name;
- BSharp IR containing compiler errors;
- unknown official words encountered at runtime.

## Stability boundary

Frozen for v0.0.13:

- current top-level fields;
- current reference type names;
- direct Kind matching only;
- context limited to one event;
- first matching rule behavior;
- current four executable official words.

Not frozen permanently:

- future Kind-family data;
- values and amounts;
- multiple selected Things;
- event queues;
- bytecode layout;
- long-term version compatibility.
