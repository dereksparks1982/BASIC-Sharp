# DKScript Parser Contract v0.1.13

## Public language

BASIC#

## Bootstrap

DKScript Ruby Bootstrap Compiler

## Structure

```text
HEAD
[first Body line
next Body line].
```

The opening `[` belongs directly against the first Body word.

## Current Heads

```text
KINDS
DEFINE
START
WHEN
IF
```

## Current Connector equivalence

```text
then = than
there = their
```

No warning and no different meaning.

## Current official-word mark

```text
(damage
(change
(carry
(unlock
```

The opening `(` is an intentional creator-facing visual guide. It marks an official word that tells the world to do something.

It is not parser-only punctuation.

## v0.1.13 parser status

No creator syntax changed in v0.1.13.

The parser and resolver remain responsible for producing language-neutral DKIR.

The v0.1.13 stress suite proves the parser and resolver can process hundreds of definitions and feed deterministic runtime execution.

## Excluded

- Kind Families.
- capitalization behavior change;
- source-spacing behavior change;
- creator-defined words;
- values and amounts;
- time;
- repetition;
- groups;
- multiple selected Things.
