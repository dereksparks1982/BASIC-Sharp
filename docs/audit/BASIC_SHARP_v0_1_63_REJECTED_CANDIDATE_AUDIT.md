# BASIC# v0.1.63 Rejected Candidate Audit

## Status

Rejected candidate record. Not an accepted baseline.

## Candidate 1 package

`BASIC_Sharp_Ruby_Bootstrap_Compiler_v0_1_63_UTF8_ELDEREDD_PATH_AND_BSBC_EXECUTION_PARITY_CHANGED_FILES_ONLY.zip`

## Candidate 1 failure

The installer passed base checks, payload checks, Ruby syntax, JSON parsing, sealed validation inventory, the complete test suite, and the required validation tools through `tools/runtime_transition.rb`.

It then failed at:

```text
PHASE START: tools/text_value_stress.rb
tools/text_value_stress.rb:27:in `assert!': Save fixture hash: FAIL (RuntimeError)
ERROR: tools/text_value_stress.rb failed.
```

## Candidate 1 root cause

The v0.1.63 candidate correctly changed the BASIC# runtime version and save output identity, but the sealed Text Value runtime fixture still carried the previous save document SHA-256 expectation.

## Candidate 2 package

`BASIC_Sharp_Ruby_Bootstrap_Compiler_v0_1_63_UTF8_ELDEREDD_PATH_AND_BSBC_EXECUTION_PARITY_REPAIRED_CHANGED_FILES_ONLY.zip`

## Candidate 2 failure

The installer passed the repaired Text Value gate and continued through later validation.

It then failed at:

```text
PHASE START: tools/number_change_stress.rb
tools/number_change_stress.rb:19:in `assert_stress': number-change expected fixture hash changed (RuntimeError)
ERROR: tools/number_change_stress.rb failed.
```

## Candidate 2 root cause

The first repair resealed only the first exposed Text Value fixture hash. The broader deterministic runtime fixture family had not been swept. Number Change, Compound IF, and OTHERWISE carry their own locked expected-file hashes and had to be verified and carried with their matching fixture specs.

## Candidate 3 package

`BASIC_Sharp_Ruby_Bootstrap_Compiler_v0_1_63_UTF8_ELDEREDD_PATH_AND_BSBC_EXECUTION_PARITY_FULL_REPAIR_CHANGED_FILES_ONLY.zip`

## Candidate 3 failure

The installer failed earlier than the stress tools, during the sealed validation inventory phase:

```text
PHASE START: sealed validation inventory
TRIAL BY FIRE: sealed artifact byte count changed for BUILD_HANDSHAKE_v0_1_63.md
ERROR: sealed validation inventory failed.
```

## Candidate 3 root cause

The full repair changed sealed documentation artifacts after the validation inventory had been generated. The package therefore carried payload bytes that did not match the locked inventory byte counts and SHA-256 values.

## Required forensic repair

Repair must sweep every sealed validation inventory record against the exact payload bytes that will be installed, not merely the first failed artifact. The repair must also update the package manifest payload hashes after the inventory and documentation bytes are final.

## Required repair

Keep the same target version, v0.1.63, because no v0.1.63 candidate was accepted, committed, or tagged.

Repair by sweeping and carrying the full deterministic runtime fixture family touched by the v0.1.63 output/version identity change:

- `spec/runtime_v2/BASIC_SHARP_TEXT_VALUE_RUNTIME_FIXTURES_v1.json`
- `spec/runtime_v5/BASIC_SHARP_NUMBER_CHANGE_RUNTIME_FIXTURES_v1.json`
- `spec/runtime_v6/BASIC_SHARP_COMPOUND_IF_RUNTIME_FIXTURES_v1.json`
- `spec/runtime_v7/BASIC_SHARP_OTHERWISE_RUNTIME_FIXTURES_v1.json`
- their matching sample expected documents where applicable

Then rerun the complete test suite, the exposed fixture gates, the sealed inventory, the package payload/manifest audit, and the native installer validation.

## Rule preserved

Rejected packages are evidence. These candidates remain recorded and must not be treated as baselines.
