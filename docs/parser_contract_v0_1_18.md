# BASIC# Parser and Resolver Contract v0.1.18

## Status

v0.1.18 does not add a new Body, Connector, or official-word grammar. It activates the already emitted `every Kind` semantic reference for action targets.

## Allowed form

```text
WHEN
[player sounds brass bell
<then> (damage every guard].
```

The same target form is allowed in IF action lists.

## Protected positions

`every Kind` is not accepted in:

```text
START facts
WHEN Triggers
IF conditions
```

BASIC# reports why instead of guessing group-event or all-versus-any condition meaning.

## Singular references

- A named Thing remains singular.
- `the Kind` remains singular and must resolve uniquely.
- `a Kind` remains a Trigger selector and is not a free-standing action choice.
- `that Kind` remains the one Thing selected by the matched WHEN event.
- `every Kind` is the explicit plural action selector.

## IR reference

```json
{
  "type": "kind_set",
  "selector": "every",
  "kind_name": "guard",
  "candidates": ["henry", "mara"]
}
```

`candidates` are compiler-time debug information only.

## Version

All newly emitted DKIR reports version `0.1.18`.
