# DKScript Parser/Semantic Contract v0.1.06

> **Historical naming note:** This record predates the v0.1.14 technical identity migration. At the time recorded below, BASIC# still used the working technical name `DKScript`. Old package names, commands, paths, and Git messages are preserved as audit history.


## Build name

DKScript Ruby Bootstrap Compiler v0.1.06  
Natural Language Error Samples + Ambiguity Tests

## Positioning

DKScript is the scripting language for non-programmers.  
So easy a caveman could grasp it.

This build keeps the compiler-only lane. It does not add runtime execution, bytecode, Godot integration, or DK Engine behavior.

## Accepted source of truth

Active project path:

```text
/home/dereksparks1982/DKLab/Projects/DKScript
```

Downloaded ZIPs are expected directly under:

```text
/home/dereksparks1982/Downloads/
```

## Syntax contract carried forward

- Statement starters are uppercase: `DEFINE`, `START`, `WHEN`, `IF`, `WHILE`, `OTHERWISE`, `WORLD`, `STATES`, `RELATIONS`, `ACTIONS`.
- Child lines start with `<`.
- Line commands use tag form: `<then>` and accepted typo alias `<than>`.
- Dictionary actions use prefix marker form: `(damage`, `(change`, `(unlock`, etc.
- Action markers are not balanced wrappers.
- Only the last line of a statement needs a period.
- Proper names do not need `the`.
- Generic selectors include `a`, `the`, `every`, and `that`.

## New in v0.1.06

v0.1.06 adds bad-script diagnostic samples under:

```text
samples/errors/
```

These files intentionally contain mistakes. They are compiler teaching targets, not gameplay scripts.

Samples added:

```text
unknown_object.bsharp
unknown_kind.bsharp
unknown_state.bsharp
unknown_action.bsharp
ambiguous_door.bsharp
bad_line_command.bsharp
```

A new test harness validates these samples:

```bash
ruby tests/test_diagnostics_samples.rb
```

## Diagnostic expectations

The compiler should explain common mistakes in plain language:

```text
unknown reference 'ghost'
unknown kind 'dragon'
unknown state 'sleepy'
unknown action 'explode'
which door? found: north door, cellar door
unknown line command '<thne>'; did you mean <then>?
```

## Line command behavior

Known line commands:

```text
<then>
<than>
```

`<than>` remains an accepted alias for `<then>` because Derek sometimes swaps then/than while writing quickly.

Unknown line command tags now produce a direct parser error.

Example:

```text
<thne> (damage henry.
```

Expected diagnostic:

```text
unknown line command '<thne>'; did you mean <then>?
```

## Validation plan

Run from the DKScript project root:

```bash
ruby compiler/basic_sharp.rb samples/first_room.bsharp
ruby compiler/basic_sharp.rb samples/first_room.bsharp --emit-ir
ruby compiler/basic_sharp.rb samples/first_room.bsharp --emit-ir --out samples/first_room.ir.json
ruby tests/test_first_room.rb
ruby tests/test_resolver.rb
ruby tests/test_ir_output.rb
ruby tests/test_cli_output.rb
ruby tests/test_diagnostics_samples.rb
```

Expected result:

```text
errors: 0
warnings: 0
0 failures
0 errors
```

## Excluded work

- No runtime execution.
- No bytecode.
- No VM.
- No self-hosted DKScript compiler.
- No DK Engine.
- No Godot integration.
- No full Inform/TADS import.
- No broad natural-language parser beyond the current strict patterns.
