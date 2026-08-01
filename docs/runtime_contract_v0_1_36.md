# BASIC# Runtime Contract v0.1.36

The BSharp VM remains the preferred runtime for source, saved BSIR, and validated BSBC. `BasicSharp::Runtime` remains the explicit reference oracle. Both accept `bsharp.meaning.v4`; Profile 4 source and BSIR emit deterministic `bsharp.bytecode.v4` in memory before preferred execution.

Platform movement itself is handled by the engine-neutral `GameInput` host boundary. The reference runtime and BSharp VM expose identical declarations through ASK and preserve identical Profile 4 program fingerprints and Save behavior. `GameInput` emits the same movement command sequence from resolved BSIR or the deeply frozen BSBC model.

Older profiles keep their accepted runtime semantics and artifacts.
