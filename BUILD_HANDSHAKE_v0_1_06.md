# DKScript Build Handshake v0.1.06

> **Historical naming note:** This record predates the v0.1.14 technical identity migration. At the time recorded below, BASIC# still used the working technical name `DKScript`. Old package names, commands, paths, and Git messages are preserved as audit history.


## Project

DKScript Ruby Bootstrap Compiler

## Version

v0.1.06

## Build name

Natural Language Error Samples + Ambiguity Tests

## Required base version

Accepted v0.1.05 in DKLab.

## Target version

v0.1.06

## Package filename

DKScript_Ruby_Bootstrap_Compiler_v0_1_06_NATURAL_LANGUAGE_ERROR_SAMPLES_AND_AMBIGUITY_TESTS_CHANGED_FILES_ONLY.zip

## Active project path

```text
/home/dereksparks1982/DKLab/Projects/DKScript
```

## Download location expectation

```text
/home/dereksparks1982/Downloads/
```

## Completed changes

- Updated compiler version constant to `0.1.06`.
- Added bad-script samples for unknown object, unknown kind, unknown state, unknown action, ambiguous door reference, and bad line command tags.
- Added diagnostics sample test harness.
- Added parser validation for unknown line-command tags, with a direct `<then>` suggestion.
- Updated README with v0.1.06 diagnostic sample notes.
- Added parser contract v0.1.06.
- Refreshed sample BSharp IR output to version `0.1.06`.

## Excluded work

- No runtime execution.
- No bytecode.
- No VM.
- No self-hosted compiler.
- No DK Engine.
- No Godot integration.
- No full Inform/TADS dictionary import.

## Changed files

```text
README.md
BUILD_HANDSHAKE_v0_1_06.md
compiler/ast_nodes.rb
compiler/parser.rb
docs/parser_contract_v0_1_06.md
samples/first_room.bsir.json
samples/errors/unknown_object.bsharp
samples/errors/unknown_kind.bsharp
samples/errors/unknown_state.bsharp
samples/errors/unknown_action.bsharp
samples/errors/ambiguous_door.bsharp
samples/errors/bad_line_command.bsharp
tests/test_diagnostics_samples.rb
```

## Validation commands

```bash
ruby compiler/basic_sharp.rb samples/first_room.bsharp
ruby compiler/basic_sharp.rb samples/first_room.bsharp --emit-ir
ruby compiler/basic_sharp.rb samples/first_room.bsharp --emit-ir --out samples/first_room.bsir.json
ruby tests/test_first_room.rb
ruby tests/test_resolver.rb
ruby tests/test_ir_output.rb
ruby tests/test_cli_output.rb
ruby tests/test_diagnostics_samples.rb
```

## Expected validation

```text
errors: 0
warnings: 0
all tests pass
```

## Known risks

- Error samples intentionally produce errors when run as compiler inputs. Their tests assert the errors are understandable.
- Natural-language parsing remains intentionally strict. This build improves diagnostics, not broad English understanding.

## Rollback point

```bash
git checkout v0.1.05
```

## Next planned work

v0.1.07 should begin tightening the actual world model and/or introduce a first tiny runtime interpreter loop for the BSharp IR debug format, depending on Derek's direction.
