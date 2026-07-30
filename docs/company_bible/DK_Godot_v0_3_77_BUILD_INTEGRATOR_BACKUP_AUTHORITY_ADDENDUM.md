# DK Godot v0.3.77 Build Integrator Backup Authority Addendum

**Date:** 2026-07-11  
**Status:** Mandatory workflow rule  
**Scope:** Every Demon Killer numbered build, patch, and repair

## Rule

The DK Dev Companion Build Integrator is the default backup and rollback authority.

- Deliver one changed-files-only ZIP by default.
- Do not create a separate safety-backup ZIP for every patch.
- Create an additional backup only when Derek explicitly requests one, the Build Integrator is unavailable or damaged, or an exceptional recovery risk is explained before packaging.
- Keep the installation baseline, changed-file scope, canonical handoff, and rollback expectations current in every package.

## Reason

The Build Integrator was created to preserve the installed baseline and provide rollback. Repeating that work with a second archive adds clutter, encourages installation mistakes, and creates competing recovery authorities.

## v0.3.77 application

v0.3.77 is delivered as one changed-files-only patch over accepted v0.3.76. No separate safety-backup archive is included.
