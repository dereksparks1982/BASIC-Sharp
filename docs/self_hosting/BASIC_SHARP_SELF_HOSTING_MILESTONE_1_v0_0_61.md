# BASIC# v0.0.63 Self-Hosting Milestone 1

v0.0.63 seals Self-Hosting Milestone 1 for BSharp Compiler Subset 0 under Ruby referee control.

## Meaning of the milestone

BASIC# can read, parse, validate, emit BSharp IR, emit BSBC, compare golden artifacts, and run selected runtime smoke checks for the sealed small compiler subset while Ruby remains the bootstrap compiler and referee.

## Not claimed

- BASIC# is not fully self-hosted.
- Ruby is not retired.
- The full BASIC# language does not compile itself.
- Profile 8 is not added.
- Production runtime behaviour is not changed.
- Bytecode and BSBC names are not renamed.

## Required gates

- README Current Release Truth Gate.
- Bootstrap Boundary Audit.
- Small compiler subset runtime smoke.
- Self-hosting fixture corpus.
- IR and BSBC golden parity harnesses.
- Full Trial by Fire.

Canonical self-hosting contract: `spec/self_hosting/BASIC_SHARP_SELF_HOSTING_SUBSET_v1.json`.
