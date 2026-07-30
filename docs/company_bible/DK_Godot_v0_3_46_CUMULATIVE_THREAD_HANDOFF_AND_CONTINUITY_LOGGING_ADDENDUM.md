# DK Godot v0.3.46 Cumulative Thread Handoff and Continuity Logging Addendum

**Date:** 2026-07-10
**Status:** Mandatory
**Scope:** Every future Demon Killer and Elderred Interactive numbered deliverable

## Owner direction

Derek directed that every update or patch must carry a handoff because OpenAI may abruptly end a long project thread and require a new one. He further directed that DK must not create a growing pile of separate handoff files. The project will use one long cumulative document so the current state and the full transfer history can be read in one place.

## Canonical handoff

The only active thread-transfer authority is:

```text
docs/hand_off/DK_MASTER_THREAD_HANDOFF.md
```

Beginning with v0.3.46:

- every build, update, patch, hotfix, repair, tool release, validation package, and equivalent numbered deliverable must update this file;
- the current transfer state at the top must be rewritten for the new version;
- a dated/versioned history entry must be appended below;
- no new per-version `HANDOFF_...` file is created;
- legacy individual handoffs remain preserved as read-only historical source records;
- the legacy handoff archive is imported into the master document so the project history can be viewed in one continuous record.

## Required current-state contents

The top section must identify at minimum:

- current numeric project version and build title;
- installation baseline and package type;
- exact completed work;
- unfinished work and known Goblins;
- validation and automated patrol status;
- protected files and systems;
- changed-file scope;
- owner decisions that govern the next thread;
- the next authorised or proposed action;
- installation and test requirements.

## Completion gate

A numbered deliverable is not complete, validated, packaged, or handed off until the canonical master handoff is current and included. The package manifest and changed-files record must list it.

## Relationship to other records

The master handoff does not replace:

- changelogs;
- patch notes;
- session/development logs;
- changed-files records;
- validation reports;
- system or migration documents;
- manifests and package hash records.

Those records remain mandatory. The master handoff is the continuity spine connecting them.

## Platform-reality rule

The assistant cannot control when the platform ends a thread and must not pretend to know a hidden message countdown. The defensive response is to keep the project state recoverable after every numbered deliverable through complete, cumulative records.
