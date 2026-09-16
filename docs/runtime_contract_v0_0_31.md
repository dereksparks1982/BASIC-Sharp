# BASIC# Runtime Contract v0.0.31

## Preferred path

Profile 1 normal execution is:

1. `.bsharp` resolves to accepted meaning, emits BSBC in memory, validates it completely, and runs through the BSharp VM;
2. `.bsir.json` emits BSBC in memory, validates it completely, and runs through the BSharp VM;
3. `.bsbc` validates completely and runs through the BSharp VM.

No temporary bytecode artifacts are required for source or BSIR execution.

## Reference path

`BasicSharp::Runtime` remains available only through explicit `--reference-runtime` use and internal conformance tests. It is the reference oracle, not the normal creator runtime.

## Shadow parity path

`--verify-runtime-parity` independently runs the preferred VM and reference runtime. Equivalent startup, event, world, IF, follow-up, ASK, Save, restore, and replay meaning must agree. Any mismatch stops execution with no newly mismatched transition state accepted.

## VM, Save, ASK, and failure boundaries

The accepted v0.0.30 trusted-loader, mutable-world isolation, Save validation, ASK read-only behavior, IF guards, follow-up-event guard, and atomic failed-restore rules remain authoritative.
