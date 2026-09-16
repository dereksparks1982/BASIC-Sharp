# BSIR Meaning Contract v0.0.32

## Identity

BSIR remains `bsir.debug.json`. `version` is `0.0.32`. The `meaning_profile` field is `bsharp.meaning.v1` for Profile 1 documents or `bsharp.meaning.v2` when creator text is present.

## Typed text representation

Text values use explicit fields rather than a decorated integer or normalized identifier. START facts use `text_value`:

```json
{
  "relation": "has",
  "value_name": "label",
  "text_value": "North Gate — CLOSED"
}
```

CHANGE actions use `to_text`, and IF equality conditions use `text_value`. The containing node therefore determines whether the literal is a starting value, new assigned value, or comparison value. Whole-number nodes retain the accepted Profile 1 `amount` and `to_amount` representation.

## Determinism and fingerprinting

- Identifier fields use canonical BASIC# names.
- Literal text stays exact.
- Source-only diagnostics and line numbers remain outside normalized meaning.
- Profile 1 uses `sha256-bsir-meaning-v1`; Profile 2 uses `sha256-bsir-meaning-v2`.
- Equivalent source and saved BSIR must produce the same normalized meaning and fingerprint.
- Profile 1 normalized meaning and fingerprints may not change merely because v0.0.32 is installed.

## Validation

A BSIR consumer must reject an unknown profile, a Profile 2 text node under Profile 1 identity, malformed UTF-8 text, unsupported text boundaries, missing type data, or any text/whole-number schema conflict before execution.
