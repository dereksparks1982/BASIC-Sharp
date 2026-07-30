# Company Bible Addendum: v0.2.14 Door Copy Promotion Hotfix

## Door Copy Rule
When Derek copies a numbered door, the copy must not remain nested inside the source door and must not keep the same Door number. The editor guard must promote the copied door to the correct sibling/owning parent and assign the next highest global Door number.

Example: if Door28 exists, copying Door1 must create Door29, not Door1/Door1.

## Backup Rule Reinforcement
Scene backups for Main.tscn or other key Godot scenes must not be stored inside the active project resource tree (`res://`). Backups must be created outside the project folder so Godot does not import them or report duplicate scene UID warnings. No exceptions.

## Build Discipline Reinforcement
Do not delete working objects, do not undo established fixes, do not change unrelated systems, and do not create a build unless Derek explicitly approves it.
