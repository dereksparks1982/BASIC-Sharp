# DKScript Parser Contract v0.1.08

> **Historical naming note:** This record predates the v0.1.14 technical identity migration. At the time recorded below, BASIC# still used the working technical name `DKScript`. Old package names, commands, paths, and Git messages are preserved as audit history.


## Build name

Body Structure and User Kinds

## Required structure

Every section begins with a Head. The next content must open a Body with `[`. The last content closes the Body and section with `].`.

```text
HEAD
[first item
second item].
```

The old form is invalid:

```text
DEFINE
<a guard named henry.
```

The parser reports:

```text
old child-line structure no longer works; start the Body with [
```

## Heads

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

`KINDS` teaches a new Kind through this form:

```text
KINDS
[dragon is a creature].
```

The parent must already be a known Kind. A user Kind is registered before `DEFINE` sections are read, so it can be used later in the same file.

## Results and Orders

A WHEN or IF Body begins with a Trigger or Fact and continues with one or more Results.

```text
WHEN
[player attacks ember
<then> (damage ember].
```

Both `<then>` and `<than>` mean Result. The Order begins with `(`.

## Approved part names

```text
Head
Body
Kind
Thing
Fact
Trigger
Result
Order
End
```

## Approved word pairs

```text
then / than
there / their
```

The first pair is active in Result markers. The second pair is recorded in the core dictionary as the same approved location word for later language growth.

## DKIR

User-defined Kinds are emitted in the `kinds` array with their parent and source line.
