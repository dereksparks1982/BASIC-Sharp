# DKScript Build Handshake v0.1.07

> **Historical naming note:** This record predates the v0.1.14 technical identity migration. At the time recorded below, BASIC# still used the working technical name `DKScript`. Old package names, commands, paths, and Git messages are preserved as audit history.


## Project

DKScript Ruby Bootstrap Compiler

## Version

v0.1.07

## Build name

Diagnostic Deduping + Cascade Cleanup

## Required base version

Accepted v0.1.06 in DKLab.

## Target version

v0.1.07

## Package filename

DKScript_Ruby_Bootstrap_Compiler_v0_1_07_DIAGNOSTIC_DEDUPING_AND_CASCADE_CLEANUP_CHANGED_FILES_ONLY.zip

## Active project path

```text
/home/dereksparks1982/DKLab/Projects/DKScript
```

## Download location expectation

```text
/home/dereksparks1982/Downloads/
```

## Completed changes

- Updated compiler version constant to `0.1.07`.
- Added diagnostic deduplication to `DiagnosticBag`.
- Added resolver-level final diagnostic cleanup and line ordering.
- Removed early parser semantic warnings for unknown kinds, objects, states, and actions so the resolver reports the final semantic error once.
- Added typo recovery for unknown line-command tags that contain an action, preventing a confusing missing-`<then>` cascade.
- Strengthened diagnostics sample tests to require exact one-error behavior for unknown object, unknown kind, unknown state, unknown action, and bad line command samples.
- Preserved two separate ambiguous-door errors because `the door` appears on two separate source lines.
- Updated README and parser contract documentation.
- Refreshed sample BSharp IR output to version `0.1.07`.

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
BUILD_HANDSHAKE_v0_1_07.md
compiler/ast_nodes.rb
compiler/diagnostics.rb
compiler/parser.rb
compiler/resolver.rb
docs/parser_contract_v0_1_07.md
samples/first_room.bsir.json
tests/test_cli_output.rb
tests/test_diagnostics_samples.rb
tests/test_ir_output.rb
```

## Validation

Run from project root after applying over v0.1.06:

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

## Validation result from package creation

- `ruby compiler/basic_sharp.rb samples/first_room.bsharp`: PASS, 0 errors, 0 warnings.
- `ruby compiler/basic_sharp.rb samples/first_room.bsharp --emit-ir`: PASS.
- `ruby compiler/basic_sharp.rb samples/first_room.bsharp --emit-ir --out samples/first_room.bsir.json`: PASS.
- `ruby tests/test_first_room.rb`: PASS.
- `ruby tests/test_resolver.rb`: PASS.
- `ruby tests/test_ir_output.rb`: PASS.
- `ruby tests/test_cli_output.rb`: PASS.
- `ruby tests/test_diagnostics_samples.rb`: PASS.
- Direct error sample sweep: PASS. Duplicate warning/error cascades removed.

## Known risks

- BSharp IR is still a debug JSON dump for inspection only. It is not final bytecode.
- Diagnostics are now cleaner but still minimal.
- Unknown-line-command recovery assumes an action-looking mistyped command was meant to be `<then>`.
- Natural-language resolution is still strict and small by design.

## Rollback point

```bash
git checkout v0.1.06
```

## Current continuation point

Next build can start the first tiny runtime skeleton that loads BSharp IR debug output into an in-memory world state and applies START facts, or can continue sharpening non-programmer diagnostics if Derek wants more compiler teeth first.
