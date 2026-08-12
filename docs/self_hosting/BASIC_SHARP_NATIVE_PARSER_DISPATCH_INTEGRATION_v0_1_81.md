# BASIC# v0.1.81 Native Parser Dispatch Integration

BASIC# v0.1.81 Self-Hosting Milestone 2 Slice 8 moves the accepted BASIC#-authored compiler decision kernel from a side proof into the bounded independent parser path.

`SmallCompilerSubsetParser` now asks `SmallCompilerSubsetNativeDispatch` to execute the checked-in `compiler/native/first_bsharp_compiler_component.bsbc` artifact whenever it encounters a possible block Head. The parser receives one of the native decisions such as `parse-kind-section`, `parse-event-rule`, or `parse-condition-rule`, then validates the source-line shape required by that decision. The parser no longer carries its former second hard-coded accepted-head dispatch table.

The integration is deliberately fail-closed. An unrecognized Head is rejected. A deliberately sabotaged native artifact that returns the wrong route causes visible parser failure instead of falling back to the old Ruby dispatch logic.

The v0.1.81 bootstrap sequence is fenced and deterministic. The accepted v0.1.80 native BSBC artifact compiles the v0.1.81 BASIC# component source into generation #1. Generation #1 is then used as the parser-dispatch artifact for a second compilation. Generation #1 and generation #2 must be byte-identical and disassembly-identical, and generation #2 must match the checked-in v0.1.81 artifact.

Ruby remains the bootstrap compiler and referee authority. Production `Parser`, `SemanticResolver`, `BytecodeEmitter`, `BytecodeLoader`, `BytecodeVirtualMachine`, and `Runtime` stay outside the bounded primary proof path and remain separate referees. This is not full self-hosting and does not retire Ruby.

No creator-facing syntax changes. Profiles 1 through 7, BSharp Bytecode layout, Save, ASK, input behavior, the opening `(` visual guide on official action words, and written action order remain unchanged.
