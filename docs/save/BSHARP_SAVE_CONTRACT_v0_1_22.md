# BSharp Save Contract v0.1.22

## Identity

```text
Full name: BSharp World Save
Normal name: BSharp Save
Extension: .bsave.json
Format: bsharp.save.json
Format version: 1
Ruby component: BasicSharp::WorldSave
```

## Top-level structure

```json
{
  "format": "bsharp.save.json",
  "format_version": 1,
  "created_by_basic_sharp": "0.1.22",
  "program_fingerprint": {
    "algorithm": "sha256-bsir-meaning-v1",
    "value": "..."
  },
  "world": {
    "settled": true,
    "things": [],
    "if_rules": []
  }
}
```

## Determinism

The same matching program and same settled world must produce byte-for-byte identical content. The document contains no timestamp, random ID, machine path, temporary filename, pending event, or runtime trace.

## Thing records

Each Thing appears once in original definition order and records:

- canonical name
- canonical Kind
- built-in identity
- sorted current states
- sorted current relationships
- sorted whole-number values

Damage is stored only as the authoritative `damage` value.

## IF records

Each IF record preserves source index, normalized condition text, and active/inactive state. The active flag must agree with the restored world condition.

## Program matching

`sha256-bsir-meaning-v1` fingerprints normalized program meaning and excludes paths, version labels, diagnostics, comments, formatting, indentation, and line numbers.

Wrong program:

```text
This BSharp Save belongs to a different BASIC# program.
Load it with the same .bsharp source or .bsir.json file that created it.
```

## Validation

Loading rejects invalid JSON, wrong format, unsupported version, malformed fingerprint, wrong program, Thing count/order/name/Kind/built-in changes, malformed states, contradictory opposite states, malformed relationships, missing relationship targets, value-schema changes, invalid whole numbers, IF count/order/condition changes, and IF flags inconsistent with the candidate world.

No candidate state is installed until every check passes.

## Atomic writing

The writer creates a temporary file in the destination directory, writes and flushes the complete deterministic document, then atomically renames it over the destination. Failure removes the temporary file and preserves the previous save.

## Settled-only boundary

v0.1.22 does not serialize pending follow-up events or unfinished work. A save is refused after unmatched or failed events and after loop protection stops a chain.
