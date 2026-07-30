# DKScript Master Thread Handoff

## Current Transfer State

**Public language name:** BASIC#  
**Bootstrap project:** DKScript Ruby Bootstrap Compiler  
**Accepted baseline:** v0.1.12 Plain-Language Runtime Trace  
**Accepted commit:** `25c9265`  
**Accepted tag:** `v0.1.12`  
**Current candidate:** v0.1.13 Focused Runtime Stress Test and Contract Hardening  
**Candidate status:** corrected package built; owner validation pending  
**Required installation base:** exact `v0.1.12` tag  
**Package type:** incremental changed-files-only, direct project-root payload  
**Corrected package:** `DKScript_Ruby_Bootstrap_Compiler_v0_1_13_FOCUSED_RUNTIME_STRESS_TEST_AND_CONTRACT_HARDENING_CORRECTED_CHANGED_FILES_ONLY.zip`  
**Project path:** `/home/dereksparks1982/DKLab/Projects/DKScript`  
**Download path:** `/home/dereksparks1982/Downloads/`

## Baseline truth

Derek installed, validated, committed, and tagged v0.1.12.

Owner validation was run twice on 2026-07-30. Both runs reported:

```text
42 runs
252 assertions
0 failures
0 errors
0 skips
```

Accepted Git state:

```text
commit 25c9265
tag v0.1.12
branch main
working tree clean
```

## Rejected v0.1.13 package history

A previously supplied v0.1.13 archive was installed and fully tested. Runtime behavior passed:

```text
54 runs
4,330 assertions
0 failures
0 errors
0 skips
20,004 standalone event executions
STRESS TEST: PASS
```

However, the archive was rejected because it included unchanged v0.1.12 files while claiming to be an incremental changed-files-only package. The code was not accepted, committed, or tagged.

This failure is preserved at:

```text
docs/audit/DKSCRIPT_v0_1_13_REJECTED_PACKAGE_AUDIT.md
```

The rejected package must not be used as a baseline.

## Corrected v0.1.13 package

The corrected archive was rebuilt from a direct comparison against a clean v0.1.12 tree. It contains only files that are new or changed from v0.1.12.

Before installation, restore the project to the accepted tag:

```bash
git reset --hard v0.1.12
```

Then apply the corrected package and rerun the complete validation sequence from `BUILD_HANDSHAKE_v0_1_13.md`.

## v0.1.13 completed work

- Preserves v0.1.12 plain-language runtime tracing.
- Adds focused high-volume runtime stress tests.
- Adds reusable `tools/runtime_stress.rb`.
- Tests hundreds of Things and thousands of events.
- Proves exact Trigger priority over direct-Kind Trigger matching.
- Proves selected-Thing context does not leak between events.
- Proves separate Runtime instances do not share state.
- Proves deterministic results from identical worlds and events.
- Proves source-built and saved-DKIR execution parity under long sequences.
- Rejects duplicate normalized DKIR Thing names.
- Rejects missing or unsupported DKIR format.
- Requires runtime top-level DKIR fields to be lists.
- Adds the first formal DKIR meaning contract.
- Records Claude review decisions.
- Adds Lisp research relevant to BASIC#.
- Records `(` as a creator-facing official-word visual guide.
- Adds no new creator syntax or official words.

## Internal stress proof

```text
54 runs
4,330 assertions
0 failures
0 errors
0 skips

504 Things
10,002 events through source-built DKIR
10,002 events through saved DKIR
20,004 total event executions
STRESS TEST: PASS
```

## Protected language decisions

- BASIC# is a scripting language made for non-programmers, by non-programmers.
- The compiler and engine do the heavy lifting.
- The creator enjoys the ride.
- `(` in `(damage` exists as a visual guide for the creator.
- `(damage` is the official word.
- `ember` is a defined Thing that follows the word.
- `<then>` is a Connector.
- Damage happening is the result.
- `[` touches the first Body word.
- Ruby remains temporary scaffolding.
- Context such as `that guard` lives only inside one event execution.

## Excluded work

- No Kind Families.
- No multiple inheritance.
- No multiple selected Things.
- No event queue.
- No creator-facing values or amounts.
- No time or repetition language feature.
- No ASK implementation.
- No capitalization or source-spacing behavior change.
- No technical rename.
- No bytecode, VM, DK Engine bridge, or self-hosting implementation.

## Known risks and limits

- Direct Kind matching does not yet walk Kind families.
- Exact rules are checked before direct-Kind rules.
- The first matching rule runs.
- One selected Thing is stored per Kind during one event.
- IF rules still run once during startup.
- Damage remains an internal integer count without creator-facing amount syntax.
- DKIR remains debug JSON rather than bytecode.
- Long-term DKIR version compatibility is not frozen.

## Rollback point

```bash
git reset --hard v0.1.12
```

## Current continuation point

1. Derek restores the project to `v0.1.12`.
2. Derek installs the corrected v0.1.13 package.
3. Derek runs the normal suite and standalone stress test.
4. If all results pass, commit and tag v0.1.13.
5. In the next thread, prepare the exact v0.1.14 proposal and wait for explicit build approval.

## Dedicated tomorrow handoff

```text
docs/hand_off/DKSCRIPT_v0_1_13_NEW_THREAD_HANDOFF.md
```

## Cumulative History

### v0.1.13 - 2026-07-30

Focused Runtime Stress Test and Contract Hardening. The first archives were rejected for base/package-scope errors. The final corrected archive is a true incremental patch over v0.1.12. Owner validation of the corrected archive remains pending.

### v0.1.12 - 2026-07-30

Plain-Language Runtime Trace. Owner-validated twice, accepted at commit `25c9265`, and tagged `v0.1.12`.

### v0.1.11 - 2026-07-30

BASIC# Language Foundation and Historical BASIC Research. Accepted at commit `9fb30ae` and tag `v0.1.11`.

### v0.1.10 - 2026-07-29

Runtime Trigger Context. Included and owner-validated through v0.1.11.

### v0.1.09 - 2026-07-29

First Runtime Execution.

### v0.1.08 - 2026-07-29

Body Structure and User Kinds. Accepted at commit `d6c92d1` and tag `v0.1.08`.
