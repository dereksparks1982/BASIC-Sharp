# BASIC# Patch Notes v0.1.53

v0.1.53 adds a plain-English error contract for invalid small compiler subset examples while Ruby remains the referee.

## Included

- `compiler/small_compiler_subset_error_contract.rb`
- `spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_ERROR_CONTRACT_v1.json`
- `tools/small_compiler_subset_error_contract.rb`
- `tests/test_small_compiler_subset_error_contract.rb`
- `docs/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_ERROR_CONTRACT_v0_1_52.md`
- v0.1.53 build handshake, validation, changelog, session log, runtime contract, and changed-files record

## Not included

No production parser replacement, no self-hosting claim, no Profile 8, no syntax changes, no runtime changes, no bytecode changes, no web export, no browser work, and no Ruby retirement.

## Repair note

The first v0.1.53 candidate failed at `tools/text_value_stress.rb` because the versioned text-value Save fixture hash was stale. This repaired package carries the corrected fixture hash and adds the requested Five Point Paradigm plus Documentation Map cleanup.
