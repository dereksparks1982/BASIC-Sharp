# DK Godot v0.2.85 Numeric-Only Versioning Addendum

## Permanent rule

All DK builds, patches, and hotfixes use the next unused numeric version. Letter suffixes are prohibited.

Examples:
- Correct: `v0.2.84` → `v0.2.85`
- Incorrect: `v0.2.84a`, `v0.2.84b`, `v0.2.84c`

Rejected packages are not accepted baselines and must not be treated as the current project version.

Before delivery, verify the package filename, `project.godot`, scene labels, script version constants, changelog, session log, handoff, patch notes, and manifest all carry the same numeric version.
