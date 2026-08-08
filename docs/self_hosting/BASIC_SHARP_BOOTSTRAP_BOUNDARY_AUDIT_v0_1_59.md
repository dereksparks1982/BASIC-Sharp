# BASIC# Bootstrap Boundary Audit v0.1.63

Status: bootstrap boundary audit under Ruby referee.

This build audits the border before v0.1.63 Self-Hosting Milestone 1. It records where Ruby still owns source-of-truth authority, where the BASIC# small compiler subset is allowed to participate, where runtime smoke evidence is allowed, and where the production runtime boundary remains protected. It is governed by spec/self_hosting/BASIC_SHARP_SELF_HOSTING_SUBSET_v1.json as the canonical self-hosting subset contract.

## Boundary summary

- Ruby remains the bootstrap compiler and referee.
- BASIC# subset source fixtures are sealed inputs only.
- The subset reader, parser, IR emitter, BSBC emitter, parity harnesses, fixture corpus, and runtime smoke lane are evidence-producing bridges.
- Runtime smoke is not the production compiler path.
- Production runtime behaviour, Profile 1 through 7 behaviour, Save, ASK, input, movement, bytecode, and BSBC naming remain protected.

## Forbidden before v0.1.63 acceptance

- Claiming BASIC# is self-hosted.
- Replacing the Ruby bootstrap compiler.
- Adding Profile 8.
- Changing production runtime behaviour.
- Renaming bytecode or BSBC.
- Web export, browser work, or native document application work.
