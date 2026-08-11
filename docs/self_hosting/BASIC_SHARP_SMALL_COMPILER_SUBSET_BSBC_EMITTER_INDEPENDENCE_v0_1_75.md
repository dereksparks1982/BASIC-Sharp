# BASIC# v0.1.75 Small Compiler Subset BSBC Emitter Independence

BASIC# v0.1.75 advances Self-Hosting Milestone 2 with Slice 2: BSBC Emitter Independence.

`SmallCompilerSubsetBSBCEmitter` now gets its primary BSBC bytes from `SmallCompilerSubsetBSBCEncoder`. The independent encoder owns the accepted Subset 0 binary layout needed by Profiles 1 through 7 and does not require or call the production `BytecodeEmitter`.

The production Ruby `BytecodeEmitter` remains a separate referee. Every sealed fixture must match it byte for byte, must load through the accepted `BytecodeLoader`, and must execute through the BSharp Virtual Machine with Ruby referee parity.

The dedicated v0.1.75 fixture combines open, close, lock, take, whole-number increase, IF, and OTHERWISE so the new encoder is proved against a mixed real-language program rather than a toy artifact.

This is Self-Hosting Milestone 2 Slice 2, not full self-hosting. Ruby remains the bootstrap compiler and referee. Normal production compilation is unchanged. Profile 8 is not introduced and the BSBC binary format is unchanged.

Machine contract: `spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_BSBC_EMITTER_INDEPENDENCE_v1.json`.

Canonical bounded self-hosting contract: `spec/self_hosting/BASIC_SHARP_SELF_HOSTING_SUBSET_v1.json`
