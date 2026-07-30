# DKScript Build Handshake v0.1.05

> **Historical naming note:** This record predates the v0.1.14 technical identity migration. At the time recorded below, BASIC# still used the working technical name `DKScript`. Old package names, commands, paths, and Git messages are preserved as audit history.


## Project

DKScript

## Version

v0.1.05 Semantic Diagnostics + IR File Output

## Required base

Accepted DKScript v0.1.04 Semantic Resolver + Human-Readable IR Dump in `/home/dereksparks1982/DKLab/Projects/DKScript`.

## Target package

DKScript_Ruby_Bootstrap_Compiler_v0_1_05_SEMANTIC_DIAGNOSTICS_AND_IR_FILE_OUTPUT_CHANGED_FILES_ONLY.zip

## Completed changes

- Updated compiler version to `0.1.05`.
- Made DKLab the forward source-of-truth path in project instructions.
- Added the DKScript non-programmer positioning note to README and docs.
- Added slogan candidates:
  - `The scripting language for non-programmers.`
  - `So easy a caveman could grasp it.`
- Updated the golden sample to define `oak table`.
- Resolved `the table` to the single defined table object when exactly one table exists.
- Added semantic warning for unresolved definite references such as `the table` when no table object exists.
- Improved unknown reference wording.
- Added safer `--out` handling with parent-directory creation for AST and DKIR output.
- Added an explicit error when `--out` is missing its path.
- Added CLI tests for IR file output and missing `--out` path.
- Updated resolver and IR tests for v0.1.05.
- Added v0.1.05 parser contract documentation.
- Generated updated `samples/first_room.ir.json`.

## Excluded work

- No runtime execution.
- No bytecode emitter.
- No binary compiler output.
- No DK Engine.
- No self-hosted DKScript compiler.
- No full Inform/TADS dictionary import.
- No Godot integration.

## Changed files

- `README.md`
- `BUILD_HANDSHAKE_v0_1_05.md`
- `compiler/ast_nodes.rb`
- `compiler/basic_sharp.rb`
- `compiler/ir_emitter.rb`
- `compiler/resolver.rb`
- `docs/parser_contract_v0_1_05.md`
- `samples/first_room.bsharp`
- `samples/first_room.ir.json`
- `tests/test_first_room.rb`
- `tests/test_resolver.rb`
- `tests/test_ir_output.rb`
- `tests/test_cli_output.rb`

## Validation

Run from project root after applying over v0.1.04:

```bash
ruby compiler/basic_sharp.rb samples/first_room.bsharp
ruby compiler/basic_sharp.rb samples/first_room.bsharp --emit-ir
ruby compiler/basic_sharp.rb samples/first_room.bsharp --emit-ir --out samples/first_room.ir.json
ruby tests/test_first_room.rb
ruby tests/test_resolver.rb
ruby tests/test_ir_output.rb
ruby tests/test_cli_output.rb
```

Expected: compiler reports zero errors and zero warnings for `samples/first_room.bsharp`; all tests pass.

## Validation result from package creation

- `ruby compiler/basic_sharp.rb samples/first_room.bsharp`: PASS, 0 errors, 0 warnings.
- `ruby compiler/basic_sharp.rb samples/first_room.bsharp --emit-ir`: PASS.
- `ruby compiler/basic_sharp.rb samples/first_room.bsharp --emit-ir --out samples/first_room.ir.json`: PASS.
- `ruby tests/test_first_room.rb`: PASS.
- `ruby tests/test_resolver.rb`: PASS.
- `ruby tests/test_ir_output.rb`: PASS.
- `ruby tests/test_cli_output.rb`: PASS.

## Known risks

- DKIR is still a debug JSON dump for inspection only. It is not the final DKScript bytecode or permanent file format.
- Event parsing is intentionally simple. It only normalizes basic trailing-s verbs such as `takes` and `attacks`.
- Definite reference resolution only handles the simple case where exactly one object of a kind exists.
- Unresolved definite references are warnings in this build, not hard errors. This can be made stricter later.
- Natural-language resolution is still strict and small by design.

## Rollback point

```bash
git checkout v0.1.04
```

## Current continuation point

Next build should start the first tiny runtime skeleton that loads DKIR debug output into an in-memory world state and applies START facts. It should not build the DK Engine yet.
