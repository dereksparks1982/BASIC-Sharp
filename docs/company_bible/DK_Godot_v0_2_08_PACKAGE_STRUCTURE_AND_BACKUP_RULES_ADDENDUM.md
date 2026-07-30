# DK Godot v0.2.08 Package Structure and Backup Rules Addendum

## Rules locked by Derek

- Every numbered patch/build must update the visible project version every time, with no exceptions.
- Logs are mandatory every time and must stay under `docs/`, not at ZIP root.
- Patch notes, backup notes, archive reminders, manifests, changelogs, and session logs must live in the proper `docs/` folders.
- Do not place loose notes at the root of a package.
- Do not nest the package contents inside a duplicate top-level folder. Files must appear directly with project-relative paths.
- No SHA/checksum files unless Derek explicitly asks for one.
- Backup handshakes must be archived outside the active Godot project folder and must not create nested `project.godot` warnings inside `res://`.

## Current package context

This redo backup package preserves the current `v0.2.08` relevant files before door renumber / real-door cleanup work. It is not a new gameplay patch and does not bump the project version.
