# BASIC# Changelog v0.0.22

## Added

- BSharp Save `.bsave.json` world-state files.
- `--save-world` and `--load-world` CLI options.
- Normalized source/BSIR program fingerprints.
- Deterministic settled-world serialization.
- Direct restore without START replay.
- Atomic save writing and candidate-first loading.
- Plain-language save corruption, mismatch, and misuse diagnostics.
- World-save sample, tests, stress lane, and contracts.

## Preserved

All accepted v0.0.21 language syntax, BSharp IR meaning, event order, IF behavior, Kind inheritance, selection, values, and retired-DKIR behavior.

## Excluded

No new official word, pending-event save, automatic save, slots, migration, ASK, arithmetic, bytecode, VM, GUI, engine bridge, or self-hosting work.
