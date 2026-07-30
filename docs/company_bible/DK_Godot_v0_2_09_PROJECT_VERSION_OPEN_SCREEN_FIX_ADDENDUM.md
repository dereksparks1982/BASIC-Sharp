# DK Godot v0.2.09 - Project Version Open Screen Fix Addendum

## Mandatory rule

Every numbered patch/build must update the Godot-visible project identity every time, with no exceptions.

The fields updated in this patch are:

```text
project.godot -> config/name="DK Godot v0.2.09 PROJECT VERSION OPEN SCREEN FIX"
project.godot -> application/config/name="DK Godot v0.2.09"
project.godot -> application/config/version="0.2.09"
scripts/world/DKWorld.gd -> build_version="DK Godot v0.2.09 - PROJECT VERSION OPEN SCREEN FIX"
scenes/NewMap.tscn -> build_version="DK Godot v0.2.09 - PROJECT VERSION OPEN SCREEN FIX"
addons/dk_door_linker/plugin.cfg -> version="0.2.09"
```

## Packaging rule carried forward

- No checksum file unless Derek asks.
- No loose notes at ZIP root.
- No duplicate top-level wrapper folder.
- Documentation/logs stay under `docs/`.
