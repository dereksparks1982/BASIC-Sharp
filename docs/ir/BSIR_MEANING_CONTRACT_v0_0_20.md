# BSharp IR Meaning Contract v0.0.20

## Official identity

**Full name:** BSharp Intermediate Representation  
**Normal name:** BSharp IR  
**Compact abbreviation:** BSIR  
**Debug format marker:** `bsir.debug.json`  
**Recommended debug filename ending:** `.bsir.json`

## Root document

```json
{
  "version": "0.0.20",
  "format": "bsir.debug.json",
  "kinds": [],
  "objects": [],
  "facts": [],
  "events": [],
  "if_rules": [],
  "diagnostics": []
}
```

## Identity rule

All newly emitted representation documents use `bsir.debug.json`. All maintained samples and fixtures use `.bsir.json`. Current code, tests, tools, contracts, and diagnostics call the representation BSharp IR or BSIR.

## Retired format

`dkir.debug.json` is retired and unsupported. It is recognized only to provide the approved recovery message. Recompile the original `.bsharp` source to produce current BSIR.

## Structural meaning

The v0.0.20 identity migration does not redesign the document structure. Kinds, Things, facts, events, IF rules, references, values, amounts, and diagnostics retain their accepted v0.0.19 meaning.

## Authority

Runtime selection is recalculated from loaded Things. Serialized candidate lists remain debug information. Numeric and reference validation occurs before START mutates the world.
