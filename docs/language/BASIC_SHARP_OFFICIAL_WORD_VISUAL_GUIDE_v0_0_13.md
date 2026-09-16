# BASIC# Official-Word Visual Guide v0.0.13

## Owner decision

The opening `(` in an official word is there for the creator first.

```text
(damage
(change
(carry
(unlock
```

It is a visual guide that marks where BASIC# tells the world to do something.

It was not added merely to make the Ruby parser's job easier.

## Reading the shape

```text
WHEN
[player attacks ember
<then> (damage ember].
```

Read it as:

```text
player attacks ember   what happened
<then>                 what follows happens because of that
(damage                BASIC# tells the world to perform damage
ember                  the already-defined Thing affected
```

The official word is `(damage`, not `(damage ember`.

## Why the mark stays

The `(` helps a non-programmer scan a Body and distinguish:

- descriptions of what exists;
- Facts about the world;
- Triggers that report what happened;
- official words that make the world do something.

This is creator-facing visual grammar.

## Lisp resemblance

Lisp commonly writes a complete instruction in a parenthesized prefix form:

```text
(damage ember)
```

BASIC# may learn from Lisp's consistency and small-core philosophy, but BASIC# does not use Lisp's full parenthesized structure.

BASIC# keeps its own Head-and-Body shape:

```text
WHEN
[player attacks ember
<then> (damage ember].
```

A resemblance to another language does not invalidate a BASIC# choice when that choice serves the beginner-first design.

## Protected rule

Do not remove or redesign the opening `(` because an outside reviewer assumes it exists for compiler convenience.

Only Derek can reopen this rule.
