# BSharp IR Meaning Contract v0.1.21

## Root identity

```json
{
  "version": "0.1.21",
  "format": "bsir.debug.json"
}
```

BSharp Intermediate Representation remains normally called BSharp IR or BSIR. Current readable files use `.bsir.json`.

## Cause action

A creator action such as:

```text
(cause that guard attacks player
```

is represented as an explicit event template:

```json
{
  "line_number": 14,
  "action": "cause",
  "event": {
    "raw": "that guard attacks player",
    "actor": {
      "type": "previous",
      "text": "that guard",
      "selector": "that",
      "kind_name": "guard"
    },
    "action": "attack",
    "target": {
      "type": "object",
      "text": "player",
      "name": "player",
      "object_kind": "person"
    }
  }
}
```

## Template meaning

- `raw` preserves the creator's normalized event sentence.
- `actor` identifies the event actor.
- `action` is the normalized event word used for matching.
- `target` identifies the optional event target.
- `previous` means a singular Thing captured by the current WHEN context.
- The runtime converts `previous` references into concrete Thing names when the cause action runs.

## Allowed caused-event references

A caused event may use:

- a named Thing;
- built-in `player`;
- singular `that Kind` selected by the current WHEN.

It may not use:

- `every Kind`;
- an unbound `that Kind`;
- an ambiguous `a Kind` or bare Kind reference.

## Runtime authority

BSharp IR stores event templates, not a serialized live event line. The runtime constructs and owns the deterministic follow-up line during execution.

Serialized candidate lists remain debug information. Runtime Kind matching and set selection remain recalculated from loaded Things.

## Structured results

The root event result includes:

```json
{
  "follow_up_events": [],
  "event_trail": []
}
```

Each executed follow-up event records its event text, cause line, match result, matched rule, understood context, actions, IF activity, error, and fresh context. The root `state` is the final world after the complete chain.

## Retired format

`dkir.debug.json` remains retired and unsupported. The approved v0.1.20 transition message remains the recovery guidance.
