# DKScript Parser Contract v0.1.09

## Build name

First Runtime Execution

## Body structure

Every Head is followed by one Body. The `[` touches the first Body word. The End is `].`.

```text
HEAD
[first Body line
next Body line].
```

Correct:

```text
WHEN
[player attacks ember
<then> (damage ember].
```

Incorrect:

```text
WHEN
[
player attacks ember
].
```

## Active Heads

```text
START
DEFINE
KINDS
WORLD
STATES
RELATIONS
ACTIONS
WHEN
IF
WHILE
OTHERWISE
```

## User Kinds

```text
KINDS
[dragon is a creature].
```

The parent must already be a known Kind. This build does not add Kind Families or richer Kind declarations.

## Connectors and official words

```text
WHEN
[player attacks ember
<then> (damage ember].
```

- `<then>` is a Connector.
- `<than>` is the exact same Connector.
- `(damage` is an official DKScript word.
- `ember` must resolve to a Thing declared earlier.

The compiler no longer describes `<then>` as a Result or `(damage ember` as an Order in user-facing messages.

## Approved equivalent words

```text
then = than
there = their
```

No warning or spelling distinction is produced for either approved pair.
