# DKScript Runtime Contract v0.1.13

> **Historical naming note:** This record predates the v0.1.14 technical identity migration. At the time recorded below, BASIC# still used the working technical name `DKScript`. Old package names, commands, paths, and Git messages are preserved as audit history.


## Purpose

The Ruby bootstrap runtime executes current BASIC# DKIR while keeping the creator-facing language simple.

## Current startup behavior

The runtime:

1. validates the DKIR format and required lists;
2. rejects DKIR containing compiler errors;
3. creates each Thing once;
4. rejects duplicate normalized Thing names;
5. applies START Facts;
6. runs true IF rules once during startup.

## Current event behavior

For one event:

1. normalize the event text;
2. try exact `WHEN` rules first;
3. try direct-Kind `WHEN` rules second;
4. check that the named Thing exists;
5. check that it has the required direct Kind;
6. remember the selected Thing only for this event;
7. make `that guard` refer to the selected guard;
8. execute the first matching rule;
9. report what matched, what BASIC# understood, what ran, and what changed.

## Context lifetime

Context such as:

```text
a guard means henry
that guard means henry
```

exists only during the current event execution.

It must not leak into:

- a later exact event;
- an unknown event;
- another `WHEN`;
- a separate Runtime instance.

v0.1.13 stress tests prove this boundary.

## Current official words

```text
(damage
(change
(carry
(unlock
```

DKIR stores the word name without `(`. BASIC# source keeps `(` as the creator-facing visual guide.

## Current matching priority

Exact Trigger:

```text
player attacks guard 250
```

is checked before:

```text
player attacks a guard
```

If both could match, the exact Trigger runs.

## v0.1.13 hardening

The runtime now rejects:

- missing or unsupported DKIR format;
- required top-level runtime fields that are not lists;
- duplicate Thing names;
- DKIR containing error diagnostics;
- unknown runtime official words.

## Stress boundary

Validated default standalone load:

```text
504 Things
20,004 total event executions across source and saved-DKIR paths
```

Validated automated suite:

```text
54 runs
4,330 assertions
0 failures
0 errors
0 skips
```

## Current limits

- direct Kind only;
- first matching rule only;
- one selected Thing per Kind per event;
- no event queue;
- no runtime-created Things;
- no creator-facing amounts;
- no save/load world format;
- DKIR debug JSON is not bytecode.
