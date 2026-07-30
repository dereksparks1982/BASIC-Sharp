# DKScript Validation v0.1.13

> **Historical naming note:** This record predates the v0.1.14 technical identity migration. At the time recorded below, BASIC# still used the working technical name `DKScript`. Old package names, commands, paths, and Git messages are preserved as audit history.


## Build

Focused Runtime Stress Test and Contract Hardening

## Required base

Accepted v0.1.12 Plain-Language Runtime Trace:

```text
commit 25c9265
tag v0.1.12
42 runs
252 assertions
0 failures
0 errors
0 skips
```

v0.1.13 is an incremental changed-files-only patch over the exact v0.1.12 baseline.

## Rejected archive result

A previous v0.1.13 archive was installed and tested by Derek. The code passed:

```text
54 runs
4,330 assertions
0 failures
0 errors
0 skips
20,004 standalone event executions
STRESS TEST: PASS
```

The archive was rejected because it also contained unchanged v0.1.12 files. That result proves the code path but does not accept the package.

## Ruby syntax

Every Ruby file under:

```text
compiler/*.rb
tools/*.rb
```

passed `ruby -c`.

Result: PASS.

## Compiler proof

```bash
ruby compiler/basic_sharp.rb samples/first_room.bsharp
```

Observed:

```text
DKScript Ruby Bootstrap Compiler v0.1.13
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

## Plain-language trace regression

The following passed:

```text
player attacks henry
player attacks ember
```

Henry still matches:

```text
player attacks a guard
```

The trace still explains:

```text
a guard means henry
that guard means henry
henry damage is now 1
henry is now angry
```

Result: PASS.

## Source and saved BSharp IR trace parity

Running `player attacks henry` from source and from `samples/first_room.bsir.json` produced identical runtime reports.

Result: PASS.

## Automated suite

```bash
ruby -w -Itest -Itests -e 'Dir["tests/test_*.rb"].sort.each { |file| require_relative file }'
```

Observed:

```text
54 runs
4,330 assertions
0 failures
0 errors
0 skips
```

Result: PASS.

## Standalone stress runner

```bash
ruby tools/runtime_stress.rb
```

Observed:

```text
BASIC# Runtime Stress Test v0.1.13
Things: 504
Events per execution path: 10002
Source and saved BSharp IR parity: PASS
Separate runtime isolation: PASS
Unknown Thing explanation: PASS
Wrong Kind explanation: PASS
Deterministic final world: PASS
STRESS TEST: PASS
```

Total event executions:

```text
20,004
```

Result: PASS.

## Stress coverage

Confirmed:

- hundreds of defined Things;
- many direct guards and dragons;
- exact Trigger priority;
- direct-Kind Trigger selection;
- repeated `(damage` and `(change`;
- truthful accumulated-damage trace;
- `(carry` relation change;
- startup `(unlock`;
- selected context staying inside one event;
- fresh Runtime isolation;
- deterministic final worlds;
- long source/saved-BSharp IR parity;
- unknown Thing explanation;
- wrong Kind explanation;
- duplicate Thing rejection;
- missing BSharp IR format rejection.

Result: PASS.

## Runtime hardening proof

Duplicate Thing test:

```text
BSharp IR has more than one Thing named 'guard 1'
```

Missing format test:

```text
BSharp IR format '(missing)' is not supported
```

Both are rejected before execution.

Result: PASS.

## Corrected package proof

The final corrected payload was generated from the actual difference between a clean v0.1.12 tree and the v0.1.13 candidate.

Confirmed:

- direct project-root layout;
- no wrapper folder;
- no deletion request;
- manifest format `BASIC_SHARP_CHANGED_FILES_PATCH` version 1;
- no unchanged v0.1.12 file in the payload;
- ZIP file set equals the authoritative changed-files record;
- manifest byte counts and SHA-256 values match every non-manifest file;
- applying the corrected payload to clean v0.1.12 reproduces the intended v0.1.13 tree;
- compiler proof passes with zero errors and warnings;
- source and saved-BSharp IR trace parity passes;
- 54-run automated suite passes;
- standalone 20,004-event stress test passes.

Result: PASS.

## Documentation proof

Confirmed present:

- v0.1.13 build handshake;
- formal BSharp IR meaning contract;
- runtime stress-test record;
- Claude review decision record;
- Lisp research;
- official-word visual guide;
- parser and runtime contracts;
- roadmap;
- cumulative master handoff;
- dedicated new-thread handoff;
- rejected-package audit;
- changelog;
- patch notes;
- session log;
- changed-files record;
- manifest.

Result: PASS.

## Internal result

PASS. No known code, test, documentation, or packaging failure is hidden.

## Owner acceptance status

Pending. Derek must restore the local repository to `v0.1.12`, apply the corrected archive, and rerun the full validation before v0.1.13 is committed or tagged.
