# BASIC# Changelog v0.1.30

## Added

- BSharp Save write and restore through the BSharp VM.
- BSharp ASK inspection through the BSharp VM.
- `.bsbc` CLI support for run/load/save/ASK combinations.
- Source, saved BSIR, and BSBC three-way parity tests.
- Repeated save/restore/replay and VM isolation tests.
- Atomic malformed-save recovery tests.
- `tools/bytecode_vm_stress.rb` bounded soak and hardening lane.
- Machine-readable VM hardening fixture identity.

## Changed

- Advanced active version surfaces to v0.1.30.
- Extended the bytecode Profile 1 execution contract to record Save, ASK, parity, and hardening support.
- Extended BSharp Save fingerprint guidance to include matching `.bsbc` programs.
- Updated the canonical Company Bible, roadmap, README, and master handoff.

## Preserved

- Bytecode binary layout and all committed `.bsbc` hashes.
- BSharp Save and ASK format versions.
- Meaning Profile 1 behavior.
- The reference source/BSIR runtime.
