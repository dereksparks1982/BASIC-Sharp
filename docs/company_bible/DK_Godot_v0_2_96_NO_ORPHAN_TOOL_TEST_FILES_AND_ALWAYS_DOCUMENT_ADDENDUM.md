# DK Godot v0.2.96 No Orphan Tool/Test Files and Always Document Addendum

**Date:** 2026-07-07  
**Status:** Mandatory  
**Scope:** All DK/Elderred tools, utilities, scaffolds, test scenes, helper files, and development-kit components

## Rule

Never distribute an orphan tool file, test scene, utility asset, or scaffold outside the normal DK build process.

Every delivered project item must:

- use the next correct unused numeric version;
- belong to one clearly named build or patch;
- include all mandatory changelog, session log, patch notes, handoff, changed-files record, system documentation, and manifest records;
- update all required active version surfaces;
- preserve the changed-files-only package structure;
- receive the same validation and documentation discipline as gameplay work.

Do not reuse the current version number for a second deliverable. Do not provide a one-file ZIP as though it were an official DK build. Do not bypass the system being tested by manually dropping in its intended target without integrating and documenting the real test layer.

## Internal development-kit status

The DK audio tools, Live Builder, cell tools, streaming scaffolds, and future EIS Forge/Cellworks utilities are part of the internal DK/Elderred development kit. They are not disposable side files. They must always be versioned, documented, recoverable, and handed off cleanly.

Simple rule:

```text
Always document it. Always number it correctly. No orphan files.
```
