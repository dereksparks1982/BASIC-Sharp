# BASIC# Company Bible Carryover v0.1.14

**Status:** Mandatory BASIC# project workflow record
**Imported:** 2026-07-30
**Project:** BASIC#
**Required base:** accepted v0.1.13, commit `3ae88bb`, tag `v0.1.13`

## Authority

The complete DK LAB Company Bible set is stored in this directory and must be read end-to-end before proposing or building future BASIC# versions.

Derek is the final decision-maker. No implementation begins until the exact scope has been stated and Derek gives explicit build or patch approval. If Derek says stop, all build and tool work stops immediately and the assistant answers him plainly.

## How the imported rules apply

- Company-wide workflow, safety, documentation, packaging, versioning, audit-trail, owner-authority, changed-files-only, rollback, validation, and post-acceptance Git rules apply to BASIC#.
- Godot, scene, map, visual, image, and game-specific rules apply only when BASIC# work actually touches those subjects.
- Historical game-specific records remain intact because the Company Bible forbids silently scrubbing failed, rejected, or older project history.
- Current BASIC# build records must use the active language identity: `BASIC#`, pronounced `Basic Sharp`, with `BasicSharp` or `basic_sharp` only where technical syntax cannot safely use `#`.

## BASIC# build discipline

Every BASIC# build must include:

- exact required base and target version;
- exact package filename;
- exact scope and exclusions;
- changed files and deletions;
- risks, rollback point, and validation plan;
- cumulative handoff and current continuation point;
- changed-files-only packaging by default;
- owner-side acceptance before the local Git commit and tag step.

## Current identity decision

Beginning with v0.1.14:

- Public and project name: `BASIC#`
- Spoken name: `Basic Sharp`
- Ruby namespace: `BasicSharp`
- Safe technical identifier: `basic_sharp`
- Creator source extension: `.bsharp`
- Former working name `DKScript` remains only where required to preserve historical truth.
