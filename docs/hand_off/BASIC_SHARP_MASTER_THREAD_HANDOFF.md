# BASIC# Master Thread Handoff

## Current candidate

- **Accepted base:** v0.1.46 Plain-English Movement and Input Contract
- **Accepted commit:** `b4d8ea2c5274e63cab3de6e6fcf003e2aef25a35`
- **Accepted tag:** `v0.1.46`
- **Accepted branch:** `main`
- **Accepted native validation:** Derek reported clean v0.1.46 commit, tag, author, committer, and final snapshot. The v0.1.46 installer had already reported complete native validation PASS, including Trial-by-Fire PASS.
- **Accepted final snapshot:** `BASIC_SHARP_v0_1_46_ACCEPTED_FULL_PROJECT_FINAL_CLEAN_AUTHOR_2026-08-07_21-31-15.tar.gz`
- **Accepted final snapshot SHA-256:** `1be06999d74855f8ce7c423888498766f9f1570f94068b3b0456f98940ae1beb`
- **Candidate:** v0.1.47 Tokenizer/Reader Contract and Universal Standard Doctrine
- **Project path:** `/home/dereksparks1982/DKLab/Projects/BASIC#`
- **Package:** `BASIC_Sharp_Ruby_Bootstrap_Compiler_v0_1_47_TOKENIZER_READER_CONTRACT_CHANGED_FILES_ONLY.zip`
- **Language scope:** Profiles 1-7 only; no new creator syntax, bytecode profile, Save format, engine bridge, web export, browser work, OpenAI outreach, licensing work, or Ruby replacement

## Canonical authority

Read `docs/company_bible/BASIC_SHARP_COMPANY_BIBLE.md` completely before any proposal or build. The active self-hosting foundation is `spec/self_hosting/BASIC_SHARP_SELF_HOSTING_SUBSET_v1.json`. The active tokenizer/reader contract is `spec/self_hosting/BASIC_SHARP_TOKENIZER_READER_CONTRACT_v1.json`. The active input-device contract is `spec/input/BASIC_SHARP_INPUT_DEVICE_MAPPING_v1.json`.

## v0.1.47 candidate work

- Adds `spec/self_hosting/BASIC_SHARP_TOKENIZER_READER_CONTRACT_v1.json`.
- Adds `docs/self_hosting/BASIC_SHARP_TOKENIZER_READER_CONTRACT_v0_1_47.md`.
- Adds `tools/tokenizer_reader_contract.rb`.
- Adds `tests/test_tokenizer_reader_contract.rb`.
- Defines deterministic reader records: line number, raw line, and trimmed text.
- Locks current comment behavior and current Head words for future self-hosting reader work.
- Defines future token-record shape without replacing the Ruby bootstrap reader.
- Adds `docs/strategy/BASIC_SHARP_UNIVERSAL_STANDARD_AND_AI_TOOLING_DOCTRINE_v0_1_47.md`.
- Records the web compatibility-first rule: BASIC# exports to current standards before any BASIC#/BSharp-native browser is considered.
- Records the AI-tooling and sponsor posture: proof and validated demos before outreach or claims.
- Updates the self-hosting foundation, Company Bible, README, roadmap, runtime contract, validation, changelog, patch notes, session log, changed-files record, and master handoff.
- Advances live version truth to `0.1.47`.

## Explicit exclusions

No Profile 8, new creator syntax, loops, functions, reusable words, collections, interpolation, multiline text, runtime behavior change, BSharp IR change, BSharp Bytecode change, Save format change, ASK behavior change, input-device behavior change, controller remapping UI, platform-specific driver layer, haptics, camera controls, graphics, engine bridge, web export, browser work, licensing, monetization, funding claim, OpenAI outreach, Project Oracle, BASIC# Semantic Oracle implementation, or Ruby replacement.

## Validation status

Candidate validation was run in the build workspace with Ruby 3.3.8.

Expected owner-side native validation is the installer validation from exact accepted v0.1.46 commit `b4d8ea2c5274e63cab3de6e6fcf003e2aef25a35` and tag `v0.1.46`.

The v0.1.47 version-bearing fixture hashes are recorded in `docs/validation/BASIC_SHARP_VALIDATION_v0_1_47.md` after candidate validation.

## Package scope and rollback

The installer requires exact accepted v0.1.46 commit `b4d8ea2c5274e63cab3de6e6fcf003e2aef25a35`, tag `v0.1.46`, branch `main`, clean tree, base hashes, payload hashes, and exact manifest scope. Any post-mutation failure restores every replaced v0.1.46 file and removes every v0.1.47 path.

## Owner installation sequence

1. Download the exact changed-files-only ZIP into `~/Downloads`.
2. Run the one-command installer supplied with delivery.
3. Do not commit if any phase fails; rollback is automatic.
4. After the installer prints native PASS, commit all manifest-listed changes and tag `v0.1.47`.
5. Create the accepted full-project snapshot and record its SHA-256 before beginning another build.

## Next action

Run native owner installation and validation. v0.1.47 is not accepted until Derek's machine reports every sealed gate as PASS and Derek commits/tags the result.

## Accepted and failed recent history

- v0.1.31 preferred BSharp VM runtime and shadow parity, `e7126c1`.
- v0.1.32 creator-facing text values and Profile 2, `3566b02`.
- v0.1.33 and v0.1.34 rejected; rollback restored v0.1.32.
- v0.1.35 complete Profile 3 re-carry and runtime-transition repair, `8c5f096`.
- v0.1.36 plain-English platform movement and Profile 4, `ef43056`.
- v0.1.37 number changes, comparisons, and Profile 5, `8eb1fbe`.
- v0.1.38 compound IF conditions and Profile 6, `3a92d4e`.
- v0.1.39 OTHERWISE branches and Profile 7, `066e715`.
- v0.1.40 failed at stale text Save fixture and rolled back cleanly.
- v0.1.41 passed the text repair, failed at stale number-change result, exposed two more downstream stale fixtures, and rolled back cleanly.
- v0.1.42 complete Trial-by-Fire repair accepted, `1d79a6221a388ffd6e372d6bfe21d9df1cb38c2c`.
- v0.1.43 rejected before mutation due to malformed installer NUL-byte package bug; version number not reused.
- v0.1.44 self-hosting foundation and rejected package repair accepted, `b630b03`.
- v0.1.45 rejected by native test timing/isolation failure in the Xbox jump assertion; rollback restored v0.1.44.
- v0.1.46 plain-English movement and input contract accepted by Derek at `b4d8ea2c5274e63cab3de6e6fcf003e2aef25a35` with clean final snapshot SHA-256 `1be06999d74855f8ce7c423888498766f9f1570f94068b3b0456f98940ae1beb`.
