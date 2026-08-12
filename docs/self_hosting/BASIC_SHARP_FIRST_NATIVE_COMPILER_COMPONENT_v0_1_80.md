# BASIC# v0.1.80 First BASIC#-Authored Compiler Component

BASIC# v0.1.80 Self-Hosting Milestone 2 Slice 7 introduces the first bounded compiler-domain component whose decision rules are authored in BASIC# source and executed from BSharp Bytecode.

The canonical source is `compiler/native/first_bsharp_compiler_component.bsharp`. It classifies the nine accepted compiler block heads (`KINDS`, `DEFINE`, `START`, `WHEN`, `IF`, `OTHERWISE`, `CONTROLS`, `HOVER`, and `CONTEXT`) into deterministic parser decisions using only already-accepted BASIC# syntax. The accepted v0.1.79 independent compiler driver compiles that source into `compiler/native/first_bsharp_compiler_component.bsbc`; the independent loader and independent BSharp VM execute the persisted artifact without requiring the source file.

This is intentionally a small compiler decision kernel. It proves that BASIC# can author executable compiler-domain logic without claiming that the complete compiler is self-hosted. Ruby remains bootstrap compiler and referee authority, and the production compiler remains a separate parity referee.

Acceptance requires deterministic source, BSharp IR, BSBC, disassembly, and compiler decisions; source-free artifact execution; disabled production constructors on the primary proof path; byte-for-byte production emitter parity; production VM and Ruby Runtime semantic parity; unchanged Profiles 1 through 7; and the complete release validation furnace.

No new creator-facing syntax is introduced. The existing opening `(` action-word visual guide and written action order remain authoritative.

Governing self-hosting contract: `spec/self_hosting/BASIC_SHARP_SELF_HOSTING_SUBSET_v1.json`.
