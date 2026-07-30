# Company Bible Addendum - v0.2.12 Door Orphan Cleanup

## Cleanup Rule Reinforcement
When deleting scene nodes manually or by script, verify that no child node records remain in `.tscn` files with vanished parent paths. Godot can instantiate the scene while warning about orphan child records.

## Backup Rule Reinforcement
Do not keep copied `.tscn` backups inside active `res://scenes` with the same UID as the live scene. If a scene backup must be shipped inside a changed-files package, prefer a non-importing extension such as `.tscn.bak` under `docs/backups`, or ensure any temporary scene-copy UID is unique.
