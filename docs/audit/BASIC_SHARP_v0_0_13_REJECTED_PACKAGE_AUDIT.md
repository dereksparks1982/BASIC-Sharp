# DKScript v0.0.13 Rejected Package Audit

> **Historical naming note:** This record predates the v0.0.14 technical identity migration. At the time recorded below, BASIC# still used the working technical name `DKScript`. Old package names, commands, paths, and Git messages are preserved as audit history.


**Date:** 2026-07-30  
**Status:** Preserved failure record  
**Accepted baseline:** v0.0.12, commit `25c9265`, tag `v0.0.12`

## What happened

Two v0.0.13 package attempts were produced before the final corrected package.

The first draft incorrectly described v0.0.11 as the required installation base. It was rejected before acceptance.

A later package was described as an incremental changed-files-only patch over v0.0.12, but its ZIP still contained unchanged v0.0.12 files. Derek installed that package and ran the complete normal and stress validation. The code passed:

```text
54 runs
4,330 assertions
0 failures
0 errors
0 skips

504 Things
20,004 total event executions
STRESS TEST: PASS
```

The build was still rejected because the package contents did not match the changed-files-only claim.

## Exact failure

The rejected ZIP included files such as:

```text
BUILD_HANDSHAKE_v0_0_12.md
docs/changed_files/BASIC_SHARP_CHANGED_FILES_v0_0_12.txt
docs/changelog/BASIC_SHARP_CHANGELOG_v0_0_12.md
docs/parser_contract_v0_0_12.md
docs/runtime_contract_v0_0_12.md
```

Those were already part of the accepted v0.0.12 baseline and did not belong in an incremental v0.0.13 package.

## What did not fail

- BASIC# source compilation
- plain-language runtime tracing
- source and saved-BSharp IR parity
- the 54-run automated suite
- the 20,004-event standalone stress test

The defect was packaging scope, not runtime behavior.

## Corrective action

The final corrected package was rebuilt by comparing the v0.0.13 candidate directly against a clean v0.0.12 tree. Only paths that are new or changed from v0.0.12 are included.

The corrected package uses a distinct filename so it cannot be confused with the rejected download:

```text
DKScript_Ruby_Bootstrap_Compiler_v0_0_13_FOCUSED_RUNTIME_STRESS_TEST_AND_CONTRACT_HARDENING_CORRECTED_CHANGED_FILES_ONLY.zip
```

Before applying it, Derek's working tree must be restored to the accepted v0.0.12 tag. The corrected package must then be applied and validated again before v0.0.13 is committed or tagged.

## Acceptance status

The rejected packages are not accepted baselines and must not be committed or tagged.

v0.0.13 remains a candidate until the corrected package passes owner-side validation.
