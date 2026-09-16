# BASIC# Stable Meaning Specification v2

## Relationship to Profile 1

`bsharp.meaning.v2` extends every accepted rule of `bsharp.meaning.v1`. The only new creator-facing meaning in v0.0.32 is exact text values. Profile 1 remains valid and is selected when a program contains no Profile 2 meaning.

## Text value domain

A text value is a finite, valid UTF-8 string on one source line. Empty text is valid. Case, punctuation, Unicode characters, and every space between the straight delimiters are meaningful. Equality is exact. Identifier normalization, locale rules, and case folding do not apply.

## Operations

- START assigns one text value to one named value slot on one resolved Thing.
- CHANGE assigns one text value to the named slot on every selected target atomically.
- IF text equality becomes true only when the resolved target's named slot exists as text and exactly equals the literal.
- Text is not a damage amount and does not participate in arithmetic.
- One value name cannot be used as both text and whole number in the same program.

## Runtime behavior

Text participates in the accepted START settling, event matching, selection, action order, reactive IF rearming/cascades/loop protection, follow-up event order, Save/restore, ASK immutability, and VM/reference shadow-parity rules.

## Conformance authority

The machine-readable profile is `spec/meaning_v2/BASIC_SHARP_MEANING_PROFILE_v2.json`. Its cases cover START, selected CHANGE, reactive IF, Save/ASK, and deterministic invalid boundaries. Implementations claiming Profile 2 must pass those fixtures without weakening Profile 1 conformance.
