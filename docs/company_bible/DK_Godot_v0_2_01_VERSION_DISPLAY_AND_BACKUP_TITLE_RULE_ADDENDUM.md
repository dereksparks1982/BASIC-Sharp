# Company Bible Addendum - Version Display and Backup Title Rule

Version: v0.2.01
Date: 2026-07-02

## Version Display Rule

Every DK patch/build with a new version number must update the project-facing version when the project is opened.

Required version surfaces:

- `project.godot` project name
- `project.godot` application version when present
- runtime/editor-visible build labels
- changelog title
- patch notes title
- session log title
- manifest title
- package ZIP title

Do not leave stale old labels such as `88`, `v0.1.88`, or older patch titles in active project identity fields after a new numbered patch/build is made.

## Backup Title Rule

Every backup must include the version number in the backup title/name.

Examples:

```text
Main_backup_v0.2.01.tscn
Main_insurance_backup_v0.2.01.tscn
DK_v0.2.01_Main_prepatch_backup.tscn
```

Do not use vague backup names such as:

```text
main_copy.tscn
Main_backup.tscn
Archive_Main.tscn
```

## Main UID Safety Reminder

Main backups must not be left as live copied `.tscn` files inside active `res://` project folders unless they are UID-safe and deliberately meant to be imported.

Prefer external backup packages or non-imported backup storage so Godot does not treat a copied `Main.tscn` as another active scene with a duplicate UID.

## Current Patch Note

This v0.2.01 patch does not edit or include `scenes/Main.tscn`, so no Main backup is required inside this package.
