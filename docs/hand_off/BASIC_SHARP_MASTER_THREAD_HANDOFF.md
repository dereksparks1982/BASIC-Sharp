# BASIC# Master Thread Handoff

## Current state

- **Accepted base:** v0.1.50 / `8506fcec102c9ab0c7f8577a03414abb721d7a5a`
- **Candidate:** v0.1.51 Small Compiler Subset IR Golden Parity Harness
- **Package:** `BASIC_Sharp_Ruby_Bootstrap_Compiler_v0_1_51_IR_GOLDEN_PARITY_HARNESS_CHANGED_FILES_ONLY.zip`
- **Canonical Company Bible:** `docs/company_bible/BASIC_SHARP_COMPANY_BIBLE.md`

## v0.1.51 candidate work

- Adds `compiler/small_compiler_subset_ir_parity_harness.rb`.
- Adds `spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_IR_PARITY_HARNESS_v1.json`.
- Adds `tools/small_compiler_subset_ir_parity_harness.rb`.
- Adds `tests/test_small_compiler_subset_ir_parity_harness.rb`.
- Adds `docs/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_IR_PARITY_HARNESS_v0_1_51.md`.
- Advances live version truth to `0.1.51`.

## Guardrails

Ruby remains the production compiler, production parser, production resolver, and referee. The new parity harness is not the production compiler path. No Profile 8, syntax change, runtime change, bytecode change, web export, browser work, engine bridge, or Ruby retirement is included.

## Installer expectation

The installer requires exact accepted v0.1.50 commit `8506fcec102c9ab0c7f8577a03414abb721d7a5a`, tag `v0.1.50`, branch `main`, clean tree, base hashes, payload hashes, and exact manifest scope. Any post-mutation failure restores every replaced v0.1.50 file and removes every v0.1.51 path.

After the installer prints native PASS, commit all manifest-listed changes and tag `v0.1.51`.


Self-hosting umbrella spec: `spec/self_hosting/BASIC_SHARP_SELF_HOSTING_SUBSET_v1.json`.

Prior IR emitter spec: `spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_IR_EMITTER_v1.json`.

## Required self-hosting specs carried forward

- `spec/self_hosting/BASIC_SHARP_TOKENIZER_READER_CONTRACT_v1.json`
- `spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_PARSER_v1.json`
