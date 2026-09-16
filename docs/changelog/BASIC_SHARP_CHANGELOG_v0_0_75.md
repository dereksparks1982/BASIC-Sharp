# BASIC# Changelog v0.0.75

## Self-Hosting Milestone 2 Slice 2: BSBC Emitter Independence

BSharp Compiler Subset 0 now owns an independent `SmallCompilerSubsetBSBCEncoder` for its primary BSBC byte-generation path. `SmallCompilerSubsetBSBCEmitter` consumes those independently encoded bytes, while the production Ruby `BytecodeEmitter` remains a separate referee used only to prove exact binary parity.

The execution corpus expands to 19 fixtures and 57 events. A dedicated Profile 7 fixture combines the accepted open, close, lock, and take object-interaction actions with whole-number increase and IF/OTHERWISE branching, then proves independent BSBC emission through the existing loader, BSharp VM, and Ruby-referee execution path.

Ruby remains the bootstrap compiler. No Profile 8, BSBC-format change, normal production compiler routing change, or creator-facing runtime-meaning change is introduced.
