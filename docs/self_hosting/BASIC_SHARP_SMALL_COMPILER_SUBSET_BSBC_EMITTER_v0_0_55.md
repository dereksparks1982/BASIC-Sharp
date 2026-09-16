# BASIC# Small Compiler Subset BSBC Emitter v0.0.63

v0.0.63 adds the first small compiler subset lane that emits real BSBC bytecode while Ruby remains the parser, resolver, compiler, runtime, and referee authority.

The lane is intentionally narrow:

- BASIC# subset source is read by the small compiler subset parser/IR path.
- BSharp IR is compared with the Ruby Parser plus SemanticResolver referee.
- The existing BSharp Bytecode emitter writes BSBC bytes from that IR.
- The existing BSharp Bytecode loader reads those bytes back and verifies the meaning fingerprint.

This is a bridge, not a takeover. It proves that the small compiler subset can reach the existing bytecode system under Ruby supervision.

Reference: `spec/self_hosting/BASIC_SHARP_SELF_HOSTING_SUBSET_v1.json`.
Reference: `spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_BSBC_EMITTER_v1.json`.

## Non-goals

- Not the production compiler path.
- No Profile 8.
- No bytecode or BSBC rename.
- No Ruby retirement.
- No self-hosting claim.

## Validation

The following gate must pass:

`ruby tools/small_compiler_subset_bsbc_emitter.rb`
