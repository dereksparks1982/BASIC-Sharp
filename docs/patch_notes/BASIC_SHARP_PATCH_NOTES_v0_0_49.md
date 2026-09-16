# BASIC# Patch Notes v0.0.49

v0.0.49 starts the small compiler subset parser lane under Ruby referee control.

## Added

- `compiler/small_compiler_subset_parser.rb`
- `spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_PARSER_v1.json`
- `tests/test_small_compiler_subset_parser.rb`
- `tools/small_compiler_subset_parser.rb`
- `docs/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_PARSER_v0_0_49.md`
- v0.0.49 build handshake, validation, changelog, session log, runtime contract, and changed-files record

## Changed

- Live version surfaces now report `0.0.49`.
- Trial-by-Fire validation inventory now runs the small compiler subset parser gate.

## Not changed

The production parser remains `compiler/parser.rb`. No Profile 8, syntax, runtime, bytecode, web export, browser work, engine bridge, or Ruby retirement is included.
