# DKScript Validation v0.1.10

> **Historical naming note:** This record predates the v0.1.14 technical identity migration. At the time recorded below, BASIC# still used the working technical name `DKScript`. Old package names, commands, paths, and Git messages are preserved as audit history.


## Baseline

Clean v0.1.09 reconstruction:

```text
35 runs
138 assertions
0 failures
0 errors
0 skips
```

## Ruby checks

Every file under `compiler/*.rb` passed `ruby -c`.

## Compiler sample

```text
DKScript Ruby Bootstrap Compiler v0.1.10
statements: 7
kinds: 1
definitions: 5
facts: 4
events: 3
if rules: 1
objects: 6
official words: 6
errors: 0
warnings: 0
```

## Runtime Kind Trigger proof

Event:

```text
player attacks henry
```

Observed words:

```text
(damage henry
(change henry to angry
```

Observed state:

```text
henry: kind=guard; states=angry; damage=1
```

Result: PASS.

## Exact event regression proof

Event:

```text
player attacks ember
```

Observed state:

```text
ember: kind=dragon; states=angry; damage=1
```

Result: PASS.

## Saved DKIR proof

Running `player attacks henry` from `samples/first_room.ir.json` produced the same Henry state as source execution.

Result: PASS.

## Error proofs

Unknown Thing:

```text
event Thing 'ghost' is not defined
```

Wrong Kind:

```text
ember is a dragon, not a guard
```

Result: PASS.

## Automated suite

```text
41 runs
178 assertions
0 failures
0 errors
0 skips
```

## Overlay proof

The changed-files-only payload was applied to a clean v0.1.09 reconstruction. The full v0.1.10 suite passed with the same result.

## Final result

PASS. No known validation failure is hidden.
