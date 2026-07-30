# Company Bible Addendum: Door Template Creation v0.2.04

Date: 2026-07-02

## Rule

Do not use raw Ctrl+C/Ctrl+V copies of placed doors as the standard DK door creation workflow.

Door creation must use the DK template tool:

```text
Select DoorTemplate* + target Cell* root → DK: Create Door From Selected Template
```

The created door must be placed directly under the target cell and receive the next higher global door number.

## Numbering Rule

New placed doors use max-plus-one global numbering. If `Door28` exists, the next created door is `Door29`.

## Undo Safety Rule

The copy guard must not auto-reparent nested pasted doors during Godot's paste/undo transaction. Warning is allowed. Automatic movement during paste is forbidden because it can corrupt the editor undo parent expectation.
