# BASIC# Creator-Facing Text Values v0.1.32

## Purpose

Creator text is a first-class world value. It is distinct from BASIC# identifiers and whole numbers.

## Accepted syntax

```bsharp
START
[north gate has "North Gate — CLOSED" label].

WHEN
[player sounds brass bell
<then> (change label of every gate to "OPEN — RubyVM!"].

IF
[north gate has "OPEN — RubyVM!" label
<then> (damage player by 1].
```

The opening and closing delimiters must be straight double quotes. The value name after the quote is one plain BASIC# identifier word. Existing Thing, Kind, selector, action, and IF ordering rules remain unchanged.

## Exact meaning

- Text inside the quotes is valid UTF-8 and stays on one source line.
- Case, punctuation, Unicode characters, and internal/leading/trailing spaces are meaningful.
- Equality is exact code-point-for-code-point equality after UTF-8 validation.
- BASIC# identifier normalization never changes literal text.
- A value name has one consistent schema—text or whole number—through the program and restored world.
- Any accepted creator text selects `bsharp.meaning.v2`.

## Deterministic diagnostics

The compiler rejects curly quote delimiters, missing closing quotes, additional straight quotes, newlines, backslashes, interpolation markers, concatenation, extra trailing syntax, invalid value names, text arithmetic, and text/whole-number schema conflicts.

## Explicit limits

No escapes, interpolation, concatenation, multiline text, speech action, text event matching, locale folding, case-insensitive equality, substring operations, or arithmetic on text are defined in this build.
