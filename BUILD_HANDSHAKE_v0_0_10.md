# DKScript Build Handshake v0.0.10

> **Historical naming note:** This record predates the v0.0.14 technical identity migration. At the time recorded below, BASIC# still used the working technical name `DKScript`. Old package names, commands, paths, and Git messages are preserved as audit history.


## Project

DKScript Ruby Bootstrap Compiler

## Version

v0.0.10

## Build name

Runtime Trigger Context

## Required base version

Accepted v0.0.09, tagged as `v0.0.09` after local acceptance.

## Target version

v0.0.10

## Package filename

`DKScript_Ruby_Bootstrap_Compiler_v0_0_10_RUNTIME_TRIGGER_CONTEXT_CHANGED_FILES_ONLY.zip`

## Active project path

```text
/home/dereksparks1982/DKLab/Projects/DKScript
```

## Download location expectation

```text
/home/dereksparks1982/Downloads/
```

## Completed changes

- Updated compiler and BSharp IR version to `0.0.10`.
- Added runtime matching from a named Thing to a direct Kind written in a Trigger, such as `henry` matching `a guard`.
- Added Trigger context that remembers the selected Thing.
- Added runtime resolution of `that guard` to the guard selected by the matched Trigger.
- Preserved exact normalized event matching for existing rules.
- Added plain runtime errors for unknown Things supplied to a Kind Trigger.
- Added plain runtime errors when a supplied Thing has the wrong Kind.
- Preserved source execution and saved-BSharp IR execution parity.
- Expanded the sample with one Kind Trigger while keeping the exact Ember Trigger.
- Added runtime, command-line, and BSharp IR tests.
- Updated the README, parser contract, runtime contract, roadmap, cumulative handoff, changelog, patch notes, session log, validation record, changed-files record, and patch manifest.

## Excluded work

- No new DKScript syntax.
- No new official words.
- No dictionary changes.
- No Kind Families.
- No inherited Kind matching.
- No multiple selected Things of the same Kind.
- No event queue or repeated execution.
- No timing system.
- No bytecode or VM.
- No DK Engine or DK Studio work.
- No Godot integration.

## Changed files

The authoritative changed-file list is:

```text
docs/changed_files/BASIC_SHARP_CHANGED_FILES_v0_0_10.txt
```

## Validation plan

```bash
for file in compiler/*.rb; do ruby -c "$file"; done
ruby compiler/basic_sharp.rb samples/first_room.bsharp
ruby compiler/basic_sharp.rb samples/first_room.bsharp --emit-ir --out samples/first_room.bsir.json
ruby compiler/basic_sharp.rb samples/first_room.bsharp --run "player attacks henry"
ruby compiler/basic_sharp.rb samples/first_room.bsharp --run "player attacks ember"
ruby compiler/basic_sharp.rb samples/first_room.bsir.json --run "player attacks henry"
ruby -Itest -Itests -e 'Dir["tests/test_*.rb"].sort.each { |file| require_relative file }'
```

## Validation result

- Accepted v0.0.09 baseline reconstruction: PASS, 35 runs, 138 assertions, 0 failures, 0 errors, 0 skips.
- Ruby syntax checks: PASS for every compiler file.
- Main sample compilation: PASS, 0 errors, 0 warnings.
- BSharp IR output generation: PASS.
- Named guard to `a guard` matching: PASS.
- `that guard` resolving to Henry: PASS.
- Exact Ember event matching: PASS.
- Unknown Thing message: PASS.
- Wrong Kind message: PASS.
- Existing-BSharp IR Trigger-context proof: PASS.
- Full v0.0.10 automated suite: PASS, 41 runs, 178 assertions, 0 failures, 0 errors, 0 skips.
- Changed-files overlay validation: PASS against a clean reconstruction of accepted v0.0.09.

## Known risks

- Kind matching is direct only. Kind Families are not part of this build.
- One remembered Thing is stored per Kind during one matched event.
- The first matching WHEN rule runs. A full multi-rule event policy is not part of this build.
- Event text still uses the current small event-word reader.
- IF rules still run once during startup only.
- BSharp IR remains readable debug information, not final bytecode.

## Rollback point

```bash
git checkout v0.0.09
```

## Current continuation point

After Derek installs, validates, and accepts v0.0.10, the next proposal is v0.0.11 Kind Families. No v0.0.11 work is approved by this handshake.
