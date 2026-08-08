# BASIC# Self-Hosting Fixture Corpus v0.1.58

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
- Renaming DKLab paths or accepted-build workflow.

## DKLab identity decision

Elderred Softworks LLC is the official company identity. DKLab is retained as the internal workspace and lab name in homage to Demon Killer. No filesystem or build-path migration is planned in this build.
