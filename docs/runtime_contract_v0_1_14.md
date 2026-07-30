# BASIC# Runtime Contract v0.1.14

## Scope

v0.1.14 changes technical identity and project documentation without changing accepted runtime behavior.

## Active runtime identity

```text
Ruby namespace: BasicSharp
Runtime class: BasicSharp::Runtime
Banner: BASIC# Runtime v0.1.14
```

## Preserved behavior

- START Facts create initial world state.
- Startup IF rules run once.
- Exact Triggers are checked before direct-Kind Triggers.
- One selected Thing per Kind is scoped to one event execution.
- `(damage`, `(change`, `(carry`, and `(unlock` retain their accepted behavior.
- Unknown Thing and wrong-Kind explanations remain plain language.
- Separate Runtime instances do not share state.
- Source-built and saved-BSharp IR execution remain equivalent.

## BSharp IR compatibility

The runtime continues to accept `bsir.debug.json`. A saved v0.1.13 BSharp IR fixture is included and tested. The version field identifies the producing compiler but does not prevent v0.1.14 from executing that accepted document.

## Explicit non-change

Runtime matching remains direct Kind matching only. Parent chains stored under `kinds` are not yet walked during Trigger matching.
