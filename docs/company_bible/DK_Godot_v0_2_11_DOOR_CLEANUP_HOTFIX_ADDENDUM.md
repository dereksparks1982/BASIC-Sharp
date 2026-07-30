# Company Bible Addendum - Door Cleanup Safety

Version: v0.2.11
Date: 2026-07-03

## Rule
When cleaning copied/manual doors, remove only confirmed duplicate or dead doors unless Derek explicitly orders broader map rebuilding.

## Practical Meaning
- Duplicate doors are doors in the same cell on the same side targeting the same cell with nearly identical placement.
- Dead doors are copied/manual doors with no `target_cell`, no linked counterpart, and no confirmed design purpose.
- Do not invent replacement door targets when the intended target cell is unknown.
- Preserve manual links when they are valid, even if their metadata needs small correction.
- If `scenes/Main.tscn` is changed, include a clearly labelled Main backup in the changed-files package.
