# DKScript Build Handshake v0.1.08

## Project

DKScript Ruby Bootstrap Compiler

## Version

v0.1.08

## Build name

Body Structure and User Kinds

## Required base version

Accepted v0.1.07 in DKLab.

## Target version

v0.1.08

## Package filename

DKScript_Ruby_Bootstrap_Compiler_v0_1_08_BODY_STRUCTURE_AND_USER_KINDS_CHANGED_FILES_ONLY.zip

## Active project path

```text
/home/dereksparks1982/DKLab/Projects/DKScript
```

## Download location expectation

```text
/home/dereksparks1982/Downloads/
```

## Completed changes

- Updated compiler version to `0.1.08`.
- Added required Body opening `[` and End `].`.
- Removed support for the old repeated `<` child structure.
- Added the `KINDS` Head.
- Added user-defined Kind declarations such as `dragon is a creature`.
- Added parent-Kind validation and duplicate-Kind errors.
- Added user-defined Kinds to the AST and DKIR debug JSON.
- Kept `<then>` and `<than>` as equivalent Results.
- Added the approved `there / their` location-word pair to the core dictionary.
- Updated compiler messages to use Head, Body, Kind, Thing, Fact, Trigger, Result, Order, and End.
- Updated all samples and tests to the new structure.
- Added a direct test proving the old structure fails.

## Excluded work

- No old-structure compatibility layer.
- No runtime execution.
- No bytecode.
- No VM.
- No self-hosted compiler.
- No DK Engine.
- No Godot integration.
- No full Inform or TADS dictionary import.

## Changed files

```text
README.md
BUILD_HANDSHAKE_v0_1_08.md
compiler/ast_nodes.rb
compiler/dictionary.rb
compiler/dks.rb
compiler/dks_ir.rb
compiler/parser.rb
compiler/resolver.rb
docs/parser_contract_v0_1_08.md
samples/first_room.dks
samples/first_room.ir.json
samples/errors/ambiguous_door.dks
samples/errors/bad_line_command.dks
samples/errors/old_structure.dks
samples/errors/unknown_action.dks
samples/errors/unknown_kind.dks
samples/errors/unknown_object.dks
samples/errors/unknown_state.dks
tests/test_cli_output.rb
tests/test_diagnostics_samples.rb
tests/test_first_room.rb
tests/test_ir_output.rb
tests/test_resolver.rb
```

## Validation plan

```bash
ruby -c compiler/ast_nodes.rb
ruby -c compiler/dictionary.rb
ruby -c compiler/dks.rb
ruby -c compiler/dks_ir.rb
ruby -c compiler/parser.rb
ruby -c compiler/resolver.rb
ruby compiler/dks.rb samples/first_room.dks
ruby compiler/dks.rb samples/first_room.dks --emit-ir --out samples/first_room.ir.json
ruby tests/test_first_room.rb
ruby tests/test_resolver.rb
ruby tests/test_ir_output.rb
ruby tests/test_cli_output.rb
ruby tests/test_diagnostics_samples.rb
```

## Validation result

- Ruby checks: PASS.
- Main sample: PASS, 0 errors, 0 warnings.
- DKIR output: PASS.
- All test files: PASS.
- Old structure rejection test: PASS.
- User Kind registration and DKIR emission: PASS.
- `<then>` and `<than>` Result handling: PASS.

## Known risks

- User Kind declarations currently support one-word Kind names and one-word parent names.
- `there / their` is recorded for later language use but no current statement depends on that location word.
- DKIR remains a human-readable debug format, not final runtime bytecode.

## Rollback point

```bash
git checkout v0.1.07
```

## Current continuation point

The compiler can next add inheritance-aware Kind behavior, richer Kind declarations, or begin the first small DKIR runtime skeleton after Derek chooses the direction.
