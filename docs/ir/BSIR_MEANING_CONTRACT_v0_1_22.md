# BSharp IR Meaning Contract v0.1.22

## Identity

- Full name: BSharp Intermediate Representation
- Normal name: BSharp IR
- Abbreviation: BSIR
- Format marker: `bsir.debug.json`
- Current creator-source compiler version: `0.1.22`

## Preserved meaning

v0.1.22 changes no BSharp IR language meaning. Kinds, objects, START facts, WHEN rules, IF rules, references, values, amounts, and caused-event templates retain the v0.1.21 structure and behavior.

Current generated `.bsir.json` samples carry version `0.1.22`.

## Relationship to BSharp Save

BSharp IR describes program meaning. BSharp Save describes one settled world created by that program.

```text
BSharp IR: rules and definitions
BSharp Save: current world state
```

A BSharp Save is not embedded into BSIR and cannot replace the matching source or BSIR when the runtime starts.

## Program fingerprint

The save system calculates `sha256-bsir-meaning-v1` from normalized BSIR meaning:

- Kinds
- objects
- START facts
- WHEN rules
- IF rules
- action order and references

It excludes compiler version labels, diagnostics, file paths, formatting, indentation, comments, and line numbers. Equivalent source and saved BSIR must produce the same fingerprint.

## Retired format

`dkir.debug.json` remains retired and unsupported with the exact approved v0.1.20 diagnostic.
