# DKScript Build Handshake v0.1.12

## Project

BASIC# language using the DKScript Ruby Bootstrap Compiler

## Version

v0.1.12

## Build name

Plain-Language Runtime Trace

## Required base version

Accepted v0.1.11, commit `9fb30ae`, tag `v0.1.11`.

## Target version

v0.1.12

## Package filename

`DKScript_Ruby_Bootstrap_Compiler_v0_1_12_PLAIN_LANGUAGE_RUNTIME_TRACE_CHANGED_FILES_ONLY.zip`

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
- Preserved source and saved-DKIR parity.
- Recorded: “A script language made for non-programmers, by non-programmers.”
- Logged Copilot review decisions.
- Advanced compiler and DKIR version to 0.1.12.
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
docs/changed_files/DKSCRIPT_CHANGED_FILES_v0_1_12.txt
```

## Validation plan

```bash
for file in compiler/*.rb; do ruby -c "$file"; done
ruby compiler/dks.rb samples/first_room.dks
ruby compiler/dks.rb samples/first_room.dks --emit-ir --out samples/first_room.ir.json
ruby compiler/dks.rb samples/first_room.dks --run "player attacks henry"
ruby compiler/dks.rb samples/first_room.dks --run "player attacks ember"
ruby compiler/dks.rb samples/first_room.ir.json --run "player attacks henry"
ruby -w -Itest -Itests -e 'Dir["tests/test_*.rb"].sort.each { |file| require_relative file }'
```

## Validation result

- Accepted v0.1.11 baseline suite: PASS, 41 runs, 178 assertions.
- Ruby syntax checks: PASS.
- Compiler sample: PASS, 0 errors, 0 warnings.
- Henry plain-language trace: PASS.
- Exact Ember trace regression: PASS.
- Saved DKIR trace parity: PASS.
- Full v0.1.12 suite with Ruby warnings: PASS, 42 runs, 252 assertions, 0 failures, 0 errors, 0 skips.
- Documentation presence checks: PASS.
- Clean v0.1.11 overlay and final ZIP checks: recorded in validation document after packaging.

## Known risks

- Runtime command-line headings changed.
- External tools that scrape `event words:` may need to use `what happened:` instead.
- Runtime Kind matching remains direct only.
- One selected Thing is stored per Kind during one event.
- The first matching WHEN rule runs.
- DKIR is not bytecode.

## Rollback point

```bash
git checkout v0.1.11
```

## Current continuation point

After owner validation and acceptance, commit/tag v0.1.12 and proceed to v0.1.13 Focused Runtime Stress Test. Kind Families remain after stress testing and any required repair.
