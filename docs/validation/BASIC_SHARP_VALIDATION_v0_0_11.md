# DKScript Validation v0.0.11

> **Historical naming note:** This record predates the v0.0.14 technical identity migration. At the time recorded below, BASIC# still used the working technical name `DKScript`. Old package names, commands, paths, and Git messages are preserved as audit history.


## Required base

Accepted v0.0.09, tag `v0.0.09`.

v0.0.11 is a cumulative changed-files package that includes v0.0.10 Runtime Trigger Context because owner terminal acceptance for v0.0.10 was not recorded before this build.

## Accepted baseline reconstruction

```text
35 runs
138 assertions
0 failures
0 errors
0 skips
```

Result: PASS.

## Ruby syntax

Every file under `compiler/*.rb` passed `ruby -c`.

Result: PASS.

## Compiler proof

```bash
ruby compiler/basic_sharp.rb samples/first_room.bsharp
```

```text
DKScript Ruby Bootstrap Compiler v0.0.11
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

## Runtime Kind Trigger proof

Event:

```text
player attacks henry
```

Observed words:

```text
(damage henry
(change henry to angry
```

Observed state:

```text
henry: kind=guard; states=angry; damage=1
```

Result: PASS.

## Exact event regression proof

Event:

```text
player attacks ember
```

Observed state:

```text
ember: kind=dragon; states=angry; damage=1
```

Result: PASS.

## Saved BSharp IR proof

Running `player attacks henry` from `samples/first_room.bsir.json` produced the same Henry state as source execution.

Result: PASS.

## Automated suite

```text
41 runs
178 assertions
0 failures
0 errors
0 skips
```

The suite was run with Ruby warnings enabled.

Result: PASS.

## Documentation checks

Confirmed present:

- BASIC# language foundation;
- historical BASIC research;
- Grok outside-analysis decision record;
- preserved Copilot review brief;
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

## Cumulative overlay proof

The final changed-files payload was applied to a clean accepted v0.0.09 reconstruction.

Confirmed:

- direct project-root layout;
- no wrapper directory;
- no deletion request;
- manifest format `BASIC_SHARP_CHANGED_FILES_PATCH`;
- manifest format version 1;
- every listed file present;
- every listed byte count correct;
- every listed SHA-256 correct;
- compiler proof passed;
- Henry Trigger-context proof passed;
- exact Ember regression passed;
- saved BSharp IR proof passed;
- full suite passed with 41 runs and 178 assertions.

Result: PASS.

## ZIP checks

- ZIP integrity: PASS.
- Direct-root changed-files layout: PASS.
- File list matches changed-files record: PASS.
- Manifest excludes only its own hash as declared: PASS.
- Package SHA-256 is reported in the delivery message after final ZIP creation.

## Final result

PASS. No known validation failure is hidden.
