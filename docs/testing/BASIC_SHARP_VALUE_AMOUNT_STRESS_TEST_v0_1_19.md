# BASIC# Value-and-Amount Stress Test v0.1.19

## Load

- 1,024 total Things.
- 512 direct guards.
- 256 inherited captains.
- 768 Things selected by `every guard`.
- 100 repeated amount events per source and saved-DKIR path.
- 76,800 explicit amount mutations per path.
- 76,800 exact value assignments per path.

## Required proofs

```text
Default damage amount compatibility: PASS
Explicit damage amounts: PASS
Generic Thing values: PASS
Exact value assignment: PASS
Exact value IF reactivity: PASS
Set action ordering: PASS
Missing-value atomicity: PASS
Overflow atomicity: PASS
No hidden health subtraction: PASS
Source and saved-DKIR parity: PASS
Separate runtime isolation: PASS
Deterministic final world: PASS
VALUE-AND-AMOUNT STRESS TEST: PASS
```

Timing is reported only and is not an acceptance gate.
