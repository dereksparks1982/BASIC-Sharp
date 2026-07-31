# BASIC# Meaning Profile 2 and Bytecode Profile 2 Test v0.1.32

## Focused automated coverage

- `tests/test_text_values.rb`: parsing, exact preservation, diagnostics, BSIR, reference/VM execution, reactive IF, ASK, typed Save/restore, and shadow parity.
- `tests/test_meaning_profile_2.rb`: machine-readable contract, valid/invalid cases, deterministic expected documents, and Profile 1 selection.
- `tests/test_bytecode_profile_2.rb`: profile identity, deterministic fixtures, exact string roles, new instructions, malformed artifacts, profile crossing, schemas, and VM execution.

The focused Profile 2 files currently total 30 runs and 168 assertions with zero failures, errors, or skips in the build environment.

The wider WebAssembly-compatible regression totals 314 runs and 7,334 assertions with zero failures, errors, or skips. All 348 tests are discovered; the remaining 34 require native process spawning, atomic rename, or native directory behavior and are therefore mandatory installer gates.

## Stress coverage

`tools/text_value_stress.rb` verifies:

- 10,000 repeated text events through each runtime path;
- 25 independently reconstructed shadow-parity events;
- 100 Save/restore cycles;
- deterministic ASK across four questions;
- identical final Profile 2 world state.

## Required compatibility coverage

- Accepted Profile 1 source/BSIR fingerprints and committed BSBC/disassembly hashes.
- Existing parser, resolver, runtime, IF, follow-up-event, Save, ASK, bytecode, VM, transition, identity, CLI, and stress lanes.
- Role-aware malformed string cases and text/whole-number conflicts.
- Deterministic source/BSIR/BSBC/Save/ASK results.
- Exact approved 85-path and package manifest checks.

## Native-Ruby acceptance gate

The build environment's Ruby WebAssembly cannot run native `Open3`, fork/process CLI tests, or atomic rename cases and emits an extension-availability warning outside project control. Therefore the installer must rerun the complete suite and every validation lane with warnings enabled on Derek's native Ruby. Any warning, failure, error, skip, lower-than-accepted Profile 1 floor, or fixture drift rejects the installation and triggers rollback.
