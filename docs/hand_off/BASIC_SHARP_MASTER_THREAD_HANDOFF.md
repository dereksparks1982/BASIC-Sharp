# BASIC# Master Thread Handoff

## Current state

- **Accepted base:** v0.1.51 / `2962fa19b3e452e529ac7166ad3e751bf621cde4`
- **Candidate:** v0.1.54 Small Compiler Subset Error Contract
- **Package:** `BASIC_Sharp_Ruby_Bootstrap_Compiler_v0_1_52_SMALL_COMPILER_SUBSET_ERROR_CONTRACT_CHANGED_FILES_ONLY.zip`
- **Canonical Company Bible:** `docs/company_bible/BASIC_SHARP_COMPANY_BIBLE.md`

## v0.1.54 candidate work

- Adds `compiler/small_compiler_subset_error_contract.rb`.
- Adds `spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_ERROR_CONTRACT_v1.json`.
- Adds `tools/small_compiler_subset_error_contract.rb`.
- Adds `tests/test_small_compiler_subset_error_contract.rb`.
- Adds `docs/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_ERROR_CONTRACT_v0_1_52.md`.
- Advances live version truth to `0.1.54`.

## Required carried references

- `spec/self_hosting/BASIC_SHARP_SELF_HOSTING_SUBSET_v1.json`
- `spec/self_hosting/BASIC_SHARP_TOKENIZER_READER_CONTRACT_v1.json`
- `spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_PARSER_v1.json`
- `spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_IR_EMITTER_v1.json`
- `spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_IR_PARITY_HARNESS_v1.json`
- `spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_ERROR_CONTRACT_v1.json`

## Guardrails

Ruby remains the production compiler, production parser, production resolver, and referee. The new error contract is not the production compiler path. No Profile 8, syntax change, runtime change, bytecode change, web export, browser work, engine bridge, or Ruby retirement is included.

## Installer expectation

The installer requires exact accepted v0.1.51 commit `2962fa19b3e452e529ac7166ad3e751bf621cde4`, tag `v0.1.51`, branch `main`, clean tree, base hashes, payload hashes, and exact manifest scope. Any post-mutation failure restores every replaced v0.1.51 file and removes every v0.1.54 path.

After the installer prints native PASS, commit all manifest-listed changes and tag `v0.1.54`.


## v0.1.54 repair scope

The first v0.1.54 candidate failed during `tools/text_value_stress.rb` with a Save fixture hash mismatch and restored exact v0.1.51. The repaired candidate carries the corrected v0.1.54 text-value Save fixture hash, keeps the small compiler subset error contract, and adds documentation cleanup requested by Derek.

Documentation cleanup included:

- Five Point Paradigm documentation in `docs/company_bible/BASIC_SHARP_COMPANY_BIBLE.md`.
- Documentation front door at `docs/BASIC_SHARP_DOCUMENTATION_MAP.md`.
- README and roadmap references to the documentation map.
- Corrected v0.1.51 naming for the IR golden parity harness lane.

The v0.1.54 repair remains under the same exclusions: no Profile 8, no new syntax, no runtime semantics change, no bytecode change, no web export, no browser work, no engine bridge, and no Ruby retirement.


## v0.1.54 Subset Scene/Block Expansion

Accepted base for this candidate: v0.1.52 / `ce42744a9021ed955b076ee42030054aa1423b92`.

The build adds `spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_SCENE_BLOCK_EXPANSION_v1.json`, `compiler/small_compiler_subset_scene_block_expansion.rb`, `tools/small_compiler_subset_scene_block_expansion.rb`, and `tests/test_small_compiler_subset_scene_block_expansion.rb`.

Ruby remains the production parser, resolver, compiler path, and referee. No Profile 8, new syntax, runtime change, bytecode change, web export, browser work, engine bridge, or Ruby retirement is included.


Symbol table contract spec: `spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_SYMBOL_TABLE_CONTRACT_v1.json`.


ByteTide decision record: the name was considered as a creator-facing metaphor for bytecode flow, then passed on for now. Official system terms remain bytecode and BSBC.

Reference: `docs/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_SYMBOL_TABLE_CONTRACT_v0_1_54.md`.
