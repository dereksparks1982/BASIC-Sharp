# DKScript Runtime Contract v0.0.10

> **Historical naming note:** This record predates the v0.0.14 technical identity migration. At the time recorded below, BASIC# still used the working technical name `DKScript`. Old package names, commands, paths, and Git messages are preserved as audit history.


## Purpose

v0.0.10 lets a WHEN Trigger select a named Thing by Kind and lets Connector lines use that same Thing.

## Working proof

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

## Matching rules

1. Exact event text is checked first so existing rules keep working.
2. When exact text does not match, the runtime compares the incoming event with the Trigger parts stored in BSharp IR.
3. A named Thing may satisfy `a guard` only when that Thing exists and its direct Kind is `guard`.
4. The selected Thing is remembered for the current event.
5. `that guard` uses the remembered guard.
6. Context is discarded after that event finishes.

## Plain errors

Unknown Thing:

```text
event Thing 'ghost' is not defined
```

Wrong Kind:

```text
ember is a dragon, not a guard
```

## Preserved runtime behavior

- START facts still establish the initial world.
- IF rules still run once after START.
- Exact WHEN events still work.
- `(damage`, `(change`, `(carry`, and `(unlock` keep their v0.0.09 behavior.
- Source and saved BSharp IR produce the same Trigger-context result.

## Not included

- No inherited Kind matching.
- No Kind Families.
- No multiple same-Kind selections.
- No event queue.
- No timing.
- No new syntax or official words.
