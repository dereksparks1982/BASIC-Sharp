# BSharp IR Meaning Contract v0.1.16

## Status

BSharp IR remains readable debug JSON. It is not final bytecode.

## Required top-level lists

```text
kinds
objects
facts
events
if_rules
diagnostics
```

## Kind entry

A Kind entry must be an object containing text fields:

```json
{
  "name": "wyrm",
  "parent": "dragon"
}
```

The name and parent must be present, non-empty text.

## Family rules

- A Kind name may appear once.
- Identical duplicates are errors.
- Conflicting parents are errors.
- Every parent must be built in or declared in the document.
- Family loops are errors and report the complete loop.
- Entry order does not prevent runtime validation from recognizing a parent declared elsewhere in the list.

## Thing Kind rule

Every Thing's `kind` must name a built-in or declared Kind.

Example failure:

```text
ember says it is a wyrm, but wyrm is not a known Kind
```

## Matching rules

- A Thing matches its direct Kind at distance zero.
- Each parent increases distance by one.
- Exact named-Thing Triggers win before Kind matching.
- The shortest compatible distance wins.
- Equal distances preserve event list order.

## Compatibility

The runtime accepts valid v0.1.13 and v0.1.15 BSharp IR fixtures. Stricter rejection applies only to malformed documents that were never valid language truth.
