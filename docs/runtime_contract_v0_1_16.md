# BASIC# Runtime Contract v0.1.16

## Runtime initialization

1. Read and validate the BSharp IR document shape.
2. Read every Kind entry in source order.
3. Reject malformed, missing, empty, non-text, duplicate, conflicting, unknown-parent, or circular Kind entries.
4. Build one validated Kind-distance index.
5. Create Things and reject any Thing whose Kind is unknown.
6. Apply START Facts.
7. Run the existing one-pass startup IF rules.

## Kind-distance index

For every known Kind, the runtime stores the distance to itself and each ancestor.

Example:

```text
wyrm: 0
dragon: 1
creature: 2
thing: 3
```

The index is built iteratively and reused during event matching.

## Trigger priority

1. Exact named-Thing Trigger.
2. Nearest compatible Kind Trigger.
3. First rule in creator source order when compatible rules have equal distance.

This priority is a tested contract, not an incidental implementation detail.

## Context

- `a Kind` binds only for the current event.
- `that Kind` resolves to the Thing bound by that Trigger.
- Context does not leak into exact, unknown, later, or separate runtime events.

## Compatibility

Valid saved BSharp IR from v0.1.13 and v0.1.15 remains executable.

## Limits

- One direct parent per Kind.
- No multiple inheritance.
- No event queue or repeated IF checking.
- Timing measurements are informational and never a correctness gate.
