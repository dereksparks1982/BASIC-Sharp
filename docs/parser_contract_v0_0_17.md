# BASIC# Parser Contract v0.0.17

## Status

The v0.0.17 build changes runtime IF behavior but does not expand parser grammar.

## IF form

```text
IF
[condition
<then> official word].
```

The condition remains one existing Fact-shaped expression.

Supported condition forms remain:

```text
Thing is state
Thing isnt state
Thing is relation target
```

Examples:

```text
ember is angry
north door isnt locked
brass key is on oak table
```

## Protected meaning

- IF has one condition.
- IF has one or more Connector-led official words.
- `<then>` and the already accepted `<than>` alias remain equivalent.
- No AND, OR, OTHERWISE, numeric comparison, Kind selector, or `that Kind` condition enters v0.0.17.
- The parser continues to emit IF rules in creator source order.

## Version

All newly emitted BSharp IR reports version `0.0.17`.
