# DK Godot v0.4.21 Audit Trail No-Scrub Rule Addendum

**Date:** 2026-07-13  
**Status:** Mandatory workflow rule  
**Scope:** Demon Killer game builds, Companion builds, handoffs, changelogs, manifests, validation notes, and failure logs

## Rule

Failed, contaminated, rejected, embarrassing, or cross-contaminated build information must not be silently deleted to make later docs look cleaner.

Corrections must be made by:

- appending a dated errata/correction note;
- adding a failure/audit log;
- superseding the bad information in a new current-state entry;
- or moving context only when explicitly labelled as audit history and approved.

## Reason

Derek explicitly rejected doc scrubbing after the v0.4.20 package contamination. Demon Killer records must show what happened so the project can recover cleanly after tool failures, thread failures, and bad package attempts.

## Application in v0.4.21

The v0.4.21 cleanup does not hide the dirty v0.4.20 trail. It records the contamination as audit history and advances only the current active project surfaces.
