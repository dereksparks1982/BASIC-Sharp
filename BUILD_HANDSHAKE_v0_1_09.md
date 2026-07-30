# DKScript Build Handshake v0.1.09

> **Historical naming note:** This record predates the v0.1.14 technical identity migration. At the time recorded below, BASIC# still used the working technical name `DKScript`. Old package names, commands, paths, and Git messages are preserved as audit history.


## Project

DKScript Ruby Bootstrap Compiler

## Version

v0.1.09

## Build name

First Runtime Execution

## Required base version

Accepted v0.1.08 at commit `d6c92d1`, tag `v0.1.08`.

## Target version

v0.1.09

## Package filename

`DKScript_Ruby_Bootstrap_Compiler_v0_1_09_FIRST_RUNTIME_EXECUTION_CHANGED_FILES_ONLY.zip`

## Active project path

```text
/home/dereksparks1982/DKLab/Projects/DKScript
```

## Download location expectation

```text
/home/dereksparks1982/Downloads/
```

## Completed changes

- Updated compiler and runtime version to `0.1.09`.
- Added `compiler/runtime.rb` as the first executable BSharp IR runtime.
- Added loading and execution of existing BSharp IR JSON files.
- Added creation of all resolved Things from BSharp IR.
- Added application of START Facts.
- Added one-pass IF checking after START Facts.
- Added exact normalized matching for one supplied WHEN Trigger.
- Preserved `<then>` and `<than>` as identical Connectors.
- Added execution for the existing official words `(damage`, `(change`, `(carry`, and `(unlock`.
- Added plain world-state output after execution.
- Changed the sample starting condition from `ember is alive` to `ember is calm` so the runtime proof shows a meaningful change to angry.
- Corrected current user-facing compiler messages to call `<then>` a Connector and `(damage` an official word.
- Added runtime, command-line, BSharp IR-loading, and state-change tests.
- Added current contracts, patch notes, changelog, validation record, roadmap, session log, and cumulative handoff.

## Excluded work

- No new DKScript syntax.
- No new official words.
- No dictionary changes.
- No Kind Families.
- No event queue or repeated execution.
- No timing system.
- No full health, inventory, door, or combat system.
- No bytecode or VM.
- No DK Engine or DK Studio work.
- No Godot integration.

## Changed files

The authoritative changed-file list is:

```text
docs/changed_files/BASIC_SHARP_CHANGED_FILES_v0_1_09.txt
```

## Validation plan

```bash
for file in compiler/*.rb; do ruby -c "$file"; done
ruby compiler/basic_sharp.rb samples/first_room.bsharp
ruby compiler/basic_sharp.rb samples/first_room.bsharp --emit-ir --out samples/first_room.bsir.json
ruby compiler/basic_sharp.rb samples/first_room.bsharp --run "player attacks ember"
ruby compiler/basic_sharp.rb samples/first_room.bsharp --run "player takes brass key"
ruby compiler/basic_sharp.rb samples/first_room.bsir.json --run "player attacks ember"
ruby -Itest -Itests -e 'Dir["tests/test_*.rb"].sort.each { |file| require_relative file }'
```

## Validation result

- Accepted v0.1.08 baseline reconstruction: PASS, 27 runs, 95 assertions, 0 failures, 0 errors, 0 skips.
- Ruby syntax checks: PASS for every compiler file.
- Main sample compilation: PASS, 0 errors, 0 warnings.
- BSharp IR output generation: PASS.
- Source-to-runtime attack proof: PASS.
- Source-to-runtime carry proof: PASS.
- Existing-BSharp IR-to-runtime attack proof: PASS.
- Full v0.1.09 automated suite: PASS, 35 runs, 138 assertions, 0 failures, 0 errors, 0 skips.
- Changed-files package overlay validation: PASS against a clean reconstruction of accepted v0.1.08; 35 runs, 138 assertions, 0 failures, 0 errors, 0 skips.

## Known risks

- The runtime matches one Trigger by normalized exact text. It does not yet maintain an event queue.
- Event-selected references such as `that guard` are not yet carried into Connector lines.
- `(damage` records a runtime damage count of one per execution. A complete health model is not part of this build.
- IF rules run once during startup only.
- BSharp IR remains a readable debug structure, not final bytecode.

## Rollback point

```bash
git checkout v0.1.08
```

## Current continuation point

After Derek installs, validates, and accepts v0.1.09, the next proposal may add runtime Trigger context so `that guard` can resolve to the Thing selected by the matched event. No v0.1.10 work is approved by this handshake.
