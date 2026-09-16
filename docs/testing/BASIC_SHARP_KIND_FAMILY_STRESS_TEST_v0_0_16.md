# BASIC# Kind-Family Stress Test v0.0.16

## Default load

```text
Kind depth: 256
Overlapping ancestor Triggers: 64
Descendant Things: 500
Repeated events per execution path: 2,000
Total events per execution path: 2,002
```

## What it proves

- Iterative 256-level ancestry.
- All 64 ancestor Triggers remain compatible.
- The nearest ancestor wins regardless of broad-rule source position.
- An exact named-Thing Trigger wins before all Kind Triggers.
- The first source rule wins an equal-distance tie.
- `that Kind` stays bound to the correct descendant Thing.
- Source-built and saved-BSharp IR executions produce identical worlds.
- Replaying the same world and events is deterministic.
- Separate runtime instances share no mutable world state.

## Run

```bash
ruby tools/kind_family_stress.rb
```

## Optional load controls

```text
BASIC_SHARP_KIND_DEPTH
BASIC_SHARP_KIND_TRIGGERS
BASIC_SHARP_KIND_THINGS
BASIC_SHARP_KIND_EVENTS
```

Timing is printed for observation only. There is no arbitrary wall-clock failure threshold.
