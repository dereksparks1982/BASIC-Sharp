# BASIC# Changelog v0.1.50

## Small Compiler Subset Emits BSharp IR Under Ruby Referee

- Added `compiler/small_compiler_subset_ir_emitter.rb`.
- Added `spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_IR_EMITTER_v1.json`.
- Added `tests/test_small_compiler_subset_ir_emitter.rb`.
- Added `tools/small_compiler_subset_ir_emitter.rb`.
- Added `docs/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_IR_EMITTER_v0_1_50.md`.
- Advanced live BASIC# version truth to `0.1.50`.
- Regenerated current version-bearing runtime fixture hashes for v0.1.50.

## Guardrails

- Ruby remains the production parser, resolver, compiler path, and referee.
- Normal BASIC# compilation is not routed through the new subset IR emitter.
- No Profile 8, new syntax, runtime behavior change, BSharp Bytecode change, Save/ASK change, input-device change, web export, browser work, engine bridge, or Ruby retirement is included.
