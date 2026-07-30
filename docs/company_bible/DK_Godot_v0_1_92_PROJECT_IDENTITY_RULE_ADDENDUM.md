# Company Bible Addendum - Project Identity Rule

Version: v0.1.92
Date: 2026-07-02

## Project Identity Rule

Every accepted DK build that includes `project.godot` must keep the Godot project identity current.

The Godot project name should reflect the current accepted build version:

```text
DK Godot vX.X.XX
```

Do not leave old restore labels, old patch names, or stale version names in `application/config/name` after the project has moved forward.

## Main Safety Note

This build does not touch or include `scenes/Main.tscn`, so no Main scene backup is required inside this package.
