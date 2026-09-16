# BSharp IR Meaning Contract v0.0.23

BSharp IR remains the deterministic debug representation of BASIC# program meaning.

v0.0.23 does not change the BSIR schema. Current documents use:

```json
{
  "version": "0.0.23",
  "format": "bsir.debug.json"
}
```

ASK reads the same resolved BSIR structures used by runtime execution. Event inspection reports the rule and action templates already present in BSIR; it does not add hidden meaning or mutate the document.

Equivalent source and saved BSIR must produce identical ASK answer data for the same world and questions.
