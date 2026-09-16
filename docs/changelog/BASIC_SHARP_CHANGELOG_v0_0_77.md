# BASIC# Changelog v0.0.77

## Self-Hosting Milestone 2 Slice 4: BSharp VM Execution Independence

BSharp Compiler Subset 0 now owns `SmallCompilerSubsetBSBCVirtualMachine` as its bounded execution engine. The production `BytecodeVirtualMachine` and `BasicSharp::Runtime` remain separate referees rather than machinery under the subset path.

The independent proof chain now runs from source reading through parsing, semantic resolution, BSharp IR, BSBC encoding, BSBC loading, and BSharp VM execution. The execution corpus expands to 21 fixtures and 60 events. A dedicated Profile 7 fixture combines Kind inheritance, creator text, whole-number values, open/close/lock/take object interaction, exact and Kind selectors, IF/OTHERWISE, and follow-up events.

The VM independence gate adds 1,024-event deterministic parity and exact 1,024 follow-up-event loop-protection parity. Profiles 1-7, the BSBC binary format, creator-facing language meaning, Save, ASK, input behavior, and normal production runtime routing remain unchanged.
