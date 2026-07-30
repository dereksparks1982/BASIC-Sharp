# DK Godot v0.3.45 Automated Playtest Pilot and Reporting Addendum

**Effective:** 2026-07-10

This addendum is mandatory for future Demon Killer builds.

## Automated patrol rule

- DK Test Pilot is the project's repeatable automated gameplay regression lane.
- Every future gameplay feature, migration, repair, or integration should add or update a deterministic patrol scenario when a stable automated assertion is practical.
- A patrol scenario must use bounded timeouts, explicit progress, clear assertions, and a human-readable report.
- A patrol failure must name the failing step and must not be silently ignored.

## Gate hierarchy

- Automated patrol PASS does not replace **Validate Current Project**.
- Automated patrol PASS does not replace manual visual, animation, audio, usability, or feel acceptance.
- Exact installed Godot validation remains authoritative.
- A feature is not accepted merely because a unit assertion passes while visible gameplay remains wrong.

## Third-party framework rule

- Third-party test frameworks must remain isolated, versioned, credited, and distributed with their required licence files.
- DK-specific logic belongs in DK-owned adapters and tests whenever practical.
- Framework updates require a deliberate versioned build, compatibility review, provenance update, and regression run.

## One-build and failure rule

- Automated patrol and project validation must not run simultaneously.
- Do not repeatedly rerun a crash-level patrol failure without diagnosis.
- New regressions discovered by the patrol must be recorded and corrected through the next proper numeric build or hotfix.

## Reporting rule

Every automated run must preserve enough information to determine:

- project and pilot version;
- Godot version and executable;
- child process ID and exit code;
- step count and individual results;
- warnings and errors;
- timeout or cancellation state;
- raw output and structured report locations.
