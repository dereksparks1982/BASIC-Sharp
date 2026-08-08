# BASIC# Small Compiler Subset BSBC Golden Parity Harness v0.1.56

v0.1.56 adds the BSBC Golden Parity Harness for the approved small compiler subset.

v0.1.55 proved that the subset can emit real BSBC bytecode under Ruby referee supervision. v0.1.56 locks that emission behind golden parity fixtures so future compiler work must keep the bytecode bytes, disassembly digest, meaning fingerprint, and bytecode loader summary stable.

The harness checks this path:

- BASIC# subset source.
- Small compiler subset IR emitter.
- Existing BSharp Bytecode emitter.
- Existing BSharp Bytecode loader.
- Golden parity record.

This is still a referee harness, not the production compiler path.

Reference: `spec/self_hosting/BASIC_SHARP_SELF_HOSTING_SUBSET_v1.json`.
Reference: `spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_BSBC_PARITY_HARNESS_v1.json`.

## Non-goals

- Not the production compiler path.
- No Profile 8.
- No bytecode or BSBC rename.
- No Ruby retirement.
- No self-hosting claim.

## Validation

The following gate must pass:

`ruby tools/small_compiler_subset_bsbc_parity_harness.rb`
