# BASIC# Patch Notes v0.1.50

v0.1.50 teaches the small compiler subset to emit BSharp IR while Ruby remains the referee.

## Added

- `compiler/small_compiler_subset_ir_emitter.rb`
- `spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_IR_EMITTER_v1.json`
- `tests/test_small_compiler_subset_ir_emitter.rb`
- `tools/small_compiler_subset_ir_emitter.rb`
- `docs/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_IR_EMITTER_v0_1_50.md`
- v0.1.50 build handshake, validation, changelog, session log, runtime contract, and changed-files record

## Preserved

- Existing Ruby bootstrap compiler path
- Existing production parser and resolver authority
- Profiles 1 through 7
- BSharp Bytecode Profiles 1 through 7
- BSharp VM preferred runtime
- Movement/input contracts
- Tokenizer/reader and small parser contracts

## Not included

No Profile 8, new creator-facing syntax, production parser migration, runtime behavior change, bytecode change, web export, browser, engine bridge, or Ruby retirement.
