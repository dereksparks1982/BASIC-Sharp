# BASIC# Master Thread Handoff

## Current candidate

- **Accepted base:** v0.1.39 Plain-English OTHERWISE Branches and BSharp Profile 7
- **Accepted commit:** `066e715`
- **Accepted tag:** `v0.1.39`
- **Accepted branch:** `main`
- **Accepted native validation:** 431 runs, 7,995 assertions, zero failures, errors, or skips; all mandatory tools passed
- **Candidate:** v0.1.42 Trial by Fire Complete Re-Carry, Complete Versioned Runtime Fixture Repair, and BSharp VM Hardening
- **Project path:** `/home/dereksparks1982/DKLab/Projects/BASIC#`
- **Package:** `BASIC_Sharp_Ruby_Bootstrap_Compiler_v0_1_42_TRIAL_BY_FIRE_COMPLETE_RE_CARRY_COMPLETE_VERSIONED_RUNTIME_FIXTURE_REPAIR_AND_BSHARP_VM_HARDENING_CHANGED_FILES_ONLY.zip`
- **Language scope:** Profiles 1–7 only; no new creator syntax, meaning, bytecode profile, or Save format

## Canonical authority

Read `docs/company_bible/BASIC_SHARP_COMPANY_BIBLE.md` completely before any proposal or build. It remains the only active Company Bible. Derek decides intended language behavior; Stable Meaning Specifications record it. The compiler, reference runtime, and BSharp VM are implementations and may not grade themselves as infallible.

The v0.1.42 Company Bible requires a complete audit of every artifact, expected result, manifest, fixture, and protected hash whose bytes can contain or depend on the target version. Regenerate and validate the whole version-bearing inventory together before packaging.

## Oracle distinction

Project Oracle is a separate autonomous-world project. Its in-world female Oracle may help simulated inhabitants for reasons she chooses. She is not part of BASIC# v0.1.42.

The shelved BASIC# Semantic Oracle is different: it must obey Derek-approved semantics, report truthfully, have no private agenda, and remain independent of the production compiler/VM. It requires a future exact proposal and approval. See `docs/research/BASIC_SHARP_SEMANTIC_ORACLE_FUTURE_CONCEPT.md`.

## Accepted base

Derek accepted v0.1.39 at commit `066e715`, tagged it `v0.1.39`, and established that exact clean `main` state as the only v0.1.42 rollback point. v0.1.39 introduced Profile 7 IF/OTHERWISE meaning. v0.1.42 does not alter that meaning.

## v0.1.40 failed native candidate

Derek ran the complete v0.1.40 installer from exact v0.1.39. Base and payload verification, Ruby syntax, JSON, sealed inventory, the complete suite (448 runs, 8,012 assertions, zero failures/errors/skips), and every required phase before text-value stress passed. `tools/text_value_stress.rb` correctly failed because the package omitted its version-specific Save fixture update.

Independent reproduction showed the Save changed only from `created_by_basic_sharp: 0.1.39` to `0.1.40`. The installer restored every accepted v0.1.39 byte and removed all candidate paths. v0.1.40 is permanently failed and not reused.

## v0.1.41 failed native candidate

The v0.1.41 installer again verified exact v0.1.39, installed 18 modified and 28 added paths, passed the complete 448-run/8,012-assertion suite, passed the repaired full-default text-value gate, and passed every required phase through platform movement. `tools/number_change_stress.rb` then correctly failed its expected runtime result.

Independent reproduction showed exactly one semantic JSON difference: `$.save.created_by_basic_sharp` changed from `0.1.39` to `0.1.41`. Complete downstream audit found the compound-IF and OTHERWISE expected results carried the same stale field and would have failed later. The installer again restored exact v0.1.39. v0.1.41 is permanently failed and not reused.

## v0.1.42 completed candidate work

- Re-carried the complete Trial-by-Fire project scope from exact v0.1.39.
- Preserved the hand-authored Profiles 1–7 proving ground, independently locked golden trace, 256-program generator, coverage matrix, four-boundary mutation engine, full native hammer phases, 17 focused tests, sealed inventory, and all protected artifacts.
- Regenerated all four known version-sensitive runtime fixtures together.
- Locked text-value Save hash `b0e2436d54335e068a41c1cd0666a1696c8aa5fe0be75c76a9b22f7fc4f1b5ef`.
- Locked number-change result hash `ed76938a393bdfd700c9ef2e1dbad78f0aedc472da70ba7437690a04f3a5e47a`.
- Locked compound-IF result hash `00da07fa749683b8a7d2bb45e655bd769fa1840762984cbf45ee9e2308f51970`.
- Locked OTHERWISE result hash `a0f0a83b09794d9eff9231a357f287d38ae6aa863df10f54f88997718834adea`.
- Passed all four repaired stress gates at full defaults in Ruby-WASM without weakening any validator.
- Added the complete version-bearing fixture-audit rule to the one canonical Company Bible.
- Recorded both failed native candidates and successful automatic rollbacks permanently.
- Found no accepted-semantics defect requiring compiler, resolver, runtime, VM, Save, ASK, or input behavior changes.

## Validation status

Available Ruby-WASM preflight proves the repaired four-fixture set and their full-default owning stress tools. The carried Trial-by-Fire evidence covers the independently locked campaign, all 256 generated programs, all 8,192 hostile artifacts, all 3,040 truncated principal BSBC prefixes, follow-up boundaries 1,023/1,024/1,025, and the focused tests.

Native Ruby is unavailable in the build workspace. Therefore native owner acceptance remains mandatory. The installer must obtain at least 448 runs and 8,012 assertions with zero failures, errors, skips, warnings, or stderr, then run every inventory-listed tool and the full default gauntlet from the beginning.

## Explicit exclusions

No Profile 8, new creator syntax, changed meaning, timers, runtime randomness, loops, collections, equations, decimals, nested IF, mixed `and`/`or`, engine bridge, rendering, editor, IDE, self-hosting, licensing, or monetization. No Project Oracle or BASIC# Semantic Oracle implementation is included.

## Package scope and rollback

- Modified project paths: 24
- Added project paths: 28
- Deleted paths: 0
- Total project paths: 52

```text
commit 066e715
tag v0.1.39
```

The installer requires that exact commit and tag, clean `main`, all declared base hashes, all payload hashes, and exact manifest scope. Any post-mutation failure restores every replaced v0.1.39 file and removes every v0.1.42 path.

## Owner installation sequence

1. Download the exact changed-files-only ZIP into `~/Downloads`.
2. Run the one-command installer supplied with delivery.
3. Do not commit if any phase fails; rollback is automatic.
4. After the installer prints native PASS, commit all manifest-listed changes and tag `v0.1.42`.
5. Create the accepted full-project snapshot and record its SHA-256 before beginning another build.

## Next action

Run native owner installation and validation. v0.1.42 is not accepted until Derek’s machine reports every sealed gate as PASS and Derek commits/tags the result.

## Accepted and failed recent history

- v0.1.24 Stable Meaning Specification and Conformance Profile 1, `28e5b5b`.
- v0.1.25 Canonical Company Bible Consolidation, `dadd813`.
- v0.1.26–v0.1.30 BSharp Bytecode Profile 1, first BSharp VM, parity, Save, ASK, and hardening.
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
