# Company Bible Addendum: v0.2.17 No In-Project Scene Backups Repair

## Rule Supersession
Any older rule or note that suggests storing `Main.tscn` backups inside `res://scenes`, `res://docs`, or anywhere else under the active Godot project folder is superseded.

## Current Mandatory Rule
Scene backups for `Main.tscn` or other key Godot scenes must be created outside the active project folder.

No exceptions.

## Reason
Godot imports `.tscn` files under `res://`. Keeping copied scene backups inside the active project can cause duplicate scene UID warnings, stale editor cache problems, and confusing leftover visual data.

## Current Repair
The stale in-project scene backup `scenes/main_copy_v0_2_11_PRE_DOOR_CLEANUP.tscn` was removed from the clean v0.2.17 project package.
