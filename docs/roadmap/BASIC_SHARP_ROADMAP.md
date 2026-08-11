# BASIC# Roadmap

## Current accepted base

```text
v0.1.75: Self-Hosting Milestone 2 Slice 2 - BSBC Emitter Independence
commit e711ee4e7d4b8c0bbd2f845c1e955423bbc739f3
tag v0.1.75
```

v0.1.75 is the accepted rollback point. It gave BSharp Compiler Subset 0 an independent BSBC encoder while the production Ruby BytecodeEmitter remained referee-only, then passed the full native validation lane before snapshot, local Git closeout, and GitHub verification.

## Current candidate

```text
v0.1.76: Self-Hosting Milestone 2 Slice 3 - BSBC Loader Independence
```

v0.1.76 gives BSharp Compiler Subset 0 an independent `SmallCompilerSubsetBSBCLoader`. The subset trust boundary must decode and validate BSBC without requiring, instantiating, or inheriting from the production Ruby `BytecodeLoader`. The production loader remains a separate exact-parity referee only.

The bounded subset proof lane for this build is:

```text
TokenizerReader
-> SmallCompilerSubsetParser
-> SmallCompilerSubsetSemanticResolver
-> BSharp IR
-> SmallCompilerSubsetBSBCEncoder
-> BSharp Bytecode
-> SmallCompilerSubsetBSBCLoader
-> BSharp VM execution engine
```

The execution corpus expands to 20 fixtures and 58 events. The v0.1.76 fixture carries Kind inheritance, creator text, whole-number state, open/close/lock/take object interaction, IF/OTHERWISE, and exact/Kind selector meaning through independent semantic resolution, independent Profile 7 BSBC encoding, independent BSBC loading, BSharp VM execution, and Ruby-referee parity.

The loader trust boundary also runs a 16-mutation malformed-artifact parity campaign. Bad magic, unsupported profiles, section geometry, truncation, invalid indexes, invalid opcodes/selectors/conditions, operand-width corruption, record-count corruption, bad code targets, and trailing data must be rejected with the same deterministic message as the production loader referee.

Reference: `spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_BSBC_EMITTER_INDEPENDENCE_v1.json` remains the accepted Slice 2 encoder-independence contract.
Reference: `spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_BSBC_LOADER_INDEPENDENCE_v1.json`.
Reference: `docs/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_BSBC_LOADER_INDEPENDENCE_v0_1_76.md`.
Reference: `compiler/small_compiler_subset_bsbc_loader.rb`.

Ruby remains the bootstrap compiler. v0.1.76 is not full self-hosting and does not change normal production compiler routing, Profile 1-7 meaning, the BSBC binary format, runtime meaning, Save, ASK, or input behaviour.

## Canonical Company Bible

```text
docs/company_bible/BASIC_SHARP_COMPANY_BIBLE.md
```

This is the single canonical Company Bible reference for current BASIC# conduct, release, validation, rollback, packaging, GitHub closeout, and Elderedd migration rules.

## Release closeout order

Every BASIC# build must follow the proven release path:

1. Apply the changed-files ZIP with the exact terminal command supplied with the download.
2. Run installer validation including the complete normal test suite, complete no-locale suite, all required stress/tool gates, and full Trial by Fire native counts required by the build.
3. Installer output preserves `PHASE START` / `PHASE PASS`, visible Minitest dot progress, run/assertion counts, and one unmistakable `FINAL PASS`.
4. Create the accepted snapshot after final PASS and before local Git closeout.
5. Commit and tag locally only after acceptance proof.
6. Complete GitHub remote closeout only after local acceptance, using the proven no-password project authentication path.
7. Start the next build only after the current build is closed.

## Emergency DKLab Retirement and Elderedd Migration

Priority: active. Status: continuing through v0.1.76.

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
BSharp Compiler Subset 0 has Self-Hosting Milestone 2 Slice 3 under Ruby referee control.
The subset path owns reader, parser, semantic resolver, BSBC encoding, and BSBC loading stages for its bounded lane.
Ruby remains the bootstrap compiler and production referee.
BASIC# is not fully self-hosted.
```

The v0.1.72 proposal is now further implemented by v0.1.74 semantic resolver independence, v0.1.75 BSBC emitter independence, and v0.1.76 BSBC loader independence. Future Milestone 2 slices should continue removing bounded subset dependence on production compiler stages while exact parity remains mandatory.

## Game-making runway

v0.1.73 established four direct creator actions: open, close, lock, and take. v0.1.76 carries them with text, numeric, inheritance, and IF/OTHERWISE meaning through independently emitted and independently loaded Profile 7 BSBC so game-making progress and compiler-independence progress remain connected.

## Next direction after v0.1.76

1. Continue Self-Hosting Milestone 2 with the next bounded production-compiler dependency removal under Ruby referee parity.
2. A meaningful creator/game-making capability expansion if Derek chooses that lane.
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
spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_SEMANTIC_RESOLVER_v1.json
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
