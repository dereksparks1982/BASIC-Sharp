# BASIC# Roadmap

## Current accepted base

```text
v0.1.71: No-Locale CLI Capture Encoding Repair
```

v0.1.71 repaired the confirmed Ruby `Open3.capture3` test-harness encoding gap so CLI output captured under minimal/no-locale environments is force-tagged as UTF-8 before assertions compare it with UTF-8 creator text.

## Current candidate

```text
v0.1.72: Self-Hosting Milestone 2 Proposal and Roadmap Truth Repair
```

v0.1.72 repairs the active roadmap and master handoff so they no longer describe v0.1.63/v0.1.66 as the current lane. It records the Self-Hosting Milestone 2 proposal without implementing the milestone, without adding object interaction, and without claiming Ruby retirement.

## Canonical Company Bible

```text
docs/company_bible/BASIC_SHARP_COMPANY_BIBLE.md
```

This is the single canonical Company Bible reference for current BASIC# conduct, release, validation, rollback, packaging, GitHub closeout, and Elderedd migration rules.

## Release closeout order

Every BASIC# build must follow the proven release path:

1. Apply the changed-files ZIP with the exact terminal command supplied with the download.
2. Run installer validation including the complete test suite and full native validation lane required by the build.
3. Create the accepted snapshot after final installer PASS and before local Git closeout.
4. Commit and tag locally only after acceptance proof.
5. Complete GitHub remote closeout only after local acceptance.
6. Start the next build only after the current build is closed.

Do not substitute SSH-key guessing, GitHub password prompts, giant token credential blocks, focused-only validation lanes, or extra archive/image steps unless Derek explicitly commands that exact change.

## Emergency DKLab Retirement and Elderedd Migration

Priority: active. Status: continuing through v0.1.72.

Rules:

- Elderedd Softworks LLC is the parent company identity.
- Elderedd Laboratory is the active lab identity.
- ELDL is internal shorthand only.
- BCS means BSharp Creator Services and remains future service-layer naming only.
- DKLab is retired as active BASIC# identity.
- DKLab may remain as compatibility, rollback, migration, and archival history.
- Canonical future path: `~/Elderedd/Projects/BASIC#`.
- Legacy compatibility path: `~/DKLab/Projects/BASIC#`.
- Do not remove the DKLab compatibility bridge until a later accepted build proves no active BASIC# workflow depends on it.

## Self-hosting runway

Current truthful claim:

```text
BSharp Compiler Subset 0 has Self-Hosting Milestone 1 proof under Ruby referee control.
Ruby remains the bootstrap compiler and reference referee.
BASIC# is not fully self-hosted.
```

v0.1.72 proposes Self-Hosting Milestone 2 as a planning gate. It should define which BASIC# subset pieces move next toward compiling more of BASIC# with BASIC# machinery while preserving Ruby as the referee until parity proves otherwise.

## Self-Hosting Milestone 2 proposal targets

The Milestone 2 proposal should prepare the next implementation build to do useful self-hosting work, not more ceremony. Candidate implementation targets after v0.1.72:

1. Expand the small compiler subset execution corpus with a meaningful new compiler feature under Ruby referee parity.
2. Add BASIC#-authored fixture programs that exercise the subset more like real compiler input.
3. Preserve BSIR and BSBC golden parity while adding only one clearly bounded compiler capability.
4. Keep Ruby as the authority until BASIC# reproduces accepted outputs exactly.

## Game-making runway

After the next self-hosting planning gate, BASIC# should return to creator-facing power. The next major language/game behaviour lane remains object interaction.

```text
v0.1.73 candidate direction: Object Interaction, if v0.1.72 is accepted.
```

Possible object-interaction targets include creator-facing words that are already recognized but not fully executable end-to-end in the preferred runtime path.

## Public proof-application ladder

These are future proof programs, not current v0.1.72 implementation work:

1. Calculator
2. Text Adventure / choose-your-own-adventure
3. Pong
4. Breakout
5. Solitaire
6. Larger 2D Game
7. Media Player

Solitaire should become a public BASIC# showcase when the language can support it properly. The source/game may be free for noncommercial study and use, while Derek's Demon Killer custom card/deck artwork remains separately protected and excluded from the free-use grant.

## Release-hardening runway

The following gates remain active:

```text
tools/deterministic_fixture_hash_sweep.rb
tools/release_package_preflight.rb
tools/release_forensic_overlay.rb
tools/trial_by_fire_inventory.rb
tools/trial_by_fire_gauntlet.rb
```

They prevent stale fixture hashes, sealed artifact byte drift, manifest/payload mismatch, and incomplete validation from being accepted.

## Future BASIC# Graphics Format runway

This idea is recorded for later work only. It is not part of v0.1.72 implementation scope.

```text
BSG = BASIC# Graphics system
BGF = BASIC# Graphics Format
Extension = .bgf
```

Roadmap intent:

- Keep BGF as the native BASIC# graphics asset format idea so it is not lost.
- Treat BSG as the future graphics system/layer name, not the immediate compiler lane.
- Start later with a spec-only BGF build before any renderer or image engine work.
- Likely first BGF scope: raw RGBA images, palette images, metadata, checksum, and reader/writer validation contracts.
- Later BGF scopes may include sprites, tiles, heightmaps, animation frames, and BASIC# runtime loading/drawing words.
- Do not mix BGF implementation into the active self-hosting execution corpus lane.

## After v0.1.72

If v0.1.72 is accepted, the next likely work is one of the following:

1. Implement the first bounded Self-Hosting Milestone 2 slice.
2. Begin object interaction if Derek decides game-making forward motion outranks another self-hosting implementation step.
3. Repair any validation truth gap found during v0.1.72 acceptance.

Do not begin BCS implementation, accounts, hosting, pricing, network calls, server work, Project Oracle, or Demon Killer in this lane.

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
