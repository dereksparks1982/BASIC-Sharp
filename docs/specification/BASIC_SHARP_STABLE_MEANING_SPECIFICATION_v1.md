# BASIC# Stable Meaning Specification v1

## Status

This is the normative meaning specification for **BSharp Meaning Profile 1**.

```text
Profile identifier: bsharp.meaning.v1
Established by: BASIC# v0.0.24
Conformance manifest: spec/meaning_v1/BASIC_SHARP_MEANING_PROFILE_v1.json
```

The words MUST, MUST NOT, SHOULD, SHOULD NOT, and MAY describe conformance requirements.

## 1. Purpose

This specification defines what accepted BASIC# programs mean independently of Ruby classes, Ruby method names, memory layout, cache design, timing, operating-system paths, or user-interface presentation.

A compiler or runtime claims Profile 1 conformance only when it produces the same normalized program meaning, deterministic selections, execution order, final world state, save meaning, and ASK answer data required by the Profile 1 fixtures.

## 2. Source structure

### 2.1 Heads

Profile 1 has exactly five Heads:

```text
KINDS
DEFINE
START
WHEN
IF
```

`WORLD`, `STATES`, `RELATIONS`, `ACTIONS`, `WHILE`, and `OTHERWISE` are not Profile 1 Heads.

### 2.2 Bodies

A Head is followed by one Body. A Body begins with `[` and ends with `].`. Body lines remain ordered.

### 2.3 Connectors

`<then>` is the canonical result Connector. `<than>` is an accepted equivalent with identical meaning.

## 3. Things and Kinds

### 3.1 Things

A Thing is one named world object. Thing names are globally unique after canonical lowercase and whitespace normalization. The built-in Thing `player` exists before creator definitions and has Kind `person`.

Creator Things are created by DEFINE in source order. That order is the stable definition order used by deterministic world snapshots and set selection.

### 3.2 Kinds

A Kind classifies Things. Profile 1 supports built-in Kinds and creator-defined Kinds. Each creator-defined Kind has one direct parent. The complete family consists of the Kind, its parent, and all ancestors. Circular families are invalid.

A Thing of a descendant Kind matches every ancestor Kind in its family.

## 4. START meaning

START establishes the initial world before external events.

Profile 1 START facts support:

- states;
- opposing-state removal;
- relationships;
- whole-number values;
- the built-in `damage` value.

Every Thing starts with `damage` equal to zero. Damage and health are separate values.

Whole numbers range from 0 through 2,147,483,647. A creator-defined value must be established by START before an action changes it. Duplicate starting assignments to the same value on the same Thing are invalid.

After START facts are applied, reactive IF rules settle. Follow-up events caused by startup IF rules then run in deterministic order. A successfully constructed world is settled and save-ready.

## 5. Event matching

One supplied event selects at most one WHEN rule.

Priority is:

```text
1. Exact named-Thing match
2. Nearest inherited Kind match
3. Source order when Kind distance is equal
```

An unmatched event changes nothing and reports no matching rule.

A singular Kind reference in a matched event binds the actual selected Thing into event context. `that Kind` resolves to that bound Thing for the complete action body.

## 6. Actions and official words

Profile 1 executable official words are:

```text
(damage
(change
(carry
(unlock
(cause
```

The opening `(` is part of the creator-facing visual identity of an official word.

### 6.1 Damage

`(damage Thing` increases `damage` by one. `(damage Thing by N` increases it by N. Overflow is invalid and must not partially change a selected set.

### 6.2 Change

`(change Thing to state` changes a state and removes its accepted opposite. `(change value of Thing to N` assigns an established whole-number value exactly.

### 6.3 Carry and unlock

`(carry` and `(unlock` apply their accepted state changes to the selected Thing or Thing set.

### 6.4 Cause

`(cause event text` explicitly creates a follow-up event. Existing state or value changes do not secretly create events.

## 7. Deterministic selections

`every Kind` selects all direct and inherited members in definition order.

When one action targets a set, the complete set receives that action line before BASIC# begins the next action line. Preflight validation occurs before an accepted atomic set action begins.

`that Kind` remains singular event context and is not replaced by set meaning.

## 8. Reactive IF rules

IF rules evaluate after START and after each complete action body.

A rule wakes when its condition changes from false to true. It remains quiet while the condition stays true. It rearms after the condition becomes false.

Cascades run in source order until the world settles. An IF action body completes before the next IF evaluation pass. Infinite or repeating cascades are stopped by the accepted loop protection with a plain explanation.

## 9. Follow-up-event order

The stable order is:

```text
current action body
IF settlement
first-created follow-up event
that event's IF settlement
next waiting event
```

Events created by a follow-up event join the end of the waiting line. One external event may produce at most 1,024 follow-up events.

A caused event captures actual `that Kind` names before it waits. Each later event receives fresh matching context.

## 10. BSharp IR meaning

BSharp IR uses format `bsir.debug.json`. Profile 1 meaning is carried by these top-level semantic collections:

```text
kinds
objects
facts
events
if_rules
```

Compiler version labels, diagnostics, line numbers, raw source echoes, Ruby object shapes, and file paths are not Profile 1 program meaning.

Equivalent source and saved BSharp IR must produce the same normalized meaning and runtime observations.

## 11. BSharp Save meaning

BSharp Save remains:

```text
format: bsharp.save.json
format version: 1
fingerprint algorithm: sha256-bsir-meaning-v1
```

A save preserves a fully settled world, including Thing order and identity, Kinds, states, relationships, values, and IF active state.

Loading validates the complete candidate before changing the live world. START, startup IF rules, and startup follow-up events do not replay. Identical settled worlds from the same program produce byte-identical save contents except where an explicitly non-meaning creator-version label is excluded from Profile comparison.

## 12. BSharp ASK meaning

BSharp ASK remains:

```text
format: bsharp.ask.json
format version: 1
maximum questions per command: 256
```

ASK is read-only. Event inspection uses the accepted event matching rules without running actions. Equivalent source, BSharp IR, and restored worlds produce the same answer data.

## 13. Diagnostics and invalid boundaries

Invalid source must not be silently assigned invented meaning. The six abandoned Head names receive a plain explanation listing the five current Heads.

Diagnostics may improve in clarity without changing valid Profile 1 program meaning, except exact messages explicitly locked by Derek remain exact.

## 14. Determinism

Profile 1 determinism includes:

- definition order;
- Kind-family distance;
- source-order ties;
- action-line order;
- set-member order;
- IF cascade order;
- follow-up-event order;
- final world order and state;
- BSharp Save meaning;
- BSharp ASK answer data.

Performance timing is not conformance meaning.

## 15. Conformance

The Profile 1 manifest contains 13 cases covering source structure, Kinds and Things, START, event priority, context, selections, IF rules, numbers, follow-up events, saves, ASK, and invalid boundaries.

A conforming implementation MUST pass every case and MUST NOT serialize Ruby-specific objects, machine paths, timestamps, or random identifiers into the fixtures.
