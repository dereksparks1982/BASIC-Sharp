# BASIC# Changelog v0.0.31

## Added

- Preferred-runtime transition boundary for source and saved BSIR.
- In-memory BSBC emission and complete validation before normal execution.
- `--reference-runtime` explicit reference-oracle mode.
- `--verify-runtime-parity` independent shadow verification mode.
- Bounded plain-language mismatch detection.
- Preferred-runtime machine fixtures, tests, and validation tool.
- Evaluated external Claude review record.

## Changed

- Normal `.bsharp` and `.bsir.json` runtime work now uses the BSharp VM.
- BSharp IR readiness validation now proves it can enter the preferred VM path.
- Bytecode Profile 1 records the preferred runtime, reference role, and shadow parity boundary.
- Active identity surfaces advanced to v0.0.31.
- Roadmap and master handoff now record accepted v0.0.30 commit `30e1506` and tag `v0.0.30`.

## Preserved

- Direct `.bsbc` execution through the BSharp VM.
- Reference runtime for explicit verification.
- Meaning Profile 1 behavior.
- Bytecode binary layout and all committed BSBC hashes.
- BSharp Save and BSharp ASK format versions.
