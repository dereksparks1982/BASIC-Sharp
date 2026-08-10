# BASIC# Master Thread Handoff

## Current state

- **Accepted base for v0.1.72 candidate:** v0.1.71 / `c727fff42aad4fb53e753e85f011ad72c393de18`
- **Accepted tag:** `v0.1.71`
- **Branch:** `main`
- **Candidate:** v0.1.72 Self-Hosting Milestone 2 Proposal and Roadmap Truth Repair
- **Canonical Company Bible:** `docs/company_bible/BASIC_SHARP_COMPANY_BIBLE.md`
- **Canonical roadmap:** `docs/roadmap/BASIC_SHARP_ROADMAP.md`

## v0.1.72 purpose

v0.1.72 does four jobs without changing runtime behaviour:

1. Repair the stale active roadmap and master handoff so they no longer describe v0.1.63/v0.1.66 as the current lane.
2. Record the Self-Hosting Milestone 2 proposal as the next self-hosting planning gate, while making clear that Milestone 2 is not implemented yet.
3. Record Derek's release closeout workflow in the canonical Company Bible: apply ZIP, full native validation, accepted snapshot, local Git commit/tag, GitHub closeout, then next build.
4. Preserve the v0.1.71 no-locale CLI capture repair and the v0.1.70 whole-language gauntlet proof.

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
- v0.1.72 does not remove the compatibility bridge.
- v0.1.72 must not delete unrelated DKLab workspace contents.

## Release closeout truth

Every accepted build closes in this order:

1. Apply the changed-files ZIP with the exact terminal command supplied with the download.
2. Run full installer/native validation, including the complete test suite and Trial by Fire lane required by the build. Preserve the terminal progress format: `PHASE START`, visible Minitest dot progress during full suites, run/assertion counts, `PHASE PASS`, and one unmistakable `FINAL PASS`.
3. Create the accepted snapshot after final PASS.
4. Perform local Git commit/tag verification only after the accepted snapshot.
5. Perform GitHub remote closeout only after local acceptance.
6. Update GitHub description only after the pushed commit/tag are verified.
7. Move to the next build only after the current build is fully closed.

Do not guess at GitHub SSH keys, prompt Derek through HTTPS username/password pushes, or provide giant token blocks that destabilize the terminal. Follow the proven project transcript and use small, evidence-based commands.

## Guardrails

This build does not change parser meaning, runtime meaning, bytecode format, BSBC naming, language syntax, Profile 8 status, movement/input behaviour, object interaction, BCS implementation, servers, accounts, pricing, payments, licensing, network calls, Project Oracle, or Demon Killer.

Ruby remains the bootstrap compiler, production parser authority, production resolver authority, runtime authority, and reference referee. BASIC# is not fully self-hosted.

## Next action after v0.1.72 acceptance

If final PASS appears, create the accepted snapshot first, then local Git commit/tag, then GitHub closeout. After v0.1.72 is fully closed, Derek decides whether v0.1.73 implements a bounded Self-Hosting Milestone 2 slice or pivots to object interaction.

## Canonical self-hosting specification runway

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
docs/self_hosting/BASIC_SHARP_SELF_HOSTING_MILESTONE_2_PROPOSAL_v0_1_72.md
```
