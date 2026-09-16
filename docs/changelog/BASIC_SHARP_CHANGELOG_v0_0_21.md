# BASIC# Changelog v0.0.21

## Follow-Up Events and Deterministic Event Order

- Added `(cause` for explicit creator-authored follow-up events.
- Added BSharp IR event templates inside cause actions.
- Finished the current action body and IF settlement before running another event.
- Added first-created, first-run ordering with nested events appended to the end.
- Captured singular `that Kind` references when events are created.
- Added fresh context for every event.
- Continued after unmatched follow-up events.
- Stopped after a follow-up runtime error.
- Discarded staged events when their body or IF settlement failed.
- Added 1,024-event loop protection, bounded trace output, complete structured results, tests, sample, and stress coverage.
- Added no automatic hidden events and no plural caused events.
