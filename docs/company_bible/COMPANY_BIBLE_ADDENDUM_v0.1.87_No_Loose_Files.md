# Company Bible Addendum - Build Packaging Rule

Version: v0.1.87
Date: 2026-07-02

## No Loose Files Rule

Never deliver loose files as part of a DK build or patch.

Every deliverable must be properly packaged according to the project's packaging rules.

Loose standalone files are not acceptable unless Derek explicitly requests them.

## Practical Meaning

- Logs go inside the project documentation structure.
- CODEX entries go inside the project documentation structure.
- Changelogs go inside the project documentation structure.
- Archive copies such as `main_copy.tscn` go inside the correct project folder beside the original file when requested.
- Changed-files patches must preserve project-relative paths.
- Full archive builds must open directly to project files, not an extra wrapper folder.
