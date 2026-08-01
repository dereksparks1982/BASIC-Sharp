# BASIC# Validation v0.1.38

## Accepted base

- Commit `8eb1fbe`, tag `v0.1.37`, branch `main`, clean tree.
- Accepted native result: 394 runs, 7,809 assertions, zero failures, errors, or skips.

## Candidate gates

- Frozen scope: 48 modified, 53 added, 0 deleted; 101 project paths.
- Focused compound IF tests: PASS.
- Meaning Profile 6 ten-case conformance: PASS.
- Bytecode Profile 6 contract, fixture, loader, disassembly, and direct VM execution: PASS.
- Source/BSIR/BSBC/reference/VM/ASK/Save parity: PASS.
- 5,000 reactive cycles and 20,000 events per runtime: PASS.
- Profile 1–5 committed BSBC and disassembly reproduction: PASS.
- JSON parsing and Ruby-WASM semantic lanes: PASS.

Expected native suite floor from the accepted 394/7,809 suite plus v0.1.38 additions is 412 runs and 7,903 assertions, with zero failures, errors, or skips.

The container does not provide native Ruby. Ruby-WASM cannot exercise native process pipes or atomic filesystem rename, so the streamed installer must run the complete native suite and every established stress tool on Derek's machine with zero warnings/stderr. Any failure restores exact v0.1.37.
