# DKScript Runtime Contract v0.0.12

> **Historical naming note:** This record predates the v0.0.14 technical identity migration. At the time recorded below, BASIC# still used the working technical name `DKScript`. Old package names, commands, paths, and Git messages are preserved as audit history.


## Public language identity

The public language name is BASIC#.

The current Ruby runtime and technical names remain DKScript bootstrap components.

## Purpose

v0.0.12 adds a plain-language window into Runtime Trigger Context.

The trace must explain:

1. which `WHEN` matched;
2. what a Kind phrase meant;
3. what `that guard` meant;
4. which event official words ran;
5. the immediate world change caused by each event word.

## Kind Trigger proof

```text
WHEN
[player attacks a guard
<then> (damage that guard
<then> (change that guard to angry].
```

Runtime event:

```text
player attacks henry
```

Required trace:

```text
what matched:
  player attacks a guard
what I understood:
  a guard means henry
  that guard means henry
what happened:
  (damage henry
  henry damage is now 1
  (change henry to angry
  henry is now angry
```

## Exact event proof

```text
player attacks ember
```

Required trace includes:

```text
what matched:
  player attacks ember
what happened:
  (damage ember
  ember damage is now 1
  (change ember to angry
  ember is now angry
```

## Current event change explanations

```text
(damage  -> NAME damage is now NUMBER
(change  -> NAME is now STATE
(carry   -> NAME is now carried by CARRIER
(unlock  -> NAME is now unlocked
```

These explanations are runtime output, not new BASIC# syntax or official words.

## Preserved behavior

- START facts establish the initial world.
- IF rules run once after START.
- Exact WHEN events work.
- Named Things may satisfy direct Kind Triggers.
- Trigger context remembers one selected Thing per Kind during that event.
- `(damage`, `(change`, `(carry`, and `(unlock` keep their current behavior.
- Source and saved BSharp IR produce the same trace and state.
- Existing world-state output remains available.

## Excluded

- No Kind Families.
- No inherited Kind matching.
- No multiple selected Things.
- No event queue.
- No ASK execution.
- No recovery syntax.
- No timing.
- No new syntax or official words.
