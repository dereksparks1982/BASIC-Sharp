# BASIC# v0.1.78 Small Compiler Subset Integrated Independent Compiler Pipeline

BASIC# v0.1.78 adds Self-Hosting Milestone 2 Slice 5 by connecting the bounded Subset 0 compiler stages behind one `SmallCompilerSubsetPipeline` source-to-world path.

The primary path is:

```text
TokenizerReader
-> SmallCompilerSubsetParser
-> SmallCompilerSubsetSemanticResolver
-> BSharp IR
-> SmallCompilerSubsetBSBCEncoder
-> BSharp Bytecode
-> SmallCompilerSubsetBSBCLoader
-> SmallCompilerSubsetBSBCVirtualMachine
```

`SmallCompilerSubsetPipeline` owns the orchestration of those bounded stages. Its primary path must remain usable when production `Lexer`, `Parser`, `SemanticResolver`, `BytecodeEmitter`, `BytecodeLoader`, `BytecodeVirtualMachine`, and `Runtime` constructors are disabled. Those production Ruby components remain separate referees for exact parity only.

`TokenizerReader` is strengthened in this slice so primary line/comment records no longer require the production `Lexer`. Exact Lexer comparison remains available as a referee path.

Acceptance requires exact BSharp IR, BSBC bytes, loader summary, event-result, final-world, BSharp Save, and deterministic replay parity on the dedicated Profile 7 fixture. Profiles 1 through 7 remain unchanged.

No new creator-facing syntax is added. Existing BASIC# statement boundaries, official action-word visual guides such as `(open`, `(close`, `(lock`, and `(take`, and written action order remain unchanged. Compiler complexity stays inside the compiler rather than being exposed as conventional programming syntax.

This is not full self-hosting. Ruby remains the bootstrap compiler and referee authority. Normal production BASIC# compilation and runtime routing remain unchanged.

Canonical self-hosting contract: `spec/self_hosting/BASIC_SHARP_SELF_HOSTING_SUBSET_v1.json`.
Machine-checked Slice 5 contract: `spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_PIPELINE_INDEPENDENCE_v1.json`.
