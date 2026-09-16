# DKScript v0.0.13 Session Log

> **Historical naming note:** This record predates the v0.0.14 technical identity migration. At the time recorded below, BASIC# still used the working technical name `DKScript`. Old package names, commands, paths, and Git messages are preserved as audit history.


## Build

Focused Runtime Stress Test and Contract Hardening

## Owner direction

- Document why `(` exists in official words.
- Record that the mark was chosen as a visual guide for the creator.
- Review Claude's analysis.
- Make the last build of the night worth it.
- Stress test more heavily than a normal build.
- Add no needless creator-facing complexity.
- Correct the packaging mistake before acceptance.
- Preserve a complete handoff for tomorrow in a new thread.

## Accepted base

```text
v0.0.12 Plain-Language Runtime Trace
commit 25c9265
tag v0.0.12
42 runs
252 assertions
0 failures
0 errors
0 skips
owner validation passed twice on 2026-07-30
```

## Audit trail

The first v0.0.13 draft incorrectly named v0.0.11 as the required base.

A later archive correctly named v0.0.12 as the base but still contained unchanged v0.0.12 files. Derek installed it and ran all tests. The code passed 54 runs, 4,330 assertions, and the 20,004-event stress test, but the archive was rejected because its contents contradicted the changed-files-only claim.

The rejected package was not committed or tagged. Its failure record is preserved in:

```text
docs/audit/BASIC_SHARP_v0_0_13_REJECTED_PACKAGE_AUDIT.md
```

The final corrected archive was rebuilt from an exact v0.0.12-to-v0.0.13 file comparison and given a distinct filename containing `CORRECTED`.

## Records reviewed

- Company Bible and available addenda;
- accepted v0.0.12 handshake, code, tests, contracts, roadmap, handoff, and package records;
- owner terminal validation and Git acceptance for v0.0.12;
- owner terminal validation from the rejected v0.0.13 install;
- Claude review supplied by Derek;
- current runtime, parser, resolver, BSharp IR, sample, and automated suite;
- historical BASIC and Lisp research decisions.

## Work completed

- Advanced version to 0.0.13.
- Added runtime BSharp IR validation.
- Added duplicate Thing rejection.
- Added reusable stress tool.
- Added twelve focused automated stress tests.
- Reached 4,330 total assertions.
- Ran 20,004 default standalone event executions.
- Proved source and saved-BSharp IR parity.
- Proved deterministic execution.
- Proved event-context isolation.
- Proved separate Runtime isolation.
- Proved exact Trigger priority.
- Proved repeated damage trace accuracy.
- Added formal BSharp IR meaning contract.
- Added Claude decision record.
- Added Lisp research.
- Added official-word visual-guide document.
- Added rejected package audit.
- Added dedicated new-thread handoff.
- Rebuilt the ZIP as a true incremental patch over v0.0.12.

## Goblins found and repaired

### Duplicate BSharp IR Thing overwrite risk

Manually altered BSharp IR could contain two Things with the same normalized name. The runtime previously could silently replace the first with the second.

Repair:

```text
BSharp IR has more than one Thing named 'guard 1'
```

The runtime now rejects the duplicate.

### Missing BSharp IR format risk

The runtime now rejects BSharp IR without the supported `bsir.debug.json` format rather than assuming the document is valid.

### Changed-files packaging contamination

The rejected archive included unchanged v0.0.12 records.

Repair:

- rebuild from clean v0.0.12;
- calculate the actual changed path set;
- package only those paths;
- compare ZIP paths, manifest paths, and changed-files record;
- validate after applying the archive to a clean v0.0.12 tree.

## Protected decisions

- `(damage` remains the official word.
- `(` is for the creator's eyes first.
- `<then>` remains a Connector.
- `that guard` remains local to one event.
- no new syntax;
- no new official words;
- no Kind Families yet.

## Continuation

The corrected package requires owner validation from a restored `v0.0.12` baseline. After it passes, v0.0.13 may be committed and tagged. Tomorrow's continuation document is:

```text
docs/hand_off/BASIC_SHARP_v0_0_13_NEW_THREAD_HANDOFF.md
```
