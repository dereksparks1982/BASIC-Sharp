# BASIC# Self-Hosting Fixture Corpus v0.1.63

Status: fixture corpus under Ruby referee.

This build seals a repeatable corpus of BASIC# source fixtures linked to `spec/self_hosting/BASIC_SHARP_SELF_HOSTING_SUBSET_v1.json` that must pass through the approved small compiler subset pipeline: parser records, BSharp IR, BSBC bytecode, bytecode loader summary, and symbol-table checks. The fixture corpus is not the production compiler path and does not claim BASIC# is self-hosted.

## Scope

Allowed:

- Add a self-hosting fixture corpus specification.
- Validate each corpus fixture under Ruby referee control.
- Cover existing bytecode profiles 1 through 7 with no Profile 8.
- Preserve bytecode and BSBC names.

Forbidden:

- Replacing the Ruby bootstrap compiler.
- Claiming BASIC# is self-hosted.
- Renaming bytecode or BSBC.
- Removing the DKLab compatibility bridge before later accepted validation.

## Elderedd identity and DKLab compatibility decision

Elderedd Softworks LLC is the parent company identity. Elderedd Laboratory is the active laboratory. DKLab is retired as active identity and retained only as compatibility bridge, rollback support, migration history, or archival evidence. The compatibility bridge must not be removed until a later accepted build proves it is safe.
