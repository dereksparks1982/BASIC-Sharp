# DKScript Build Handshake v0.0.04

> **Historical naming note:** This record predates the v0.0.14 technical identity migration. At the time recorded below, BASIC# still used the working technical name `DKScript`. Old package names, commands, paths, and Git messages are preserved as audit history.


## Project

DKScript

## Version

v0.0.04 Semantic Resolver + Human-Readable IR Dump

## Required base

Accepted DKScript v0.0.03 Ruby Bootstrap Compiler Prototype.

## Target package

DKScript_Ruby_Bootstrap_Compiler_v0_0_04_SEMANTIC_RESOLVER_AND_IR_OUTPUT_CHANGED_FILES_ONLY.zip

## Completed changes

- Updated compiler version to `0.0.04`.
- Added semantic resolver.
- Added BSharp IR debug document structure.
- Added IR emitter.
- Added `--emit-ir` compiler option.
- Preserved `--json` and added `--emit-ast` alias for AST output.
- Added generated sample IR file.
- Added semantic resolver and IR tests.
- Added v0.0.04 parser contract documentation.
- Updated README.

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
- `BUILD_HANDSHAKE_v0_0_04.md`
- `compiler/ast_nodes.rb`
- `compiler/basic_sharp.rb`
- `compiler/basic_sharp_ir.rb`
- `compiler/ir_emitter.rb`
- `compiler/resolver.rb`
- `docs/parser_contract_v0_0_04.md`
- `samples/first_room.bsir.json`
- `tests/test_resolver.rb`
- `tests/test_ir_output.rb`

## Validation

Run from package root after applying over v0.0.03:

```bash
ruby compiler/basic_sharp.rb samples/first_room.bsharp
ruby compiler/basic_sharp.rb samples/first_room.bsharp --emit-ir
ruby compiler/basic_sharp.rb samples/first_room.bsharp --emit-ir --out samples/first_room.bsir.json
ruby tests/test_first_room.rb
ruby tests/test_resolver.rb
ruby tests/test_ir_output.rb
```

Expected: compiler reports zero errors and zero warnings for `samples/first_room.bsharp`; all tests pass.

## Validation result from package creation

- `ruby compiler/basic_sharp.rb samples/first_room.bsharp`: PASS, 0 errors, 0 warnings.
- `ruby compiler/basic_sharp.rb samples/first_room.bsharp --emit-ir`: PASS.
- `ruby tests/test_first_room.rb`: PASS.
- `ruby tests/test_resolver.rb`: PASS.
- `ruby tests/test_ir_output.rb`: PASS.

## Known risks

- BSharp IR is a debug JSON dump for inspection only. It is not the final DKScript bytecode or permanent file format.
- Event parsing is intentionally simple. It only normalizes basic trailing-s verbs such as `takes` and `attacks`.
- Resolver allows known kinds such as `the table` even when no specific table object was defined, to keep the first sample permissive.
- Natural-language resolution is still strict and small by design.

## Rollback point

```bash
git checkout v0.0.03
```

## Current continuation point

Next build should add the first runtime skeleton that can load BSharp IR debug output into an in-memory world state and apply START facts. It should not build the DK Engine yet.
