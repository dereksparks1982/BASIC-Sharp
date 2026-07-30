# BASIC# Build Handshake v0.1.14

## Project

BASIC# Ruby Bootstrap Compiler

## Build name

Technical Identity Migration and Company Bible Integration

## Required base

```text
version: v0.1.13
commit: 3ae88bbd032a20c97f4ce99ecc5b0623125b2fc4
tag: v0.1.13
branch: main
working tree: clean
```

## Target version

```text
v0.1.14
```

## Package filename

```text
BASIC_Sharp_Ruby_Bootstrap_Compiler_v0_1_14_TECHNICAL_IDENTITY_MIGRATION_AND_COMPANY_BIBLE_INTEGRATION_CHANGED_FILES_ONLY.zip
```

## Target project path

```text
/home/dereksparks1982/DKLab/Projects/BASIC#
```

## Completed changes

- Migrated the active project and language identity to `BASIC#` / `Basic Sharp`.
- Migrated the Ruby namespace from the former working namespace to `BasicSharp`.
- Renamed the compiler entry point to `compiler/basic_sharp.rb`.
- Renamed the IR source file to `compiler/basic_sharp_ir.rb`.
- Renamed all creator source samples from `.dks` to `.bsharp`.
- Renamed documentation filenames carrying the retired project label.
- Added historical naming notes instead of scrubbing old build truth.
- Imported the complete 73-file Company Bible set from `docs.zip`.
- Added the BASIC# Company Bible carryover record, making 74 project Bible files.
- Corrected current documentation to recognize accepted v0.1.13 commit `3ae88bb` and tag `v0.1.13`.
- Added migration-specific automated tests.
- Added a v0.1.13 saved-BSharp IR compatibility fixture.
- Preserved the `bsir.debug.json` format and runtime meaning.
- Added a one-command migration installer inside the package.

## Explicit exclusions

- No inherited Kind matching.
- No new `KINDS` syntax or behavior.
- No multiple inheritance.
- No new Heads, Connectors, official words, values, amounts, time, repetition, queue, ASK, bytecode, VM, engine bridge, or self-hosting work.
- No parser grammar or creator-facing runtime behavior changes.
- No Git commit or tag before Derek accepts the installed build.

## Changed files and deletions

The complete machine-readable list is in `BASIC_SHARP_PATCH_MANIFEST.json`.
The human-readable list is:

```text
docs/changed_files/BASIC_SHARP_CHANGED_FILES_v0_1_14.txt
```

## Validation result

Ruby syntax:

```text
PASS for every compiler, tool, and test Ruby file
```

Automated suite:

```text
61 runs
4,360 assertions
0 failures
0 errors
0 skips
```

Focused stress:

```text
504 Things
10,002 events through source-built BSharp IR
10,002 events through saved BSharp IR
20,004 total event executions
source/saved-BSharp IR parity: PASS
separate runtime isolation: PASS
unknown Thing explanation: PASS
wrong Kind explanation: PASS
deterministic final world: PASS
```

Additional proofs:

- `BasicSharp` is the active Ruby namespace.
- The retired Ruby namespace is not defined.
- `.bsharp` is the active creator source extension.
- No project filename uses the retired technical label.
- Compiler and runtime banners display BASIC# v0.1.14.
- A saved v0.1.13 BSharp IR document still executes correctly.
- The Company Bible is present in project documentation.

## Known risks

- The `#` in the project folder must remain quoted in shell commands.
- Open terminals, editor workspaces, or bookmarks may still point to the former folder path after migration.
- Historical documents intentionally retain former names inside their contents as audit history.
- BSharp IR remains a debug format whose long-term compatibility is not yet frozen.

## Rollback point

```text
folder: /home/dereksparks1982/DKLab/Projects/DKScript
commit: 3ae88bbd032a20c97f4ce99ecc5b0623125b2fc4
tag: v0.1.13
```

The installer rolls back the folder name and Git tree if validation fails.

## Owner-side apply command

Run from any directory after placing the package in Downloads:

```bash
unzip -p ~/Downloads/BASIC_Sharp_Ruby_Bootstrap_Compiler_v0_1_14_TECHNICAL_IDENTITY_MIGRATION_AND_COMPANY_BIBLE_INTEGRATION_CHANGED_FILES_ONLY.zip APPLY_BASIC_SHARP_v0_1_14.sh | bash -s -- ~/Downloads/BASIC_Sharp_Ruby_Bootstrap_Compiler_v0_1_14_TECHNICAL_IDENTITY_MIGRATION_AND_COMPANY_BIBLE_INTEGRATION_CHANGED_FILES_ONLY.zip
```

## Acceptance and Git step

Only after Derek validates and accepts v0.1.14:

```bash
cd '/home/dereksparks1982/DKLab/Projects/BASIC#'
git status
git add -A
git commit -m "BASIC# v0.1.14 Technical Identity Migration and Company Bible Integration"
git tag v0.1.14
git status
```

## Current continuation point

After acceptance, commit, and tag, prepare the exact v0.1.15 proposal for **Inherited Kind Matching**. Do not implement it without a new explicit build command.
