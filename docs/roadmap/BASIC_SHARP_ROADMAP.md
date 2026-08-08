# BASIC# Bootstrap Roadmap

## Current position

```text
BASIC# source
-> Ruby bootstrap parser and resolver
-> BSharp IR
-> Stable Meaning Profiles 1-7
-> BSharp Bytecode Profiles 1-7
-> BSharp VM preferred runtime
-> Trial by Fire validation and rollback discipline
-> BSharp Compiler Subset 0 under Ruby referee control
-> Self-Hosting Milestone 1 accepted in v0.1.61
-> Elderedd identity migration and DKLab compatibility bridge accepted in v0.1.62
-> v0.1.63 candidate: UTF-8 source hardening, Elderedd path proof, and BSBC execution parity
```

Ruby remains the bootstrap compiler, production parser authority, production resolver authority, runtime authority, and reference referee. BASIC# is not fully self-hosted. Ruby is retired only after each boundary is separately proven by accepted validation.

Canonical Company Bible: `docs/company_bible/BASIC_SHARP_COMPANY_BIBLE.md`.
Self-hosting contract: `spec/self_hosting/BASIC_SHARP_SELF_HOSTING_SUBSET_v1.json`.

## Accepted self-hosting runway

```text
v0.1.47 Tokenizer/Reader Contract
v0.1.48 Tokenizer/Reader Implementation
v0.1.49 Small Compiler Subset Parser
v0.1.50 Small Compiler Subset BSharp IR Emitter
v0.1.51 Small Compiler Subset IR Golden Parity Harness
v0.1.52 Small Compiler Subset Plain-English Error Contract
v0.1.53 Small Compiler Subset Scene/Block Expansion
v0.1.54 Small Compiler Subset Symbol Table Contract
v0.1.55 Small Compiler Subset BSBC Emitter
v0.1.56 Small Compiler Subset BSBC Golden Parity Harness
v0.1.57 Self-Hosting Fixture Corpus
v0.1.58 Small Compiler Subset Runtime Smoke
v0.1.59 Bootstrap Boundary Audit
v0.1.60 Self-Hosting Milestone 1 candidate rejected and rolled back
v0.1.61 Self-Hosting Milestone 1 Repair accepted
v0.1.62 Elderedd Identity and DKLab Compatibility accepted
```

The v0.1.60 rejected candidate remains permanent evidence. It passed the ordinary suite but failed the sealed README/error-contract reference gate, then restored exact v0.1.59. The rejection audit is `docs/audit/BASIC_SHARP_v0_1_60_REJECTED_BUILD_AUDIT.md`.

## Emergency Roadmap: DKLab Retirement and Elderedd Migration

Priority: Emergency. Status: active beginning in v0.1.62 and continuing in v0.1.63.

Goal: retire DKLab / DK LAB as the active BASIC# identity and migrate current work to Elderedd without reckless breakage.

Current identity direction:

- Elderedd Softworks LLC: parent company / umbrella identity.
- Elderedd Laboratory: research and build laboratory.
- ELDL: internal shorthand only.
- BCS: BSharp Creator Services.
- BASIC#: language name.
- BSharp: tool-safe technical name.

DKLab retirement rule: DKLab is retired as active identity. DKLab may remain only in approved historical, migration, compatibility bridge, rollback, or archival contexts.

Retirement ladder:

1. Establish Elderedd as canonical identity.
2. Mark DKLab as retired history and compatibility-only.
3. Update active docs, tools, contracts, and validation gates.
4. Move current instructions toward `~/Elderedd/Projects/BASIC#`.
5. Archive or quarantine old DKLab references where history requires them.
6. Prove future builds work from the Elderedd path.
7. Remove the BASIC# DKLab compatibility bridge only after validation confirms nothing active depends on it.

Hard rules:

- Never make the BASIC# GitHub repository public unless Derek explicitly commands that exact visibility change.
- Do not delete unrelated projects while migrating BASIC#.
- Do not remove the DKLab compatibility bridge until a later accepted build proves it is safe.
- Every accepted build includes GitHub description update after push verification.


Canonical self-hosting spec runway:

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

## v0.1.63 Candidate: UTF-8 Source Hardening, Elderedd Path Proof, and BSBC Execution Parity

Status: current candidate.

This build has three focused purposes:

1. Harden UTF-8 source, BSharp IR, BSharp Save, and text fixture reading so minimal/no-locale Ruby environments do not crash on creator text.
2. Continue the Emergency DKLab Retirement and Elderedd Migration by proving the new Elderedd path direction while preserving the DKLab compatibility bridge.
3. Add the next self-hosting bridge: small compiler subset BSBC execution parity. Approved subset fixtures travel from BASIC# source to BSharp IR to BSBC bytes, execute inside the BSharp Virtual Machine, and match the Ruby referee runtime for event results, final snapshots, and BSharp Save documents.

Guardrails:

- Ruby remains the bootstrap compiler and reference referee.
- BASIC# is not fully self-hosted.
- Profile 8 is not added.
- Bytecode and BSBC are not renamed.
- Production meaning is not changed.
- File reading is hardened to explicit UTF-8 where source/JSON/text artifacts are read.
- The DKLab compatibility bridge remains active retirement support.
- BCS is named only; no accounts, servers, networking, payments, or hosting are implemented.

Primary references:

- `spec/governance/BASIC_SHARP_UTF8_SOURCE_READING_CONTRACT_v1.json`
- `tools/utf8_source_reading_contract.rb`
- `spec/governance/BASIC_SHARP_ELDEREDD_PATH_BRIDGE_CONTRACT_v1.json`
- `tools/elderedd_path_bridge_contract.rb`
- `spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_BSBC_EXECUTION_PARITY_v1.json`
- `tools/small_compiler_subset_bsbc_execution_parity.rb`

## After v0.1.63

If v0.1.63 is accepted, the next likely work is one of the following, chosen after validation evidence rather than momentum:

1. Continue Elderedd path migration by proving the project validates from `~/Elderedd/Projects/BASIC#` while preserving the DKLab bridge.
2. Expand small compiler subset BSBC execution parity only after the current parity gate remains stable.
3. Prepare a later bridge-removal build only after no active BASIC# workflow depends on `~/DKLab/Projects/BASIC#`.

Do not remove the DKLab compatibility bridge immediately after v0.1.63. Do not begin BCS implementation, accounts, hosting, pricing, network calls, or server work until separately approved.

## Future web/app/company lane

BASIC# / BSharp aims to become a universal creator-facing standard for websites, apps, games, tools, automation, and business systems.

The staged web strategy is compatibility first:

```text
BASIC# source
-> HTML for structure
-> CSS for style
-> JavaScript for browser behavior
-> WebAssembly or native targets later
-> BASIC#/BSharp-native browser only much later, after proven demand
```

BCS, BSharp Creator Services, is the future hosted service layer for BASIC#: creator accounts, project sync, updates, documentation, compiler access, publishing tools, future game/world hosting, and eventual Elderedd-controlled server infrastructure. v0.1.63 does not implement BCS.

Private/proprietary distribution remains under consideration, but licensing and monetization are deferred. Future Creator pricing must include a reasonable monthly option, annual billing may only be an optional discount, and an eligible paid local version must remain usable permanently under eventual qualifying terms.

## Long-range future concepts

- BSharp web/app export contracts.
- BSharp native document app.
- Game-engine bridge.
- Independent BASIC# Semantic Oracle.
- Staged BASIC# editor: Notepad -> Notepad++ -> Sublime-class.
- Complete BASIC# IDE.
- BASIC#/BSharp-native browser only after web export and demand are real.
