# BASIC# Master Thread Handoff

## Current state

- **Accepted baseline:** v0.1.49
- **Accepted commit:** `936c01340c518af655fce21f11d9b99f1863f3f1`
- **Candidate:** v0.1.50 Small Compiler Subset Emits BSharp IR Under Ruby Referee
- **Package:** `BASIC_Sharp_Ruby_Bootstrap_Compiler_v0_1_50_SMALL_COMPILER_SUBSET_IR_EMITTER_CHANGED_FILES_ONLY.zip`

Read `docs/company_bible/BASIC_SHARP_COMPANY_BIBLE.md` completely before any proposal or build. The active self-hosting foundation is `spec/self_hosting/BASIC_SHARP_SELF_HOSTING_SUBSET_v1.json`. The active tokenizer/reader contract is `spec/self_hosting/BASIC_SHARP_TOKENIZER_READER_CONTRACT_v1.json`. The active small compiler subset parser contract is `spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_PARSER_v1.json`. The active small compiler subset IR emitter contract is `spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_IR_EMITTER_v1.json`.

## v0.1.50 candidate work

- Adds `compiler/small_compiler_subset_ir_emitter.rb`.
- Adds `tests/test_small_compiler_subset_ir_emitter.rb`.
- Adds `tools/small_compiler_subset_ir_emitter.rb`.
- Adds `spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_IR_EMITTER_v1.json`.
- Adds `docs/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_IR_EMITTER_v0_1_50.md`.
- Advances live version truth to `0.1.50`.
- Preserves Ruby as production parser, resolver, compiler path, and referee.

## Exclusions

No Profile 8, new creator syntax, production parser migration, runtime behavior change, BSharp Bytecode instruction change, Save/ASK behavior change, input-device behavior change, web export, browser work, engine bridge, OpenAI outreach, or Ruby retirement.

## Required owner validation

The installer requires exact accepted v0.1.49 commit `936c01340c518af655fce21f11d9b99f1863f3f1`, tag `v0.1.49`, branch `main`, clean tree, base hashes, payload hashes, and exact manifest scope. Any post-mutation failure restores every replaced v0.1.49 file and removes every v0.1.50 path.

After the installer prints native PASS, commit all manifest-listed changes and tag `v0.1.50`.
