# BASIC# BSharp VM Preferred Runtime Transition v0.1.31

## Decision

The BSharp VM is the preferred Profile 1 execution path for `.bsharp`, `.bsir.json`, and `.bsbc` programs.

```text
.bsharp -> resolved meaning -> BSBC in memory -> complete validation -> BSharp VM
.bsir.json -> BSBC in memory -> complete validation -> BSharp VM
.bsbc -> complete validation -> BSharp VM
```

The Ruby reference runtime is not a competing product path. It remains an explicit verification oracle while BASIC# is bootstrap-hosted by Ruby.

## In-memory boundary

Source and BSIR execution use `BytecodeEmitter#binary` and `BytecodeLoader.new`. They do not write temporary bytecode or disassembly files. The loader must validate the complete binary and expose a deeply frozen trusted model before the VM creates mutable world state.

## Explicit reference mode

`--reference-runtime` routes source or BSIR directly through `BasicSharp::Runtime`. This is for diagnosis, conformance work, and regression comparison. It cannot be combined with direct `.bsbc` input because `.bsbc` is already the VM artifact.

## Shadow parity mode

`--verify-runtime-parity` creates independent preferred and reference executions. It verifies startup, event results, settled worlds, IF truth and active state, follow-up ordering, ASK, Save, restore, and replay.

Each verified event is first executed on freshly reconstructed candidate engines using the same starting save and prior event history. A mismatch leaves the previously accepted transition state in place and raises a plain-language error with bounded result fingerprints.

## Preserved boundaries

- The VM does not reconstruct BSIR.
- The VM does not call `BasicSharp::Runtime`.
- The reference runtime is not deleted.
- Direct `.bsbc` execution remains unchanged.
- BSharp Save and BSharp ASK formats remain unchanged.
- `bsharp.bytecode.v1` binary layout remains unchanged.
- Existing committed `.bsbc` and `.bsbc.txt` files remain byte-for-byte unchanged.
