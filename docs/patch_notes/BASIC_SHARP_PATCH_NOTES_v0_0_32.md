# BASIC# Patch Notes v0.0.32

BASIC# can now hold creator-facing text as a real value instead of forcing every world value to be a whole number.

Write text with straight double quotes:

```bsharp
START
[north gate has "North Gate — CLOSED" label].
```

Change it with the existing creator-facing action form:

```bsharp
(change label of north gate to "OPEN — RubyVM!"
```

Reactive IF rules compare text exactly. Capitalization, punctuation, Unicode characters, and spaces matter. Save files preserve whether each value is text or a whole number, and ASK reports both kinds without changing the world.

Programs that do not use text remain Profile 1. Text programs use Meaning Profile 2 and Bytecode Profile 2 automatically. This build deliberately does not add escapes, interpolation, concatenation, multiline text, speech, or editor work.
