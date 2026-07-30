# DKScript Changelog v0.1.13

> **Historical naming note:** This record predates the v0.1.14 technical identity migration. At the time recorded below, BASIC# still used the working technical name `DKScript`. Old package names, commands, paths, and Git messages are preserved as audit history.


## Focused Runtime Stress Test and Contract Hardening

- Added reusable high-volume runtime stress runner.
- Added focused automated stress coverage.
- Added duplicate normalized Thing-name protection for BSharp IR.
- Added BSharp IR format and top-level structure validation.
- Added the first formal BSharp IR meaning contract.
- Recorded Claude review decisions.
- Added Lisp research relevant to BASIC#.
- Recorded `(` as a creator-facing visual guide for official words.
- Added a preserved rejected-package audit.
- Added a dedicated new-thread handoff.
- Added no new creator-facing syntax or official words.

## Packaging correction

Earlier v0.1.13 archives were rejected. One archive passed all runtime tests but incorrectly included unchanged v0.1.12 files while claiming to be incremental.

The final corrected package was rebuilt from the actual difference between the accepted `v0.1.12` tag and the v0.1.13 candidate. It uses a distinct `CORRECTED_CHANGED_FILES_ONLY` filename and requires owner validation before acceptance.
