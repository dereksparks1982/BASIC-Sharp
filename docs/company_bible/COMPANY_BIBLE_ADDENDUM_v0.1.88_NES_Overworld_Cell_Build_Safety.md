# Company Bible Addendum - NES Overworld Cell Build Safety

Version: v0.1.88
Date: 2026-07-02

## Rule
When adding NES/Zelda-style overworld cells to DK, the patch must be additive and surgical.

Do not delete, replace, rename, or reparent the existing old map cells or the working door cells unless Derek explicitly orders that exact destructive change.

## Required Safety Behaviour
- Back up `scenes/Main.tscn` as `scenes/main_copy.tscn` when Main is changed.
- Keep packages changed-files-only by default.
- Preserve project-relative paths.
- Do not deliver loose files.
- New overworld cells must be visible in the editor before Play when they are intended for map building.
- Door-link workflow and cell-link workflow are separate. Do not break one to add the other.
