# BASIC# Text Value Runtime v0.1.32

Both the preferred BSharp VM and protected Ruby reference runtime execute the same typed text meaning.

## World model

Each Thing value slot contains either a whole number or exact text. Program resolution establishes the schema. START builds the initial world, CHANGE replaces the value on all selected targets atomically, and reactive IF rules observe exact equality through the accepted settling and loop-protection process.

## Runtime paths

- `.bsharp` and `.bsir.json` produce validated in-memory Profile 2 BSBC and run on the BSharp VM.
- `.bsbc` validates completely and runs directly on the BSharp VM.
- `--reference-runtime` runs the protected Ruby oracle.
- `--verify-runtime-parity` independently rebuilds both engines and stops before accepting a mismatched result or world.

## Determinism

Equivalent meaning produces identical fingerprints, bytecode, disassembly, snapshots, event results, Save documents, ASK answers, restored worlds, and replay outcomes. Literal case and punctuation are part of that identity.

## Safety

Malformed text, profile conflicts, value-schema conflicts, and invalid restored types fail before or atomically during the relevant operation. ASK remains read-only. Restore failure does not partially mutate an existing world.
