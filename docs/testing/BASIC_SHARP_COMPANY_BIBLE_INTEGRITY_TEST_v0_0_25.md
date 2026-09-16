# BASIC# Company Bible Integrity Test v0.0.25

Command:

```bash
ruby tools/company_bible_audit.rb
```

Coverage:

1. Exactly one active file exists under `docs/company_bible/`.
2. The exact canonical filename is present.
3. No addendum, carryover, project-bible, or Godot `.meta` file remains active.
4. Mandatory authority, approval, stop, packaging, rollback, validation, continuity, identity, image-permission, and business-shelving sections exist.
5. All 74 retired source paths appear in the consolidation ledger.
6. README, roadmap, and master handoff point to the exact canonical path.
7. The canonical document prohibits new standalone Company Bible addendums.

Required result:

```text
COMPANY BIBLE AUDIT: PASS
```
