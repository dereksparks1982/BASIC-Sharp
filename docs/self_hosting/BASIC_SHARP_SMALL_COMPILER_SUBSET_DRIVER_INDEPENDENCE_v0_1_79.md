# BASIC# v0.1.79 Small Compiler Subset Independent Compiler Driver

v0.1.79 advances Self-Hosting Milestone 2 Slice 6 by placing a bounded compiler-driver boundary in front of the accepted v0.1.78 integrated independent pipeline.

`SmallCompilerSubsetDriver` accepts BASIC# source text or a `.bsharp` source file, invokes `SmallCompilerSubsetPipeline`, and writes the independently encoded BSBC bytes as a real `.bsbc` artifact. The saved artifact is then reloaded only through `SmallCompilerSubsetBSBCLoader` and executed only through `SmallCompilerSubsetBSBCVirtualMachine` on the primary proof path.

Production `Parser`, `SemanticResolver`, `BytecodeEmitter`, `BytecodeLoader`, `BytecodeVirtualMachine`, and `Runtime` remain separate referees. The independence gate disables their constructors and requires the primary driver path to continue compiling, writing, reloading, and executing successfully.

The companion artifact-round-trip contract proves that the saved `.bsbc` bytes equal the in-memory bytes, repeated compilation is deterministic, the source file is unnecessary after artifact creation, and artifact execution reproduces the same event results, final world, and BSharp Save document as fresh in-memory execution and the separate referees.

This release introduces no new creator-facing syntax. Existing BASIC# statement boundaries, action-word visual guides such as `(open`, `(close`, `(lock`, and `(take`, and written action order remain unchanged. Compiler complexity remains inside the compiler.

This is not full self-hosting and does not retire Ruby. Profiles 1 through 7 and the existing BSBC binary layout remain unchanged.

The governing self-hosting boundary remains `spec/self_hosting/BASIC_SHARP_SELF_HOSTING_SUBSET_v1.json`.
