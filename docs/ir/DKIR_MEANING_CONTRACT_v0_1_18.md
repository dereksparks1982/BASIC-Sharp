# DKIR Meaning Contract v0.1.18

## Format

The readable bootstrap format remains:

```text
dkir.debug.json
```

## Multiple-selection reference

```json
{
  "type": "kind_set",
  "text": "every guard",
  "selector": "every",
  "kind_name": "guard",
  "candidates": ["henry", "mara", "otto"]
}
```

Meaning:

- `selector` must be `every`.
- `kind_name` must be a known nonempty text Kind.
- `candidates` are optional debug information and are never runtime authority.
- Runtime membership is derived from current `objects`, object order, and inherited Kind meaning.

## Allowed location

A `kind_set` is valid only as the target of an official word inside a WHEN or IF action list in v0.1.18.

It is invalid in START facts, WHEN actor/target references, and IF conditions.

## Determinism

Source-built and saved-DKIR execution must return identical ordered selections, steps, traces, and final world state.

## Session-only data

Current set snapshots and event context are not written back into DKIR.

## Compatibility

The runtime accepts valid accepted fixtures from v0.1.13, v0.1.15, v0.1.16, and v0.1.17.
