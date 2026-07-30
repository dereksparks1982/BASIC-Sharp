# Company Bible Addendum: Door Copy Workflow

Door source workflow remains:
- `Door1` through `Door4` are source doors in `DKDoorPalette`.
- Copying any source door must never leave a permanent `Door#/Door#` nested child.
- The copied door must become its own numbered `Door#` using the next highest global number.
- Existing doors and map geography must not be renumbered or deleted during copy workflow fixes.
- Fixes to editor tooling must preserve undo safety and must not cause Godot parent mismatch console errors.

Backup rule reminder:
- Main scene backups must be outside the active project folder when Main is edited.
- This patch did not edit `Main.tscn`, so no Main backup was included.
