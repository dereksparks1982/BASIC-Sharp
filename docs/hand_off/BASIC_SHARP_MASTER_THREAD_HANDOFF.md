# BASIC# Master Thread Handoff

## Current state

- **Accepted baseline:** v0.1.48
- **Accepted commit:** `c67c74251aaa58e4f2fcded1144ea5187eebfb25`
- **Candidate:** v0.1.49 Small Compiler Subset Parser Under Ruby Referee
- **Package:** `BASIC_Sharp_Ruby_Bootstrap_Compiler_v0_1_49_SMALL_COMPILER_SUBSET_PARSER_CHANGED_FILES_ONLY.zip`

Read `docs/company_bible/BASIC_SHARP_COMPANY_BIBLE.md` completely before any proposal or build. The active self-hosting foundation is `spec/self_hosting/BASIC_SHARP_SELF_HOSTING_SUBSET_v1.json`. The active tokenizer/reader contract is `spec/self_hosting/BASIC_SHARP_TOKENIZER_READER_CONTRACT_v1.json`. The active small compiler subset parser contract is `spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_PARSER_v1.json`.

## v0.1.49 candidate work

- Adds `compiler/small_compiler_subset_parser.rb`.
- Adds `tests/test_small_compiler_subset_parser.rb`.
- Adds `tools/small_compiler_subset_parser.rb`.
- Adds `docs/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_PARSER_v0_1_49.md`.
- Advances live version truth to `0.1.49`.
- Preserves Ruby as production parser authority.

## Exclusions

No Profile 8, new creator syntax, production parser migration, runtime behavior change, BSharp IR meaning change, BSharp Bytecode instruction change, Save/ASK behavior change, input-device behavior change, web export, browser work, engine bridge, OpenAI outreach, or Ruby retirement.

## Required owner validation

The installer requires exact accepted v0.1.48 commit `c67c74251aaa58e4f2fcded1144ea5187eebfb25`, tag `v0.1.48`, branch `main`, clean tree, base hashes, payload hashes, and exact manifest scope. Any post-mutation failure restores every replaced v0.1.48 file and removes every v0.1.49 path.

After the installer prints native PASS, commit all manifest-listed changes and tag `v0.1.49`.
