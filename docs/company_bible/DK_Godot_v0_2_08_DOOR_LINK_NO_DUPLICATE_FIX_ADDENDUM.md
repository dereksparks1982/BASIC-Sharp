# DK Godot v0.2.08 - Door Link No Duplicate Fix Addendum

## Company Bible Rule

Door linking is link-only.

`DK: Link Selected Doors` must never create new doors, convert templates into real doors, adopt floating nodes, infer a target cell for a template, or duplicate anything.

## Correct Door Workflow

1. Use/copy `DoorTemplateNorth`, `DoorTemplateSouth`, `DoorTemplateEast`, or `DoorTemplateWest` only as palette/template material.
2. If a copied template is needed, it may become `DoorTemplateNorth1`, `DoorTemplateSouth1`, etc.
3. To make a real placed door, select one `DoorTemplate*` plus the target `Cell*` root and run `DK: Create Door From Selected Template`.
4. The creation command creates the next global real `Door#` directly under the target cell.
5. Only after two real `Door#` nodes exist should `DK: Link Selected Doors` be used.

## Why This Exists

Derek observed that linking `DoorTemplateNorth1` and `DoorTemplateSouth1` immediately created real doors `Door28` and `Door29`. That made the link command behave like a hidden creation command and produced duplicate/stacked door visuals.

The v0.2.08 rule separates those jobs: templates create doors only through the create command, and the link command only links real doors.

## Package Discipline

- Changed-files-only patch.
- Visible version updated to v0.2.08.
- No SHA/checksum file unless Derek asks.
- `scenes/Main.tscn` was not touched.
