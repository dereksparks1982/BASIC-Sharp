# DKScript Parser Contract v0.1.07

> **Historical naming note:** This record predates the v0.1.14 technical identity migration. At the time recorded below, BASIC# still used the working technical name `DKScript`. Old package names, commands, paths, and Git messages are preserved as audit history.


## Build name

Diagnostic Deduping + Cascade Cleanup

## Required base

Accepted DKScript v0.1.06 in `/home/dereksparks1982/DKLab/Projects/DKScript`.

## Purpose

v0.1.07 does not add runtime execution. It cleans the compiler's voice.

v0.1.06 proved that bad DKScript samples produce errors. v0.1.07 makes those errors easier for non-programmers to trust by reporting each distinct problem once and avoiding follow-up errors caused only by an earlier typo.

## Diagnostic rules

- Parser diagnostics are for syntax/shape mistakes.
- Resolver diagnostics are for meaning mistakes.
- The same severity, line number, and message must not be emitted twice.
- Final diagnostics are sorted by line number.
- If two diagnostics share a line, errors appear before warnings.
- Unknown line-command typo recovery may treat an action-looking line as `<then>` after reporting the typo. This prevents a noisy second error such as `WHEN needs at least one <then> action line`.

## Sample behavior

`bad_line_command.bsharp` now reports only:

```text
ERROR: line 6: unknown line command '<thne>'; did you mean <then>?
```

`unknown_action.bsharp` now reports only:

```text
ERROR: line 6: unknown action 'explode'
```

`unknown_kind.bsharp` now reports only:

```text
ERROR: line 2: unknown kind 'dragon'
```

`unknown_object.bsharp` now reports only:

```text
ERROR: line 2: unknown reference 'ghost': not a defined object and not a known kind
```

`unknown_state.bsharp` now reports only:

```text
ERROR: line 5: unknown state 'sleepy'
```

`ambiguous_door.bsharp` still reports two errors because the ambiguous phrase occurs twice on two separate lines:

```text
ERROR: line 5: which door? found: north door, cellar door
ERROR: line 7: which door? found: north door, cellar door
```

## Excluded work

- No runtime execution.
- No bytecode.
- No VM.
- No self-hosted compiler.
- No DK Engine.
- No Godot integration.
- No full Inform/TADS dictionary import.

## Validation

Run from project root:

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
