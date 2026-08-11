# BASIC# Roadmap

## Current accepted base

```text
v0.1.72: Self-Hosting Milestone 2 Proposal and Roadmap Truth Repair
commit db1776050d74bf3f6110986fe0a52a78e103bb43
tag v0.1.72
```

v0.1.72 repaired the active roadmap/master handoff, recorded the Self-Hosting Milestone 2 proposal, preserved the full native validation lane, and locked the release closeout process into the canonical Company Bible.

## Current candidate

```text
v0.1.73: Plain-English Object Interaction Actions
```

v0.1.73 returns BASIC# to creator-facing game-making progress. The already-recognized official words `(open`, `(close`, `(lock`, and `(take` become executable end to end through the production resolver, BSIR, BSBC, preferred BSharp VM, Ruby referee runtime, and CONTEXT interaction path.

The new words reuse existing proven primitives instead of adding a new bytecode profile:

```text
(open  -> change target to open
(close -> change target to closed
(lock  -> change target to locked
(take  -> carry target
```

Existing selector rules remain authoritative. Exact `@objects`, established `it`, and `every #Kind` work where the current language already permits them. Retired selector forms remain retired.

## Canonical Company Bible

```text
docs/company_bible/BASIC_SHARP_COMPANY_BIBLE.md
```

This is the single canonical Company Bible reference for current BASIC# conduct, release, validation, rollback, packaging, GitHub closeout, and Elderedd migration rules.

## Release closeout order

Every BASIC# build must follow the proven release path:

1. Apply the changed-files ZIP with the exact terminal command supplied with the download.
2. Run installer validation including the complete normal test suite, complete no-locale suite when relevant, all required stress/tool gates, and full Trial by Fire native counts required by the build.
3. Installer output preserves `PHASE START` / `PHASE PASS`, visible Minitest dot progress, run/assertion counts, and one unmistakable `FINAL PASS`.
4. Create the accepted snapshot after final PASS and before local Git closeout.
5. Commit and tag locally only after acceptance proof.
6. Complete GitHub remote closeout only after local acceptance, using the proven project authentication path and never a username/password prompt.
7. Start the next build only after the current build is closed.

## Emergency DKLab Retirement and Elderedd Migration

Priority: active. Status: continuing through v0.1.73.

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

The accepted v0.1.72 Self-Hosting Milestone 2 proposal remains the planning record for the next bounded self-hosting implementation slice. v0.1.73 does not claim Milestone 2 implementation or Ruby retirement.

## Game-making runway

v0.1.73 begins the object-interaction lane with four direct creator actions. Future object-interaction work may expand other already-recognized words only through explicit approved builds and end-to-end execution proof.

Candidate directions after v0.1.73:

1. First bounded Self-Hosting Milestone 2 implementation slice under Ruby referee parity.
2. Next meaningful object-interaction expansion if Derek chooses game-making forward motion again.
3. Repair any proven validation/release defect before new functionality if one is found.

No new governance/audit system is planned unless a demonstrated failure requires it.

## Public proof-application ladder

These are future proof programs, not permission to interrupt the active compiler/runtime lane:

1. Calculator
2. Text Adventure / choose-your-own-adventure
3. Pong
4. Breakout
5. Solitaire
6. Larger 2D Game
7. Media Player

Solitaire is a future public BASIC# showcase. The game/source is intended for free noncommercial study and use, while Derek's Demon Killer custom card/deck artwork remains separately protected and excluded from that free-use grant.

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

Recorded for later only:

```text
BSG = BASIC# Graphics system
BGF = BASIC# Graphics Format
Extension = .bgf
```

Compatibility and functional language progress remain ahead of BGF implementation.

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
