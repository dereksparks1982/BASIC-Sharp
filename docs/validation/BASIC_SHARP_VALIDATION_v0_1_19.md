# BASIC# Validation v0.1.19

## Ruby

- Syntax: PASS
- Warnings: 0

## Automated suite

```text
135 runs
4,717 assertions
0 failures
0 errors
0 skips
```

## Stress lanes

```text
Runtime stress: PASS
Kind-family stress: PASS
IF-rule stress: PASS
Multiple-selection stress: PASS
Value-and-amount stress: PASS
```

## Compatibility

```text
v0.1.13 saved BSharp IR: PASS
v0.1.15 saved BSharp IR: PASS
v0.1.16 saved BSharp IR: PASS
v0.1.17 saved BSharp IR: PASS
v0.1.18 saved BSharp IR: PASS
Old damage action without amount defaults to one: PASS
```

## New behavior

```text
Whole-number START values: PASS
Default and explicit damage amounts: PASS
Exact value assignment: PASS
Exact-value IF reactivity and re-arming: PASS
Full WHEN body before IF settlement: PASS
Deterministic set order: PASS
Missing-value atomicity: PASS
Overflow atomicity: PASS
No hidden health subtraction: PASS
Malformed numeric BSharp IR rejected before START mutation: PASS
Source/saved-BSharp IR parity: PASS
Runtime isolation: PASS
Deterministic replay: PASS
```
