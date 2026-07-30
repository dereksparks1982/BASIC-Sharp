# Company Bible Addendum - Door Naming and Main Backup UID Safety

Version: v0.1.91
Date: 2026-07-02

## Global Door Naming Rule

DK door nodes must use globally unique numbered names across `Main/Cells`.

Use:

```text
Door1
Door2
Door3
Door4
Door5
```

Do not repeat `Door1`, `Door2`, etc. in every cell.

Do not use Godot emergency names such as:

```text
@Node2D@41139
_Node2D_41139
Node2D
```

## Main Backup UID Safety

Main backups are mandatory before Main builds, but live `.tscn` backup copies inside the Godot project tree can trigger duplicate UID warnings.

Warnings seen:

```text
UID duplicate detected between res://scenes/Main.tscn and res://Builds/Archive/main_copy.tscn
UID duplicate detected between res://scenes/main_copy.tscn and res://scenes/Main.tscn
```

## Rule Going Forward

If Derek explicitly asks for a standalone `Main.tscn` backup, deliver it standalone for external archiving.

Do not leave extra `main_copy.tscn` scene files inside the live Godot `res://` project unless Derek explicitly wants that file in the project and accepts the UID warning risk.

For normal packaged insurance backups, prefer an external archive package or non-imported backup format so Godot does not treat the backup as another live scene.
