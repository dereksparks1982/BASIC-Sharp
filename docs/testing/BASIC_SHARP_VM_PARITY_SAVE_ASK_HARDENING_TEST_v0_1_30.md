# BASIC# v0.1.30 VM Parity, Save, ASK, and Hardening Test

## Automated suite

```text
292 runs
7,262 assertions
0 failures
0 errors
0 skips
```

## New focused coverage

- six sample source/BSIR/BSBC event-sequence comparisons;
- VM ASK answer parity and non-mutation;
- VM save-document parity with the reference runtime;
- restore without START replay;
- 25-cycle save/restore/replay unit test;
- failed-restore atomicity;
- 64-world isolation unit test;
- deterministic save bytes;
- BSBC CLI run/ASK/save/restore;
- deterministic BSBC ASK JSON.

## Default stress lane

```text
10,000 events per execution path
100 save/restore replay cycles
128 independent VM worlds
256 ASK questions
```

The stress lane also verifies malformed-save recovery, IF-loop protection, the 1,024-event guard, loader immutability, and repeated deterministic replay.
