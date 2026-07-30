# BSharp IR Meaning Contract v0.1.15

## Purpose

BSharp IR remains the language-neutral record of what the BASIC# bootstrap compiler understood.

```text
BASIC# source
-> parser
-> meaning checks
-> BSharp IR
-> runtime
```

It is readable debug JSON, not Ruby source and not final bytecode.

## Current top-level form

```json
{
  "version": "0.1.15",
  "format": "bsir.debug.json",
  "kinds": [],
  "objects": [],
  "facts": [],
  "events": [],
  "if_rules": [],
  "diagnostics": []
}
```

All six runtime collections must be lists.

## Kinds

Each Kind entry records one direct link:

```json
{
  "name": "wyrm",
  "parent": "dragon",
  "line_number": 4
}
```

v0.1.15 activates the transitive meaning of those links. The Runtime may follow:

```text
wyrm -> dragon -> creature -> thing
```

The BSharp IR still stores only direct links. It does not duplicate every ancestor onto every Thing.

## Kind integrity

The Runtime rejects BSharp IR with:

- missing Kind names;
- missing parents;
- duplicate parents for one Kind;
- unknown parents;
- circular parent chains.

## Objects

An object continues to store only its direct Kind:

```json
{
  "name": "ember",
  "kind": "wyrm",
  "builtin": false,
  "line_number": 8
}
```

Inherited membership is calculated from `kinds` when needed.

## References

`kind_one` and `kind` references now mean a Thing whose direct Kind or inherited family includes `kind_name`.

`previous` continues to mean the Thing selected earlier in the same event execution.

## Events

Exact named-Thing events are checked first.

Compatible Kind events are ranked by family distance:

```text
0 = direct Kind
1 = direct parent
2 = grandparent
3 = next ancestor
```

The nearest match runs. Source order resolves equal-distance ties.

## Stability boundary

Frozen for v0.1.15:

- one direct parent per Kind;
- inherited family walking through stored parents;
- exact Trigger priority;
- nearest compatible Kind priority;
- event-local `previous` context;
- plain rejection of broken or circular families.

Not frozen permanently:

- multiple inheritance;
- public long-term BSharp IR compatibility;
- bytecode layout;
- values, queues, and save-state representation.
