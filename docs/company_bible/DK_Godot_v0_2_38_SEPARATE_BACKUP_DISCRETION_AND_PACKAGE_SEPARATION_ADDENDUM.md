# Company Bible Addendum - v0.2.38 Separate Backup Discretion And Package Separation

Date: 2026-07-04
Status: Mandatory
Scope: All future DK / Demon Killer Godot builds, patches, repairs, documentation operations, and safety backups

## Owner Authorization

Derek grants the assistant continuing discretion to create an additional separate backup download whenever the assistant judges that the work carries enough risk to justify extra insurance.

A new permission request is not required for each individual safety backup.

## Required Separation

Every discretionary safety backup must:

- remain outside the active Godot project and outside `res://`;
- be provided separately from the changed-files patch/build ZIP;
- use a clear versioned name describing what was backed up and why;
- never be hidden inside the installation package;
- never be stored as a loose backup inside the project tree.

The changed-files patch must remain a clean installation package containing only active changed project files and its required documentation, logs, patch notes, and manifest.

## Communication

When a discretionary backup is created, the assistant must explain:

- what was backed up;
- why the backup was warranted;
- that it is separate from the patch;
- that it should remain outside the active project unless recovery is required.

## One-Download Clarification

When Derek asks for one download, that instruction means one main changed-files patch download unless he explicitly states that no separate safety backup should be supplied.

A safety backup may therefore appear as an additional, clearly separated download when warranted, but it may never be bundled inside the patch merely to reduce the number of links.

## Limits

This authorization is not permission to create unnecessary backup clutter. Use it when the change touches high-risk files, large interconnected systems, critical scenes, project identity, or other state where rollback insurance is reasonably valuable.
