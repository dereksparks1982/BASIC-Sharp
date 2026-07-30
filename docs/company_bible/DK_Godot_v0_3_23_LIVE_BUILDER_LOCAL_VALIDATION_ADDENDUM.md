# Company Bible Addendum - DK Live Builder Local Validation

**Build:** DK Godot v0.3.23  
**Status:** Mandatory workflow rule

## Local validation rule

DK Live Builder is the preferred local doorway for Godot project validation and basic smoke testing.

Open it from:

```text
Project > Tools > DK Live Builder
```

Use **Validate Current Project** to run the installed Godot editor's fixed headless import check. Warnings are failures. Use **Run Main Scene Test** for the local visual smoke test.

## Reporting rule

Do not repeatedly tell the owner that Godot is absent from an external packaging environment when DK Live Builder can perform the test locally. Report the actual Live Builder result instead when one is available.

A new, specific validation failure may still be explained plainly. Do not recycle generic boilerplate.

## Authority boundary

Local validation and run/stop control do not grant silent or unlimited project authority.

The Live Builder must continue to:

- use fixed, inspectable validation commands;
- keep reports outside `res://`;
- preserve warnings-as-errors;
- preserve guarded apply and exact Undo;
- reject arbitrary commands, shell access, networking, and unapproved production edits;
- require separate approval before widening write authority.
