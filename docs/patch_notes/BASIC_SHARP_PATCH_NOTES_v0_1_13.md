# DKScript Patch Notes v0.1.13

> **Historical naming note:** This record predates the v0.1.14 technical identity migration. At the time recorded below, BASIC# still used the working technical name `DKScript`. Old package names, commands, paths, and Git messages are preserved as audit history.


BASIC# received its first heavy runtime pressure test.

```text
504 Things
20,004 event executions
source and saved DKIR parity: PASS
runtime isolation: PASS
deterministic final world: PASS
```

Automated suite:

```text
54 runs
4,330 assertions
0 failures
0 errors
0 skips
```

The build also adds:

- a formal DKIR meaning contract;
- duplicate Thing protection;
- malformed DKIR format protection;
- Claude review decisions;
- Lisp research;
- the protected rule that `(` in `(damage` is a visual guide for the creator;
- a rejected-package audit;
- a dedicated tomorrow/new-thread handoff.

The final archive is a corrected incremental changed-files-only patch over accepted v0.1.12. Earlier v0.1.13 archives are rejected and must not be committed or tagged.

No new BASIC# syntax or official word was added.
