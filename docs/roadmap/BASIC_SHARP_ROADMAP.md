# BASIC# Roadmap

## Current accepted base

```text
v0.1.63: UTF-8 hardening, Elderedd path proof, and BSBC execution parity
```

## Current candidate

```text
v0.1.65: Self-Hosting Execution Expansion and Release Gate Hardening
```

v0.1.65 expands the small compiler subset BSBC execution parity lane and adds release-hardening gates so deterministic fixture hashes, sealed inventory byte counts, package payload hashes, and changed-file scope are audited together before handoff.


## Canonical Company Bible

```text
docs/company_bible/BASIC_SHARP_COMPANY_BIBLE.md
```

This is the single canonical Company Bible reference for current BASIC# conduct, release, validation, rollback, packaging, Git, and Elderedd migration rules.

## Emergency DKLab Retirement and Elderedd Migration

Priority: Emergency. Status: active beginning in v0.1.62 and continuing through v0.1.65.

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
BSharp Compiler Subset 0 has staged self-hosting proof under Ruby referee control.
Ruby remains the bootstrap compiler and reference referee.
BASIC# is not fully self-hosted.
```

v0.1.65 expands the BSBC execution parity gate from the first execution proof into a broader sealed fixture lane. It adds repeated threshold crossing and IF/OTHERWISE rearming fixtures while preserving exact Ruby referee parity.

## Release-hardening runway

v0.1.65 adds two protective gates:

```text
tools/deterministic_fixture_hash_sweep.rb
tools/release_package_preflight.rb
```

These gates prevent the v0.1.63 rejected-candidate pattern:

```text
fix one stale fixture hash
miss another stale fixture hash
miss final sealed artifact byte drift
hand Derek a ZIP too early
```

Future packages should be proven by final extracted payload audit, not by piecemeal confidence.


## Future BASIC# Graphics Format runway

This idea is recorded for later work only. It is not part of v0.1.65 implementation scope.

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

## After v0.1.65

If v0.1.65 is accepted, the next likely work is one of the following:

1. Continue expanding small compiler subset BSBC execution parity carefully.
2. Prove the project can validate from `~/Elderedd/Projects/BASIC#` while preserving the DKLab bridge.
3. Prepare a later DKLab bridge-removal proposal only after no active BASIC# workflow depends on `~/DKLab/Projects/BASIC#`.

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
```
