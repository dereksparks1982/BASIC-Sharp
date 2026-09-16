# BASIC# Runtime Contract v0.0.22

## New-world construction

Without `--load-world`, runtime construction remains:

```text
create Things
-> apply START
-> settle startup IF rules
-> drain startup follow-up events
-> accept an external event
```

A world may be saved after that process finishes without error.

## Restored-world construction

With `--load-world`, runtime construction is:

```text
read and validate matching program rules
-> validate the complete BSharp Save into candidate state
-> install the candidate state atomically
-> accept an external event
```

START, startup IF rules, and startup follow-up events do not run during restore.

## Save-ready rule

A save is allowed only:

- after successful startup settlement;
- after loading a valid settled save;
- after one matched external event and all its IF/follow-up work finish without error.

A save is refused after an unmatched event, runtime error, IF loop failure, follow-up chain failure, or the 1,024-event circuit breaker.

## Preserved state

- Thing order, name, Kind, and built-in flag
- states
- relationships
- all whole-number values
- authoritative damage value
- IF active/inactive state

## Atomic restore

The save is fully validated before `@objects` or IF-active state changes. Failed validation leaves the previous runtime snapshot untouched.

## Event execution

The accepted v0.0.21 order remains:

```text
current WHEN body
-> complete IF settlement
-> first waiting follow-up event
-> repeat first-created, first-run
```

Saving occurs only after this line is empty and the event result is successful.
