# BSharp Bytecode Profile 7 v0.1.39

Profile identifier: `bsharp.bytecode.v7`; meaning identifier: `bsharp.meaning.v7`.

Profile 7 retains all Profile 6 opcodes and section layouts except IFRL records. Each Profile 7 IFRL record stores its condition reference, required IF action-block reference, optional OTHERWISE action-block reference, and source order. The absent OTHERWISE reference uses the canonical sentinel. Action blocks are emitted in deterministic event/IF/OTHERWISE order.

The loader validates every reference, reconstructs the two ordered action lists, and rejects noncanonical block ownership or trailing bytes. The disassembler prints `OTHERWISE BLOCK n` only when present. The VM executes the validated model directly. Profiles 1 through 6 retain their exact bytes and disassembly.
