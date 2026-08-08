# BASIC# Master Thread Handoff

## Current state

- **Accepted base:** v0.1.59 / `4d58c74aca68f826c0bdd0ecf50bec377d7063fe`
- **Accepted tag:** `v0.1.59`
- **Branch:** `main`
- **Candidate:** v0.1.61 Self-Hosting Milestone 1 Repair
- **Package:** `BASIC_Sharp_Ruby_Bootstrap_Compiler_v0_1_61_SELF_HOSTING_MILESTONE_1_REPAIR_CHANGED_FILES_ONLY.zip`
- **Rollback:** exact v0.1.59
- **Canonical Company Bible:** `docs/company_bible/BASIC_SHARP_COMPANY_BIBLE.md`

## Why v0.1.61 exists

v0.1.60 was rejected on 2026-08-08. Its installer passed the complete 526-run / 8787-assertion suite and the self-hosting lanes through IR parity, then `tools/small_compiler_subset_error_contract.rb` stopped because `README.md` did not reference `spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_ERROR_CONTRACT_v1.json`. The installer restored exact v0.1.59, and Derek verified `main`, tag `v0.1.59`, commit `4d58c74aca68f826c0bdd0ecf50bec377d7063fe`, clean tree, no diff, and no untracked files.

Permanent evidence: `docs/audit/BASIC_SHARP_v0_1_60_REJECTED_BUILD_AUDIT.md`.

## v0.1.61 candidate work

- Re-carries Self-Hosting Milestone 1 directly from accepted v0.1.59, never from v0.1.60 as a baseline.
- Adds `compiler/self_hosting_milestone_1.rb`, its spec, tool, tests, and documentation.
- Adds the README Current Release Truth Gate and its spec, tool, tests, and documentation.
- Adds the exact Small Compiler Subset Error Contract spec reference to the root README.
- Advances active compiler, tests, specs, generated fixtures, docs, validation inventory, and release truth to `0.1.61`.
- Preserves the v0.1.60 rejection record.
- Requires the exact final sealed installer to pass against a disposable clean copy of accepted v0.1.59 before Derek receives the package.

## Guardrails

Ruby remains the bootstrap compiler, production parser authority, production resolver authority, and referee. This build does not claim full self-hosting, retire Ruby, add Profile 8, rename bytecode or BSBC, change production runtime behaviour, add web/browser/editor work, or add an engine bridge.

## Self-hosting runway now present

1. Tokenizer/Reader Contract and implementation.
2. Small compiler subset parser.
3. BSharp IR emitter.
4. BSharp IR golden parity harness.
5. Plain-English small compiler subset error contract.
6. Scene/block expansion.
7. Symbol table contract.
8. BSBC emitter.
9. BSBC golden parity harness.
10. Self-hosting fixture corpus.
11. Small compiler subset runtime smoke.
12. Bootstrap Boundary Audit.
13. README Current Release Truth Gate.
14. Self-Hosting Milestone 1 gate.

Canonical self-hosting contract: `spec/self_hosting/BASIC_SHARP_SELF_HOSTING_SUBSET_v1.json`.

## Required carried self-hosting references

- `spec/self_hosting/BASIC_SHARP_TOKENIZER_READER_CONTRACT_v1.json`
- `spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_PARSER_v1.json`
- `spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_IR_EMITTER_v1.json`
- `spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_IR_PARITY_HARNESS_v1.json`
- `spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_ERROR_CONTRACT_v1.json`
- `spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_SCENE_BLOCK_EXPANSION_v1.json`
- `spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_SYMBOL_TABLE_CONTRACT_v1.json`
- `spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_BSBC_EMITTER_v1.json`
- `spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_BSBC_PARITY_HARNESS_v1.json`
- `spec/self_hosting/BASIC_SHARP_SELF_HOSTING_FIXTURE_CORPUS_v1.json`
- `spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_RUNTIME_SMOKE_v1.json`
- `spec/self_hosting/BASIC_SHARP_BOOTSTRAP_BOUNDARY_AUDIT_v1.json`
- `spec/self_hosting/BASIC_SHARP_README_CURRENT_RELEASE_TRUTH_v1.json`
- `spec/self_hosting/BASIC_SHARP_SELF_HOSTING_MILESTONE_1_v1.json`

## Material build history

- v0.1.43: rejected malformed self-hosting package; installer NUL-byte bug; no mutation.
- v0.1.44: accepted Self-Hosting Foundation and rejected-package repair record.
- v0.1.45: rejected movement/input candidate; native timing assertion failed and rollback restored v0.1.44.
- v0.1.46: accepted Plain-English Movement and Input Contract.
- v0.1.47: accepted Tokenizer/Reader Contract.
- v0.1.48: accepted tokenizer/reader implementation under Ruby referee.
- v0.1.49: accepted small compiler subset parser.
- v0.1.50: accepted BSharp IR emitter lane.
- v0.1.51: accepted IR golden parity harness.
- v0.1.52: accepted plain-English small compiler subset error contract.
- v0.1.53: accepted scene/block expansion.
- v0.1.54: accepted symbol table contract and ByteTide naming decision.
- v0.1.55: accepted BSBC emitter lane.
- v0.1.56: accepted BSBC golden parity harness.
- v0.1.57: accepted self-hosting fixture corpus.
- v0.1.58: accepted small compiler subset runtime smoke.
- v0.1.59: accepted Bootstrap Boundary Audit; current rollback baseline.
- v0.1.60: rejected README/error-contract integration miss; exact rollback to v0.1.59 verified.
- v0.1.61: current repaired Self-Hosting Milestone 1 candidate.

## Validation and acceptance rule

The final package must verify exact v0.1.59 commit/tag/branch/clean-tree state, base hashes, payload hashes, manifest scope, Ruby syntax, JSON, sealed validation inventory, complete suite floor, every required validation tool, compatibility artifacts, and exact Git scope. A post-mutation failure must restore exact v0.1.59 and remove every candidate-added path.

Only after the exact sealed installer prints final PASS on Derek's machine may v0.1.61 be committed, tagged, archived as accepted, and pushed.

## Next action

Run the exact v0.1.61 changed-files-only package on Derek's clean v0.1.59 repository. If final PASS appears, commit/tag v0.1.61 and create the accepted snapshot/patch records. If any gate fails, v0.1.61 is rejected and the installer must leave exact v0.1.59 restored.
