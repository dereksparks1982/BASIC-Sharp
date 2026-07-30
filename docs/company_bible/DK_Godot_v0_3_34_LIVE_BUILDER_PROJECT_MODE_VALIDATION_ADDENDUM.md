# DK Godot v0.3.34 Live Builder Project-Mode Validation Addendum

**Date:** 2026-07-09  
**Status:** Mandatory workflow correction  
**Scope:** DK Live Builder local project validation

## Superseding validation command rule

The earlier Company Bible instruction describing **Validate Current Project** as a fixed `--headless --import` check is superseded.

DK Live Builder must not start a second Godot editor/import process against the same already-open project when that route causes installed Windows GDExtensions to fight over editor-owned temporary DLL files.

The approved validation route is now:

```text
current Godot executable
    --headless
    --path <current project root>
    --script <fixed DK validation runner>
```

The runner must remain fixed, inspectable, project-owned, and non-arbitrary. It scans and loads approved project resource types through Godot itself and returns a machine-readable summary.

## Validation integrity remains mandatory

A repair may change the validation route, but it may not weaken the gate. Validation passes only when all of the following are true:

- Godot starts successfully;
- the runner returns its expected summary;
- the runner reports zero load failures;
- Godot reports zero warnings;
- Godot reports zero errors;
- the process exits with code `0`.

Do not hide, suppress, reclassify, or ignore genuine project warnings or errors merely to obtain a green report.

## LimboAI descriptor rule

Do not carry the ineffective v0.3.33 `reloadable = false` edit as a permanent local modification. The supplied LimboAI descriptor is restored. Compatibility is handled in DK Live Builder's process architecture rather than by altering the dependency without effect.

## Preserved authority boundaries

This correction does not grant shell access, arbitrary command execution, networking, silent production edits, or wider write authority. Guarded apply, exact Undo, external validation reports, and separate owner approval requirements remain in force.
