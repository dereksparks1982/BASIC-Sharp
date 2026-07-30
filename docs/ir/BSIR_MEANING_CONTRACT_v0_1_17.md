# BSharp IR Meaning Contract v0.1.17

## Format

The readable bootstrap format remains:

```text
bsir.debug.json
```

v0.1.17 does not add a new IF field or redesign the schema.

## IF rule meaning

Existing entries retain this shape:

```json
{
  "line_number": 1,
  "if": { "raw": "ember is angry" },
  "then": []
}
```

The semantic change is runtime-side:

- rules preserve source order;
- condition active state is runtime session memory, not stored in BSharp IR;
- false-to-true transitions wake rules;
- false conditions re-arm rules;
- source-built and saved-BSharp IR execution must produce identical IF traces and worlds.

## Session-only data

The following are never serialized into accepted BSharp IR:

- IF active bits;
- seen loop signatures;
- firing counters;
- current event context;
- current IF trace.

Loading the same valid BSharp IR into two Runtime instances must create separate IF memory.

## Compatibility

The runtime accepts valid accepted fixtures from v0.1.13, v0.1.15, and v0.1.16.
