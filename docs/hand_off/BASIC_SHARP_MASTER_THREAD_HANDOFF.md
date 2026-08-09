# BASIC# Master Thread Handoff

## Current state

- **Accepted base for v0.1.64 candidate:** v0.1.63 / `a1ca9501f49f51b937bb6c736824dd96568a5f0b`
- **Accepted tag:** `v0.1.63`
- **Branch:** `main`
- **Candidate:** v0.1.64 Self-Hosting Execution Expansion and Release Gate Hardening
- **Canonical Company Bible:** `docs/company_bible/BASIC_SHARP_COMPANY_BIBLE.md`

## v0.1.64 purpose

v0.1.64 does two jobs without removing the bridge too early:

1. Expand small compiler subset BSBC execution parity from 7 sealed fixtures to 9 sealed fixtures, including repeated number-threshold execution and IF/OTHERWISE rearming over a longer event path.
2. Add release-hardening gates so stale deterministic hashes, sealed artifact byte counts, payload hashes, and changed-file scope are checked together before Derek receives a ZIP.

Active identity:

- Elderedd Softworks LLC: parent company / umbrella identity.
- Elderedd Laboratory: research and build laboratory.
- ELDL: internal shorthand only.
- BCS: BSharp Creator Services.
- BASIC#: language name.
- BSharp: tool-safe technical name.

DKLab status: retired active identity. It may appear only as migration history, compatibility bridge, rollback support, or archived evidence. The project works toward removing the BASIC# DKLab bridge in later accepted builds after validation proves it is safe.

## Path bridge truth

- Canonical future path: `~/Elderedd/Projects/BASIC#`.
- Legacy compatibility path: `~/DKLab/Projects/BASIC#`.
- v0.1.64 does not remove the compatibility bridge.
- v0.1.64 must not delete unrelated DKLab workspace contents.

## Release hardening truth

- `tools/deterministic_fixture_hash_sweep.rb` runs the complete deterministic fixture family together.
- `tools/release_package_preflight.rb` verifies manifest identity, package identity, installer identity, payload hashes, active Git scope, and validation inventory inclusion.
- A release package must not enter acceptance testing unless the final extracted payload is audited against the sealed records.

## Guardrails

This build does not change parser meaning, runtime meaning, bytecode format, BSBC naming, language syntax, Profile 8 status, movement/input behaviour, BCS implementation, servers, accounts, pricing, payments, licensing, network calls, Project Oracle, or Demon Killer.

Ruby remains the bootstrap compiler, production parser authority, production resolver authority, runtime authority, and reference referee. BASIC# is not fully self-hosted.

## Build closeout order

Every accepted build closes in this order:

1. Accepted snapshot
2. Local Git commit/tag verification
3. GitHub push and remote verification
4. GitHub description update
5. Final status summary

Never make the BASIC# GitHub repository public unless Derek explicitly commands that exact visibility change.

## Next action

Run the exact v0.1.64 changed-files-only package on Derek's clean v0.1.63 repository. If final PASS appears, create the accepted snapshot, then verify local Git commit/tag, push to GitHub, update the GitHub description, and provide the final status summary.

## Canonical self-hosting specification runway

```text
spec/self_hosting/BASIC_SHARP_SELF_HOSTING_SUBSET_v1.json
spec/self_hosting/BASIC_SHARP_TOKENIZER_READER_CONTRACT_v1.json
spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_PARSER_v1.json
spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_IR_EMITTER_v1.json
spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_IR_PARITY_HARNESS_v1.json
spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_ERROR_CONTRACT_v1.json
spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_SCENE_BLOCK_EXPANSION_v1.json
spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_SYMBOL_TABLE_CONTRACT_v1.json
spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_BSBC_EMITTER_v1.json
spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_BSBC_PARITY_HARNESS_v1.json
spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_BSBC_EXECUTION_PARITY_v1.json
spec/self_hosting/BASIC_SHARP_SELF_HOSTING_FIXTURE_CORPUS_v1.json
spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_RUNTIME_SMOKE_v1.json
spec/self_hosting/BASIC_SHARP_BOOTSTRAP_BOUNDARY_AUDIT_v1.json
spec/self_hosting/BASIC_SHARP_README_CURRENT_RELEASE_TRUTH_v1.json
spec/self_hosting/BASIC_SHARP_SELF_HOSTING_MILESTONE_1_v1.json
```
