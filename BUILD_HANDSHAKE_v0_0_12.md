# DKScript Build Handshake v0.0.12

> **Historical naming note:** This record predates the v0.0.14 technical identity migration. At the time recorded below, BASIC# still used the working technical name `DKScript`. Old package names, commands, paths, and Git messages are preserved as audit history.


## Project

BASIC# language using the DKScript Ruby Bootstrap Compiler

## Version

v0.0.12

## Build name

Plain-Language Runtime Trace

## Required base version

Accepted v0.0.11, commit `9fb30ae`, tag `v0.0.11`.

## Target version

v0.0.12

## Package filename

`DKScript_Ruby_Bootstrap_Compiler_v0_0_12_PLAIN_LANGUAGE_RUNTIME_TRACE_CHANGED_FILES_ONLY.zip`

## Active project path

```text
/home/dereksparks1982/DKLab/Projects/DKScript
```

## Download location expectation

```text
/home/dereksparks1982/Downloads/
```

## Completed changes

- Added plain-language runtime trace output.
- Shows the matched WHEN rule.
- Shows direct Kind selection.
- Shows what `that guard` means.
- Shows each event official word and immediate world change.
- Preserved exact matching and direct Kind Trigger behavior.
- Preserved source and saved-BSharp IR parity.
- Recorded: “A script language made for non-programmers, by non-programmers.”
- Logged Copilot review decisions.
- Advanced compiler and BSharp IR version to 0.0.12.
- Updated README, contracts, roadmap, handoff, changelog, patch notes, session log, validation, changed-files record, and manifest.

## Excluded work

- No new syntax.
- No new official words.
- No Kind Families.
- No multiple selected Things.
- No event queue.
- No ASK or recovery implementation.
- No timing or repetition.
- No technical rename.
- No bytecode, VM, engine bridge, or self-hosting implementation.

## Changed files

The authoritative changed-file list is:

```text
docs/changed_files/BASIC_SHARP_CHANGED_FILES_v0_0_12.txt
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

- Accepted v0.0.11 baseline suite: PASS, 41 runs, 178 assertions.
- Ruby syntax checks: PASS.
- Compiler sample: PASS, 0 errors, 0 warnings.
- Henry plain-language trace: PASS.
- Exact Ember trace regression: PASS.
- Saved BSharp IR trace parity: PASS.
- Full v0.0.12 suite with Ruby warnings: PASS, 42 runs, 252 assertions, 0 failures, 0 errors, 0 skips.
- Documentation presence checks: PASS.
- Clean v0.0.11 overlay and final ZIP checks: recorded in validation document after packaging.

## Known risks

- Runtime command-line headings changed.
- External tools that scrape `event words:` may need to use `what happened:` instead.
- Runtime Kind matching remains direct only.
- One selected Thing is stored per Kind during one event.
- The first matching WHEN rule runs.
- BSharp IR is not bytecode.

## Rollback point

```bash
git checkout v0.0.11
```

## Current continuation point

After owner validation and acceptance, commit/tag v0.0.12 and proceed to v0.0.13 Focused Runtime Stress Test. Kind Families remain after stress testing and any required repair.
