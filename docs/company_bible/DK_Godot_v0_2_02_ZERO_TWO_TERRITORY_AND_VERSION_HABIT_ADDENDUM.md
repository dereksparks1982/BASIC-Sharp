# Company Bible Addendum - v0.2 Territory Version Habit

Version: v0.2.02
Date: 2026-07-02
Status: Mandatory DK workflow rule

## v0.2 Territory Milestone

DK has crossed into the v0.2 line. This is a major project milestone, not a throwaway number bump.

After v0.1.99, the version line rolls to v0.2.01 and continues from there as v0.2.02, v0.2.03, and so on. Do not create v0.1.100-style builds.

## Project-Facing Version Must Update Every Time

Every numbered DK patch/build must update the visible project version when the project opens.

Required surfaces include:

- `project.godot` `config/name`
- `project.godot` `application/config/name`
- `project.godot` `application/config/version`
- exported/runtime build strings such as `DKWorld.gd` `build_version`
- scene-level build-version overrides such as `NewMap.tscn` when present
- changelog title
- patch notes title
- session log title
- manifest title
- package ZIP title

Leaving an old version label such as `88`, `v0.1.88`, or an older v0.2 label in active project identity fields is a Goblin.

## Backup Title Rule Reinforcement

Every backup title/name must include the version number.

Good examples:

```text
Main_backup_v0.2.02.tscn
Main_insurance_backup_v0.2.02.tscn
DK_v0.2.02_Main_prepatch_backup.tscn
```

Bad examples:

```text
main_copy.tscn
Main_backup.tscn
Archive_Main.tscn
```

Main backups must not sit inside active `res://` folders as live duplicate scene files unless they are UID-safe and deliberately imported. Prefer external version-labelled backup storage or packaged backup storage.

## Next Target Recorded

Next gameplay/system target after this v0.2 progress log is **WAR MODE**.

War Mode belongs in CODEX/design documentation and implementation patches, not as a Company Bible workflow rule. The Company Bible records it only as the next scheduled work target.

## Main Scene Note

This patch does not touch `scenes/Main.tscn`, so no Main backup was created or included.
