# DKScript Build Handshake v0.0.11

> **Historical naming note:** This record predates the v0.0.14 technical identity migration. At the time recorded below, BASIC# still used the working technical name `DKScript`. Old package names, commands, paths, and Git messages are preserved as audit history.


## Project

BASIC# language using the DKScript Ruby Bootstrap Compiler

## Version

v0.0.11

## Build name

BASIC# Language Foundation and Historical BASIC Research

## Required base version

Accepted v0.0.09, tag `v0.0.09`.

The package is cumulative and includes the unaccepted v0.0.10 Runtime Trigger Context candidate.

## Target version

v0.0.11

## Package filename

`DKScript_Ruby_Bootstrap_Compiler_v0_0_11_BASIC_SHARP_LANGUAGE_FOUNDATION_AND_HISTORICAL_BASIC_RESEARCH_CHANGED_FILES_ONLY.zip`

## Active project path

```text
/home/dereksparks1982/DKLab/Projects/DKScript
```

## Download location expectation

```text
/home/dereksparks1982/Downloads/
```

## Completed changes

- Recorded BASIC# as the public language name.
- Recorded Basic Sharp as the pronunciation.
- Preserved all technical DKScript names pending a separate approved migration.
- Recorded the beginner-first creator doctrine.
- Added historical BASIC research and future-roadmap findings.
- Logged and evaluated Grok's outside analysis.
- Preserved the Copilot project brief in project documentation.
- Carried v0.0.10 Runtime Trigger Context forward cumulatively.
- Advanced compiler and BSharp IR version to 0.0.11.
- Updated README, contracts, roadmap, cumulative handoff, changelog, patch notes, session log, validation, changed-files record, and manifest.

## Excluded work

- No technical rename of repository, files, Ruby modules, commands, compiler banner, or package prefix.
- No new syntax.
- No new official words.
- No duplicate or replacement language dictionary.
- No Kind Families.
- No ASK syntax or execution.
- No tracing interface.
- No recovery syntax.
- No capitalization or spacing behavior change.
- No event queue, timing, bytecode, VM, DK Engine, or Studio implementation.

## Changed files

The authoritative changed-file list is:

```text
docs/changed_files/BASIC_SHARP_CHANGED_FILES_v0_0_11.txt
```

## Validation plan

```bash
for file in compiler/*.rb; do ruby -c "$file"; done
ruby compiler/basic_sharp.rb samples/first_room.bsharp
ruby compiler/basic_sharp.rb samples/first_room.bsharp --emit-ir --out samples/first_room.bsir.json
ruby compiler/basic_sharp.rb samples/first_room.bsharp --run "player attacks henry"
ruby compiler/basic_sharp.rb samples/first_room.bsharp --run "player attacks ember"
ruby compiler/basic_sharp.rb samples/first_room.bsir.json --run "player attacks henry"
ruby -w -Itest -Itests -e 'Dir["tests/test_*.rb"].sort.each { |file| require_relative file }'
```

## Validation result

- Accepted v0.0.09 baseline reconstruction: PASS, 35 runs, 138 assertions, 0 failures, 0 errors, 0 skips.
- Ruby syntax checks: PASS for every compiler file.
- Compiler sample: PASS, 0 errors, 0 warnings.
- Henry direct-Kind Trigger proof: PASS.
- `that guard` context proof: PASS.
- Exact Ember event regression: PASS.
- Saved BSharp IR proof: PASS.
- Full v0.0.11 automated suite with Ruby warnings enabled: PASS, 41 runs, 178 assertions, 0 failures, 0 errors, 0 skips.
- Documentation presence checks: PASS.
- Cumulative overlay onto a clean accepted v0.0.09 reconstruction: PASS.
- Manifest file, byte-count, and SHA-256 verification: PASS.
- ZIP integrity and direct-root layout: PASS.

## Known risks

- Public language name and technical bootstrap name temporarily differ.
- Runtime Kind matching remains direct only.
- One selected Thing is stored per Kind during one event.
- The first matching WHEN rule runs.
- IF rules still run once during startup.
- BSharp IR is not bytecode.

## Rollback point

```bash
git checkout v0.0.09
```

## Current continuation point

After Derek installs, validates, and accepts v0.0.11, the next proposal is v0.0.12 Kind Families. No v0.0.12 work is approved by this handshake.
