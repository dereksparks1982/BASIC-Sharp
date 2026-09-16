# BASIC# Parser Contract v0.0.20

## Scope

v0.0.20 changes identity and saved representation naming only. It does not change BASIC# grammar, Heads, official words, references, number syntax, selection meaning, or IF meaning.

## Creator source

Creator source remains:

```text
*.bsharp
```

The compiler entry remains:

```text
compiler/basic_sharp.rb
```

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
```

## Output contract

`--emit-ir` now emits BSharp IR with:

```json
{
  "version": "0.0.20",
  "format": "bsir.debug.json"
}
```

The recommended saved debug filename ending is `.bsir.json`.

## Explicit exclusions

- No parser tolerance or spell correction.
- No new punctuation rules.
- No new Heads or official words.
- No event queue, time, save/load, ASK, bytecode, VM, GUI, or self-hosting work.
