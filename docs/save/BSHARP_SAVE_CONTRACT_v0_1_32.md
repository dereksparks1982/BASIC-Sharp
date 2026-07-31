# BSharp Save Contract v0.1.32

## Typed Save format

Profile 2 worlds use `bsharp.save.json` format version 2. Each value slot stores an explicit type and value so creator text cannot be confused with a whole number:

```json
"values": {
  "label": { "type": "text", "value": "OPEN — RubyVM!" },
  "damage": { "type": "whole_number", "value": 1 }
}
```

Text stays exact UTF-8. Whole numbers keep the accepted nonnegative 32-bit range. Keys remain canonical identifiers.

## Compatibility

Accepted Profile 1 saves remain format version 1 and retain their unwrapped integer value representation. A program and Save must have matching meaning profile, fingerprint algorithm, fingerprint value, Thing identities, Kind identities, value names, and value types.

## Restore safety

The entire document is validated before world replacement. Invalid JSON, UTF-8, format/profile identity, fingerprint, schema, value type, whole-number range, Thing set, state/relation data, or unsettled world fails without partial mutation. Equivalent restored worlds produce deterministic snapshots and replay behavior.
