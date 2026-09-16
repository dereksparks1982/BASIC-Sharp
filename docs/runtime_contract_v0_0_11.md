# DKScript Runtime Contract v0.0.11

> **Historical naming note:** This record predates the v0.0.14 technical identity migration. At the time recorded below, BASIC# still used the working technical name `DKScript`. Old package names, commands, paths, and Git messages are preserved as audit history.


## Public language identity

The owner-selected public language name is BASIC#.

The current Ruby runtime and its technical names remain DKScript bootstrap components in this version. The technical rename is deferred.

## Runtime behavior

v0.0.11 preserves the complete v0.0.10 Runtime Trigger Context behavior.

Working proof:

```text
KINDS
[guard is a person].

DEFINE
[a guard named henry].

WHEN
[player attacks a guard
<then> (damage that guard].
```

Runtime event:

```text
player attacks henry
```

Required behavior:

```text
henry is confirmed as a guard
that guard means henry
(damage runs on henry
```

## Preserved behavior

- START facts establish the initial world.
- IF rules run once after START.
- Exact WHEN events work.
- Named Things may satisfy direct Kind Triggers.
- Trigger context remembers the selected Thing during that event.
- `(damage`, `(change`, `(carry`, and `(unlock` keep their current behavior.
- Source and saved BSharp IR produce the same result.

## No runtime expansion in v0.0.11

- No Kind Families.
- No inherited Kind matching.
- No multiple selected Things.
- No event queue.
- No ASK execution.
- No tracing interface.
- No recovery syntax.
- No timing.
- No new syntax or official words.
