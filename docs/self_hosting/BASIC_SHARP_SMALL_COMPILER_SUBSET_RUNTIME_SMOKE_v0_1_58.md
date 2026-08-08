# BASIC# Small Compiler Subset Runtime Smoke v0.1.59

Status: runtime smoke under Ruby referee.

This build proves selected small compiler subset fixtures can move through parser records, BSharp IR, BSBC bytecode, bytecode loader summary, and into the verifying runtime for smoke events, world snapshots, and save documents. It is linked to `spec/self_hosting/BASIC_SHARP_SELF_HOSTING_SUBSET_v1.json`. The runtime smoke lane is a sealed referee check. It is not the production compiler path and does not claim BASIC# is self-hosted.

## Scope

Allowed:

- Run selected fixture corpus programs through the small compiler subset pipeline.
- Load the resulting BSharp IR into the verifying runtime transition.
- Execute deterministic smoke events.
- Seal event result, world snapshot, and save document digests.

Forbidden:

- Replacing the Ruby bootstrap compiler.
- Claiming BASIC# is self-hosted.
- Adding Profile 8.
- Renaming bytecode or BSBC.
- Changing production runtime behaviour.
