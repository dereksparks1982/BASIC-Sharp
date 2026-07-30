# BASIC# Parser Contract v0.1.14

## Scope

v0.1.14 is an identity migration. The parser grammar and creator-facing meaning remain exactly as accepted in v0.1.13.

## Active technical identity

```text
Language: BASIC#
Pronunciation: Basic Sharp
Ruby namespace: BasicSharp
Compiler entry: compiler/basic_sharp.rb
Creator source extension: .bsharp
```

## Preserved parser behavior

- Heads: `KINDS`, `DEFINE`, `START`, `WHEN`, `IF`.
- Body opening `[` touches the first Body word.
- Body closing remains `].`.
- `<then>` remains a Connector.
- `then` and `than` remain accepted equivalents.
- `there` and `their` remain accepted equivalents where already supported.
- Official words retain their creator-facing opening `(`.
- User-defined direct Kind parents remain represented in BSharp IR.

## Explicit non-change

This build does not add inherited Kind matching. A declared `wyrm is a dragon` remains stored, but runtime family walking is deferred to a separately approved build.
