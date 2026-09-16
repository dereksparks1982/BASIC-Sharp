# DKScript Validation v0.0.12

> **Historical naming note:** This record predates the v0.0.14 technical identity migration. At the time recorded below, BASIC# still used the working technical name `DKScript`. Old package names, commands, paths, and Git messages are preserved as audit history.


## Required base

Accepted v0.0.11, commit `9fb30ae`, tag `v0.0.11`.

## Ruby syntax

Every file under `compiler/*.rb` passed `ruby -c`.

Result: PASS.

## Compiler proof

```bash
ruby compiler/basic_sharp.rb samples/first_room.bsharp
```

```text
DKScript Ruby Bootstrap Compiler v0.0.12
statements: 7
kinds: 1
definitions: 5
facts: 4
events: 3
if rules: 1
objects: 6
official words: 6
errors: 0
warnings: 0
```

Result: PASS.

## Henry trace proof

Event:

```text
player attacks henry
```

Observed:

```text
what matched:
  player attacks a guard
what I understood:
  a guard means henry
  that guard means henry
what happened:
  (damage henry
  henry damage is now 1
  (change henry to angry
  henry is now angry
```

Final Henry state:

```text
henry: kind=guard; states=angry; damage=1
```

Result: PASS.

## Exact Ember trace proof

Observed:

```text
what matched:
  player attacks ember
what happened:
  (damage ember
  ember damage is now 1
  (change ember to angry
  ember is now angry
```

Result: PASS.

## Saved BSharp IR proof

Running `player attacks henry` from `samples/first_room.bsir.json` produced the same trace and state as source execution.

Result: PASS.

## Automated suite

```text
42 runs
252 assertions
0 failures
0 errors
0 skips
```

The suite was run with Ruby warnings enabled.

Result: PASS.

## Documentation checks

Confirmed present:

- non-programmer doctrine;
- Copilot review decision;
- parser and runtime contracts;
- roadmap;
- cumulative handoff;
- changelog;
- patch notes;
- session log;
- changed-files record;
- build handshake;
- patch manifest.

Result: PASS.

## Clean v0.0.11 overlay proof

The changed-files payload was applied to a clean v0.0.11 copy.

Confirmed:

- direct project-root layout;
- no wrapper directory;
- no deletion request;
- manifest format `BASIC_SHARP_CHANGED_FILES_PATCH`;
- manifest format version 1;
- all 20 packaged files present;
- every manifest byte count correct;
- every manifest SHA-256 correct;
- compiler proof passed;
- Henry trace passed;
- exact Ember trace passed;
- source and saved-BSharp IR trace outputs matched;
- full suite passed with 42 runs and 252 assertions.

Result: PASS.

## ZIP checks

- ZIP integrity: PASS.
- Direct-root changed-files layout: PASS.
- File list exactly matches the changed-files record: PASS.
- Manifest excludes only its own hash as declared: PASS.
- No loose deliverable files: PASS.
- Package SHA-256 is reported in the delivery message after final ZIP creation.

## Final result

PASS. No known validation failure is hidden.
