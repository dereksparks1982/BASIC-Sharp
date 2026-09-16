# BASIC# v0.0.13 New Thread Handoff

> **Historical naming note:** This record predates the v0.0.14 technical identity migration. At the time recorded below, BASIC# still used the working technical name `DKScript`. Old package names, commands, paths, and Git messages are preserved as audit history.


**Prepared:** 2026-07-30  
**Purpose:** Resume tomorrow in a new conversation without reconstructing the build history.

## Project

- Public language name: **BASIC#**, pronounced **Basic Sharp**
- Current technical bootstrap name: **DKScript Ruby Bootstrap Compiler**
- Project path: `/home/dereksparks1982/DKLab/Projects/DKScript`
- Owner: Derek

## Core identity

> A scripting language made for non-programmers, by non-programmers.

The compiler and engine do the heavy lifting. The creator enjoys the ride.

The opening `(` in official words such as `(damage` is a creator-facing visual guide. Derek chose it so he can immediately see where BASIC# tells the world to do something. It was not added merely for parser convenience.

## Accepted baseline

```text
Version: v0.0.12 Plain-Language Runtime Trace
Commit: 25c9265
Tag: v0.0.12
Validation: 42 runs, 252 assertions, 0 failures, 0 errors, 0 skips
Owner validation: passed twice on 2026-07-30
```

## Current candidate

```text
Version: v0.0.13
Build: Focused Runtime Stress Test and Contract Hardening
Status: corrected package built; owner validation pending
```

Corrected package:

```text
DKScript_Ruby_Bootstrap_Compiler_v0_0_13_FOCUSED_RUNTIME_STRESS_TEST_AND_CONTRACT_HARDENING_CORRECTED_CHANGED_FILES_ONLY.zip
```

Required base:

```text
v0.0.12 tag
```

## Important package history

The previously installed v0.0.13 ZIP is rejected. Its code passed all tests, but the archive incorrectly included unchanged v0.0.12 files while claiming to be an incremental changed-files-only package.

Do not commit or tag the currently installed rejected package.

The full audit is stored at:

```text
docs/audit/BASIC_SHARP_v0_0_13_REJECTED_PACKAGE_AUDIT.md
```

## Correct recovery and installation sequence

From the project root:

```bash
git reset --hard v0.0.12
unzip -o "/home/dereksparks1982/Downloads/DKScript_Ruby_Bootstrap_Compiler_v0_0_13_FOCUSED_RUNTIME_STRESS_TEST_AND_CONTRACT_HARDENING_CORRECTED_CHANGED_FILES_ONLY.zip" -d "/home/dereksparks1982/DKLab/Projects/DKScript"
```

The hard reset restores all tracked files to the accepted v0.0.12 baseline. The corrected ZIP then overwrites the rejected v0.0.13 candidate files with the verified incremental payload.

## Required validation

```bash
ruby compiler/basic_sharp.rb samples/first_room.bsharp && \
ruby compiler/basic_sharp.rb samples/first_room.bsharp --run "player attacks henry" && \
ruby compiler/basic_sharp.rb samples/first_room.bsharp --run "player attacks ember" && \
ruby compiler/basic_sharp.rb samples/first_room.bsir.json --run "player attacks henry" && \
ruby -w -Itest -Itests -e 'Dir["tests/test_*.rb"].sort.each { |file| require_relative file }' && \
ruby tools/runtime_stress.rb
```

Expected automated result:

```text
54 runs
4,330 assertions
0 failures
0 errors
0 skips
```

Expected standalone stress result:

```text
504 Things
10,002 events through source-built BSharp IR
10,002 events through saved BSharp IR
20,004 total event executions
STRESS TEST: PASS
```

## v0.0.13 completed scope

- preserves v0.0.12 plain-language tracing;
- adds reusable high-volume runtime stress testing;
- proves source and saved-BSharp IR parity over long event sequences;
- proves runtime isolation and deterministic results;
- protects selected-Thing context from leaking between events;
- rejects duplicate normalized Thing names in BSharp IR;
- rejects missing or unsupported BSharp IR formats;
- adds the first formal BSharp IR meaning contract;
- records Claude review decisions and Lisp research;
- records the creator-facing purpose of `(`;
- adds no new BASIC# syntax or official words.

## Excluded work

- no Kind Families;
- no multiple selected Things;
- no event queue;
- no creator-facing values or amounts;
- no time or repetition feature;
- no ASK implementation;
- no technical rename;
- no bytecode, VM, game-engine bridge, or self-hosting work.

## Acceptance step after owner validation

Only after the corrected package passes:

```bash
git add . && \
git commit -m "DKScript v0.0.13 Focused Runtime Stress Test and Contract Hardening" && \
git tag -a v0.0.13 -m "DKScript v0.0.13 Focused Runtime Stress Test and Contract Hardening" && \
git status
```

## Continuation point

After v0.0.13 is accepted and tagged, prepare a tightly scoped v0.0.14 proposal. Kind Families are the current likely direction, but no v0.0.14 implementation begins without Derek's explicit approval.
