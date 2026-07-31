# BASIC# Changelog v0.1.27

## BSharp Bytecode Emitter and Deterministic Disassembly 1

- Added deterministic `.bsbc` emission from `.bsharp` and `.bsir.json`.
- Added deterministic `.bsbc.txt` diagnostic disassembly.
- Added CLI `--emit-bytecode` with default and custom output paths.
- Added canonical string, Kind, Thing, START, event, IF, and code-block ordering.
- Added Profile 1 lowering for every accepted START record, action, selector, and IF condition.
- Added raw 32-byte meaning fingerprints and zero-filled alignment.
- Added atomic paired output replacement.
- Added six sample binaries, six sample disassemblies, and fixture hashes.
- Added emitter tests and an independent emitter validation lane.
- Preserved creator-facing language meaning, BSIR, Save, and ASK schemas.
- Excluded loader, VM, execution, optimization, compression, and runtime replacement.
