# BASIC# Non-Programmer Doctrine v0.0.12

## Owner statement

> A script language made for non-programmers, by non-programmers.

## Meaning

BASIC# is not designed from the assumption that its creator already understands programming.

A creator should be able to:

- describe Things and Kinds;
- describe the starting world;
- say when something happens;
- say what happens next;
- run the creation;
- read what the machine understood;
- make understandable repairs;
- learn programming logic through creation rather than jargon drills.

The compiler, runtime, future VM, and engine may be complicated internally. That machinery is not the creator's burden.

## Design test

Every creator-facing feature must answer:

> Can a person who does not know programming read this, use it, and understand what happened?

If a feature requires the creator to learn internal compiler terminology before using it, the surface design is not finished.

## Protected wording

The language may use internal technical concepts in compiler source and engineering documents. Beginner documentation and normal runtime output should not require terms such as:

```text
binding
scope
inheritance
dispatch
lowering
AST
bytecode
event queue
garbage collection
```

The machine may use those ideas. The creator should see ordinary cause and effect.

## v0.0.12 proof

```text
WHEN
[player attacks a guard
<then> (damage that guard].
```

Runtime explanation:

```text
what matched:
  player attacks a guard
what I understood:
  a guard means henry
  that guard means henry
what happened:
  (damage henry
  henry damage is now 1
```

The trace explains the result without asking the creator to become the mechanic.
