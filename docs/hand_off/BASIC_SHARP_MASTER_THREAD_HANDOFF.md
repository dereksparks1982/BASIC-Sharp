# BASIC# Master Thread Handoff

## Current state

- **Accepted base:** v0.1.62 / `f6d66a2abad805acb4061767732df394ff863765`
- **Accepted tag:** `v0.1.62`
- **Branch:** `main`
- **Candidate:** v0.1.62 Elderedd Identity Migration with DKLab Compatibility Layer
- **Canonical Company Bible:** `docs/company_bible/BASIC_SHARP_COMPANY_BIBLE.md`

## v0.1.62 purpose

v0.1.62 retires DKLab / DK LAB as the active BASIC# identity and establishes Elderedd terminology without removing the compatibility bridge too early.

Active identity:

- Elderedd Softworks LLC: parent company / umbrella identity.
- Elderedd Laboratory: research and build laboratory.
- ELDL: internal shorthand only.
- BCS: BSharp Creator Services.
- BASIC#: language name.
- BSharp: tool-safe technical name.

DKLab status: retired active identity. It may appear only as migration history, compatibility bridge, rollback support, or archived evidence. The project works toward removing the BASIC# DKLab bridge in later accepted builds after validation proves it is safe.


Canonical self-hosting runway references:

- Self-hosting subset contract: `spec/self_hosting/BASIC_SHARP_SELF_HOSTING_SUBSET_v1.json`.
- Tokenizer/reader contract: `spec/self_hosting/BASIC_SHARP_TOKENIZER_READER_CONTRACT_v1.json` with documentation at `docs/self_hosting/BASIC_SHARP_TOKENIZER_READER_CONTRACT_v0_1_47.md`.
- Small compiler subset parser: `spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_PARSER_v1.json`.
- Small compiler subset IR emitter: `spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_IR_EMITTER_v1.json`.
- Small compiler subset IR parity harness: `spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_IR_PARITY_HARNESS_v1.json`.
- Small compiler subset error contract: `spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_ERROR_CONTRACT_v1.json`.
- Small compiler subset scene/block expansion: `spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_SCENE_BLOCK_EXPANSION_v1.json`.
- Small compiler subset symbol table contract: `spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_SYMBOL_TABLE_CONTRACT_v1.json`.
- Small compiler subset BSBC emitter: `spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_BSBC_EMITTER_v1.json`.
- Small compiler subset BSBC parity harness: `spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_BSBC_PARITY_HARNESS_v1.json`.
- Self-hosting fixture corpus: `spec/self_hosting/BASIC_SHARP_SELF_HOSTING_FIXTURE_CORPUS_v1.json`.
- Small compiler subset runtime smoke: `spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_RUNTIME_SMOKE_v1.json`.
- Bootstrap boundary audit: `spec/self_hosting/BASIC_SHARP_BOOTSTRAP_BOUNDARY_AUDIT_v1.json`.
- README current release truth: `spec/self_hosting/BASIC_SHARP_README_CURRENT_RELEASE_TRUTH_v1.json`.
- Self-Hosting Milestone 1: `spec/self_hosting/BASIC_SHARP_SELF_HOSTING_MILESTONE_1_v1.json`.

## Guardrails

This is an identity, roadmap, compatibility, and governance build. It does not change parser behaviour, runtime behaviour, bytecode, BSBC, language syntax, self-hosting milestone scope, Profile 8 status, movement/input behaviour, BCS implementation, servers, accounts, pricing, payments, licensing, network calls, Project Oracle, or Demon Killer.

Ruby remains the bootstrap compiler, production parser authority, production resolver authority, runtime authority, and reference referee. BASIC# is not fully self-hosted.

## Build closeout order

Every accepted build now closes in this order:

1. Accepted snapshot
2. Local Git commit/tag verification
3. GitHub push and remote verification
4. GitHub description update
5. Final status summary

Never make the BASIC# GitHub repository public unless Derek explicitly commands that exact visibility change.

## Next action

Run the exact v0.1.62 changed-files-only package on Derek's clean v0.1.62 repository. If final PASS appears, create the accepted snapshot, then verify local Git commit/tag, push to GitHub, update the GitHub description, and provide the final status summary.
