# BSharp IR Meaning Contract v0.0.24

BSharp IR remains the deterministic readable representation of resolved BASIC# program rules.

```json
{
  "version": "0.0.24",
  "format": "bsir.debug.json"
}
```

v0.0.24 performs no schema migration.

Profile 1 semantic collections are:

```text
kinds
objects
facts
events
if_rules
```

Line numbers, raw source echoes, diagnostics, compiler version labels, machine paths, and Ruby object types are excluded from normalized Profile 1 meaning.

Equivalent source and saved BSIR must produce identical Profile 1 observations.
