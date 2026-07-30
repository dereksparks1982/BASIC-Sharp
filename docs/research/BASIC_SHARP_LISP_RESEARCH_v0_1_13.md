# BASIC# Lisp Research v0.1.13

## Purpose

This record captures Lisp ideas that may help BASIC# without turning BASIC# into Lisp.

## Useful ideas

### One dependable shape

Lisp places the operation first. BASIC# already gains a similar reading advantage from official words:

```text
(damage ember
(change ember to angry
```

The creator can see what the world is being told to do.

### Small powerful core

Lisp grew from a small foundation that could be combined into larger behavior.

BASIC# should favor a small set of obvious official words over hundreds of unrelated built-ins.

### Programs that can explain themselves

Lisp's program-as-data tradition supports the broader idea that a language can inspect structured meaning.

BASIC# can use BSharp IR and future ASK-style tools to explain:

```text
why henry became angry
which WHEN matched
what that guard meant
what changed a door
```

### Interactive experimentation

Lisp environments became known for entering something small and seeing the result immediately.

A future BASIC# Studio should support the same learning rhythm:

```text
make something
run it
see what happened
change one thing
run it again
```

### Automatic memory work

Lisp helped establish automatic memory recovery.

BASIC# should also keep memory management under the hood. The creator should not need to become a memory mechanic.

### Human surface versus machine structure

Lisp history shows that internal notation and creator-facing notation do not have to be the same.

BASIC# source should remain near-plain and readable. BSharp IR, bytecode, and VM structures may be stricter underneath.

## Ideas not adopted as creator requirements

BASIC# does not need to copy:

```text
deep parenthesis nesting
prefix mathematics
car
cdr
lambda
mandatory recursion
raw macros
```

These may inspire internal implementation, but they do not automatically belong in beginner-facing BASIC#.

## Decision about `(damage`

The Lisp resemblance is acknowledged.

The BASIC# opening `(` remains because Derek chose it as a visual guide for himself and other creators. Its human purpose comes first.
