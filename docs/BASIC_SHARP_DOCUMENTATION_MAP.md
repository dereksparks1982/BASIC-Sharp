# BASIC# Documentation Map

**Version:** v0.1.52  
**Status:** Canonical navigation guide  
**Purpose:** Give Derek, future assistants, contributors, and reviewers a front door into the BASIC# documentation stack.

BASIC# now has enough doctrine, build history, validation records, and technical contracts that the docs must be navigated like a library instead of a pile of scrolls. This file is the map.

## 1. Start Here

Read these first when entering a BASIC# thread or repo checkout.

- `README.md` - public-facing project entry and current high-level status.
- `docs/hand_off/BASIC_SHARP_MASTER_THREAD_HANDOFF.md` - current continuity record, accepted base, candidate build, and next-step handoff.
- `docs/BASIC_SHARP_DOCUMENTATION_MAP.md` - this map.

## 2. Doctrine and Authority

These records explain why the project exists and what decisions are not optional.

- `docs/company_bible/BASIC_SHARP_COMPANY_BIBLE.md` - sole canonical Company Bible and mandatory rule source.
- Five Point Paradigm section inside the Company Bible - five-point decision compass for BASIC#.
- Creator ownership rules inside the Company Bible - pricing, access, and anti-hostage product principles.

## 3. Roadmap

Use this to understand where the current work fits.

- `docs/roadmap/BASIC_SHARP_ROADMAP.md` - active roadmap, self-hosting bridge, and explicit not-yet items.

## 4. Self-Hosting Bridge

These records govern the current march toward BASIC# understanding a sealed subset of itself under Ruby referee control.

- `spec/self_hosting/BASIC_SHARP_SELF_HOSTING_SUBSET_v1.json`
- `spec/self_hosting/BASIC_SHARP_TOKENIZER_READER_CONTRACT_v1.json`
- `spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_PARSER_v1.json`
- `spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_IR_EMITTER_v1.json`
- `spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_IR_PARITY_HARNESS_v1.json`
- `spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_ERROR_CONTRACT_v1.json`
- `docs/self_hosting/` implementation notes for each self-hosting lane.

## 5. Runtime and Bytecode Contracts

These records protect the working engine while self-hosting grows.

- `docs/runtime_contract_v0_1_*.md`
- `spec/runtime_v*/`
- `spec/bytecode*/`
- bytecode tools under `tools/bytecode_*.rb`
- runtime transition and VM tools under `tools/runtime_transition.rb` and `tools/bytecode_virtual_machine.rb`

## 6. Validation and Proof Under Fire

These records prove builds instead of merely describing them.

- `spec/trial_by_fire/BASIC_SHARP_TRIAL_BY_FIRE_VALIDATION_INVENTORY_v1.json`
- `tools/trial_by_fire_inventory.rb`
- `tools/trial_by_fire_gauntlet.rb`
- `docs/validation/`
- stress tools under `tools/*_stress.rb`

## 7. Build History

These records explain what changed, why, and how the package was handed off.

- `docs/changelog/`
- `docs/patch_notes/`
- `docs/session_logs/`
- `docs/changed_files/`
- `BUILD_HANDSHAKE_v0_1_*.md`

## 8. Reading Order for a Build

Before proposing or building a BASIC# patch, read in this order:

1. `docs/company_bible/BASIC_SHARP_COMPANY_BIBLE.md`
2. `docs/hand_off/BASIC_SHARP_MASTER_THREAD_HANDOFF.md`
3. `docs/roadmap/BASIC_SHARP_ROADMAP.md`
4. This documentation map.
5. The exact specs, tools, tests, and docs touched by the proposed build.
6. The current Git state and accepted base.

## 9. What This Map Is Not

This map is not a replacement for the Company Bible, roadmap, specifications, validation inventory, or handoff. It is the front door that tells a reader which room to enter first.
