# BASIC# Validation v0.0.16

## Ruby syntax

```text
PASS
```

Compiler, tools, and tests were checked with Ruby warnings enabled and syntax warnings treated as failures.

## Automated suite

```text
79 runs
4,473 assertions
0 failures
0 errors
0 skips
```

## Existing runtime stress

```text
BASIC# Runtime Stress Test v0.0.16
Things: 504
Events per execution path: 10,003
Source and saved BSharp IR parity: PASS
Separate runtime isolation: PASS
Unknown Thing explanation: PASS
Inherited Kind matching: PASS
Wrong Kind explanation: PASS
Deterministic final world: PASS
STRESS TEST: PASS
```

## Kind-family stress

```text
BASIC# Kind-Family Stress Test v0.0.16
Kind depth: 256
Overlapping ancestor Triggers: 64
Descendant Things: 500
Repeated events per execution path: 2,000
256-level ancestry: PASS
Exact Trigger priority: PASS
Nearest Kind priority: PASS
Same-distance source-order priority: PASS
Event context isolation: PASS
Source and saved-BSharp IR parity: PASS
Deterministic replay: PASS
Separate runtime isolation: PASS
KIND-FAMILY STRESS TEST: PASS
```

## Compatibility

```text
v0.0.13 saved-BSharp IR fixture: PASS
v0.0.15 saved-BSharp IR fixture: PASS
current source execution: PASS
current saved-BSharp IR execution: PASS
```

## Malformed BSharp IR validation

```text
non-object Kind entry: PASS
missing name: PASS
missing parent: PASS
empty name: PASS
empty parent: PASS
non-text name: PASS
non-text parent: PASS
duplicate same parent: PASS
duplicate conflicting parent: PASS
unknown parent: PASS
circular family: PASS
Thing with unknown Kind: PASS
```
