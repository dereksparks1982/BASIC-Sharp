# BASIC# Changelog v0.0.32

## Added

- Stable Meaning Profile 2 for exact creator-facing text values.
- BSharp Bytecode Profile 2 and its three typed text instructions.
- Straight-double-quoted, single-line UTF-8 text in START, CHANGE, and reactive IF equality.
- Typed Save/restore and read-only ASK output for text values.
- Role-aware bytecode strings, Profile 2 conformance fixtures, negative fixtures, focused tests, and deterministic stress tooling.

## Changed

- Source, AST, resolution, BSIR, fingerprints, reference runtime, preferred VM, Save, ASK, CLI reporting, and shadow parity now understand text values.
- Active validation wrappers and records report v0.0.32 and verify both accepted profiles.
- The canonical Company Bible, roadmap, README, and master handoff record Profile 2 without changing the build workflow.

## Preserved

- Profile 1 remains selected for programs without creator text.
- Accepted Profile 1 meaning, fingerprints, BSBC bytes, disassembly, Save validation, ASK, VM behavior, and reference parity remain compatibility gates.

## Not added

Interpolation, concatenation, escapes, multiline text, `(speak ...)`, text event matching, arithmetic on text, editor/IDE work, and unrelated syntax remain future work.
