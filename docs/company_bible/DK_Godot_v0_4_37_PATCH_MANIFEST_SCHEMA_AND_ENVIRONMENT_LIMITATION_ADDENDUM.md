# DK Godot v0.4.37 Company Bible Addendum - Patch Manifest Schema and Environment Handling

**Date:** 2026-07-14  
**Status:** Mandatory workflow rule

## Installable patch manifests

Every direct changed-files package must carry a top-level `DK_PATCH_MANIFEST.json` using `DK_CHANGED_FILES_PATCH`, format version 1. The exact package name, required base, target version, direct-root payload, changed-files-only status, and deletion array must be validated before ZIP creation and again after extraction.

Never substitute the non-installable legacy keys `package`, `version`, `changed_files`, and `deletions` for the accepted schema. Never modify DK Build Integrator to excuse a bad package. Repair the package instead.

## Environment limitation handling

When Godot runtime execution is unavailable in the build environment, record that limitation once in the Company Bible or active build documentation. Do not repeat the same limitation boilerplate in every delivery note. Owner-side Live Builder, Test Pilot, and smoke-test reports remain the authority for runtime acceptance.
