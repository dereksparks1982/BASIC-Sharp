# BASIC# Runtime Stress Test v0.1.13

## Goal

Pressure the runtime features that already exist before adding Kind Families.

This build intentionally adds more testing than a normal feature patch.

## Default standalone load

```text
300 guards
200 dragons
player
stress key
stress table
stress door
504 total Things

10,002 events through source-built DKIR
10,002 events through saved DKIR
20,004 total event executions
```

## Automated suite coverage

The v0.1.13 automated stress tests cover:

- hundreds of Things;
- many Things sharing one direct Kind;
- exact Trigger priority over a direct-Kind Trigger;
- two thousand repeated contextual events in one test;
- selected-Thing context remaining local;
- separate runtimes not sharing state;
- deterministic worlds from identical starts and events;
- long source-versus-saved-DKIR event sequences;
- unknown Thing explanations under load;
- wrong Kind explanations under load;
- repeated damage counts remaining exact;
- trace text remaining truthful after repeated events;
- carry relation changes;
- startup IF and unlock behavior;
- duplicate DKIR Thing rejection;
- missing/unsupported DKIR format rejection.

## Standalone command

```bash
ruby tools/runtime_stress.rb
```

Optional controls:

```bash
BASIC_SHARP_STRESS_GUARDS=500 \
BASIC_SHARP_STRESS_DRAGONS=250 \
BASIC_SHARP_STRESS_EVENTS=20000 \
ruby tools/runtime_stress.rb
```

These environment controls belong to the developer tool only. They are not BASIC# language syntax.

## Pass gates

- no Ruby warnings;
- no test failures, errors, or skips;
- source and saved DKIR final worlds match;
- fresh runtimes begin fresh;
- wrong and unknown Things remain clearly explained;
- repeated runs remain deterministic;
- no hidden state leakage.

## Result

The final observed result is recorded in:

```text
docs/validation/BASIC_SHARP_VALIDATION_v0_1_13.md
```
