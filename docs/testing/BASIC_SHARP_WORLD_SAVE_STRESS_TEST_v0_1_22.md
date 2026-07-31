# BASIC# World-Save Stress Test v0.1.22

## Scale

```text
Direct guards: 384
Inherited captains: 128
Things selected by every guard: 512
Saved Things: 516
Replay events after restore: 100
```

## Required proofs

- Source and saved-BSIR fingerprint parity.
- Byte-identical deterministic saves.
- Source and saved-BSIR world parity.
- Direct and inherited Thing preservation.
- Definition-order preservation.
- State, value, relationship, and IF-active preservation.
- Complete event-chain settlement before saving.
- START and startup events do not rerun.
- Restored source and saved-BSIR parity.
- Deterministic replay after restore.
- Separate runtime isolation.
- No pending events in the save document.

Timing is observational only.
