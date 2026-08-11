# BASIC# Changelog v0.1.76

## Self-Hosting Milestone 2 Slice 3: BSBC Loader Independence

BSharp Compiler Subset 0 now owns an independent `SmallCompilerSubsetBSBCLoader` for its primary BSBC decode-and-validate path. The production Ruby `BytecodeLoader` remains a separate referee used only to prove exact trusted-model and rejection parity.

The execution corpus expands to 20 fixtures and 58 events. A dedicated Profile 7 fixture combines Kind inheritance, text and whole-number values, open, close, lock, take, and IF/OTHERWISE behavior, then proves the complete independent compiler chain through independently emitted BSBC, independently loaded trusted-model data, BSharp VM execution, and Ruby-referee runtime parity.

The loader trust boundary is exercised by a 16-mutation malformed-artifact campaign covering header, profile, section geometry, truncation, index, opcode, selector, condition, operand, target, count, and trailing-data failures. Ruby remains the bootstrap compiler. No Profile 8, BSBC-format change, normal production compiler routing change, or creator-facing runtime-meaning change is introduced.

Before Git acceptance, snapshot review caught stale canonical README current-build lines left from Slice 2. The v0.1.76 repair corrects those lines and hardens the README Current Release Truth Gate so the exact canonical current milestone/build lines are checked across the full README rather than only the introductory release block.
