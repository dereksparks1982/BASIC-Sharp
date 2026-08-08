# BASIC# Master Thread Handoff

## Current state

- **Accepted base for v0.1.63 candidate:** v0.1.62 / `e6b777669c48c6c516c5b7e875745407ee75129c`
- **Accepted tag:** `v0.1.62`
- **Branch:** `main`
- **Candidate:** v0.1.63 UTF-8 Source Hardening, Elderedd Path Proof, and Small Compiler Subset BSBC Execution Parity
- **Canonical Company Bible:** `docs/company_bible/BASIC_SHARP_COMPANY_BIBLE.md`

## v0.1.63 purpose

v0.1.63 merges three approved directions without removing the bridge too early:

1. Harden UTF-8 source, BSharp IR, BSharp Save, and text fixture reading so minimal/no-locale Ruby environments do not crash on creator text.
2. Prove the Elderedd path direction while keeping `~/DKLab/Projects/BASIC#` as the retired compatibility path.
3. Add small compiler subset BSBC execution parity under Ruby referee control.

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
- v0.1.63 does not remove the compatibility bridge.
- v0.1.63 must not delete unrelated DKLab workspace contents.

## Canonical self-hosting runway references

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
- UTF-8 source reading contract: `spec/governance/BASIC_SHARP_UTF8_SOURCE_READING_CONTRACT_v1.json`.
- Small compiler subset BSBC execution parity: `spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_BSBC_EXECUTION_PARITY_v1.json`.
- Self-hosting fixture corpus: `spec/self_hosting/BASIC_SHARP_SELF_HOSTING_FIXTURE_CORPUS_v1.json`.
- Small compiler subset runtime smoke: `spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_RUNTIME_SMOKE_v1.json`.
- Bootstrap boundary audit: `spec/self_hosting/BASIC_SHARP_BOOTSTRAP_BOUNDARY_AUDIT_v1.json`.
- README current release truth: `spec/self_hosting/BASIC_SHARP_README_CURRENT_RELEASE_TRUTH_v1.json`.
- Self-Hosting Milestone 1: `spec/self_hosting/BASIC_SHARP_SELF_HOSTING_MILESTONE_1_v1.json`.

## Guardrails

This build does not change parser meaning, runtime meaning, bytecode format, BSBC naming, language syntax, Profile 8 status, movement/input behaviour, BCS implementation, servers, accounts, pricing, payments, licensing, network calls, Project Oracle, or Demon Killer. The only runtime-adjacent hardening is explicit UTF-8 file reading for source/JSON/text artifacts.

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

Run the exact v0.1.63 changed-files-only package on Derek's clean v0.1.62 repository. If final PASS appears, create the accepted snapshot, then verify local Git commit/tag, push to GitHub, update the GitHub description, and provide the final status summary.
