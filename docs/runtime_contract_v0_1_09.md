# DKScript Runtime Contract v0.1.09

> **Historical naming note:** This record predates the v0.1.14 technical identity migration. At the time recorded below, BASIC# still used the working technical name `DKScript`. Old package names, commands, paths, and Git messages are preserved as audit history.


## Purpose

v0.1.09 is the first bridge from "DKScript understands the script" to "DKScript performs the script."

The runtime consumes the existing DKIR debug structure. It does not invent a second language or bypass the compiler.

## Starting sequence

```text
1. Load DKIR.
2. Reject DKIR that contains compiler errors.
3. Create every defined Thing.
4. Apply every START Fact.
5. Check the existing IF rules once.
6. Receive one WHEN event.
7. Match that event to a Trigger.
8. Follow its Connector lines.
9. Run the official words.
10. Print the changed world state.
```

## Command

```bash
ruby compiler/basic_sharp.rb samples/first_room.bsharp --run "player attacks ember"
```

Run an existing DKIR file directly:

```bash
ruby compiler/basic_sharp.rb samples/first_room.ir.json --run "player attacks ember"
```

## Official words executed in this build

### `(damage`

Increases the Thing's runtime damage count by one.

```text
(damage ember
```

### `(change`

Changes the Thing to the stated condition. When the new condition has a known opposite, the opposite is removed.

```text
(change ember to angry
```

### `(carry`

Removes the Thing's current `in` or `on` location and records it as carried by the actor from the matched Trigger.

```text
(carry brass key
```

### `(unlock`

Removes `locked` and adds `unlocked`.

```text
(unlock north door
```

## Event matching

The first runtime uses normalized exact Trigger text. For example:

```text
player attacks ember
```

matches:

```text
WHEN
[player attacks ember
<then> (damage ember].
```

An unknown event does not run anything and returns a failed match.

## Boundaries

This build deliberately does not add:

- new DKScript syntax;
- new official words;
- dictionary changes;
- Kind Families;
- a continuous event queue;
- timed or repeated execution;
- bytecode or a VM;
- a complete health, inventory, door, or combat system.
