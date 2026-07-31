# BASIC# Parser Contract v0.1.21

## New official word

```text
(cause
```

A cause action must be written after a connector inside WHEN or IF:

```text
<then> (cause henry attacks player
```

## Event sentence preservation

Everything after `(cause` belongs to the caused event sentence. The parser does not split the sentence at `to` or `by`.

These remain whole caused events:

```text
(cause player takes road to town
(cause player attacks guard by river
```

## Concrete reference rule

A caused event must identify one concrete Thing by name or use a singular `that Kind` already selected by the current WHEN.

Rejected shapes include:

```text
(cause every guard attacks player
(cause a guard attacks player
```

An unbound `that guard` is also rejected with a plain explanation.

## Current Heads

```text
KINDS
DEFINE
START
WHEN
IF
```

## Current executable official words

```text
(damage
(change
(carry
(unlock
(cause
```

## Explicit exclusions

- No automatic event syntax.
- No plural caused events.
- No delayed, timed, prioritized, scheduled, or parallel event syntax.
- No new Heads, number forms, Boolean connectors, ASK syntax, or arithmetic.
