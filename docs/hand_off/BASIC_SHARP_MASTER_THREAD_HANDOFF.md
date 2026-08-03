# BASIC# Master Thread Handoff

## Current candidate

- **Accepted base:** v0.1.42 Trial by Fire Complete Re-Carry, Complete Versioned Runtime Fixture Repair, and BSharp VM Hardening
- **Accepted commit:** `1d79a6221a388ffd6e372d6bfe21d9df1cb38c2c`
- **Accepted tag:** `v0.1.42`
- **Accepted branch:** `main`
- **Accepted native validation:** 448 runs, 8,012 assertions, zero failures, errors, or skips; full native Trial-by-Fire gauntlet PASS with results SHA-256 `a4655ebd043e927b82b487a6ef18fdfd53b6d3d06da2eab5659cf8369f4fbd80`
- **Candidate:** v0.1.44 Self-Hosting Foundation and Rejected Package Repair Record
- **Project path:** `/home/dereksparks1982/DKLab/Projects/BASIC#`
- **Package:** `BASIC_Sharp_Ruby_Bootstrap_Compiler_v0_1_44_SELF_HOSTING_FOUNDATION_AND_REJECTED_PACKAGE_REPAIR_RECORD_CHANGED_FILES_ONLY.zip`
- **Language scope:** Profiles 1-7 only; no new creator syntax, meaning, bytecode profile, Save format, or Ruby replacement

## Canonical authority

Read `docs/company_bible/BASIC_SHARP_COMPANY_BIBLE.md` completely before any proposal or build. The active self-hosting contract is `spec/self_hosting/BASIC_SHARP_SELF_HOSTING_SUBSET_v1.json` and the explanatory record is `docs/self_hosting/BASIC_SHARP_SELF_HOSTING_FOUNDATION_v0_1_44.md`.

## v0.1.42 accepted base

Derek ran the v0.1.42 installer natively. It passed the complete suite, every required tool, and the full Trial-by-Fire gauntlet. Derek committed the accepted tree as `1d79a6221a388ffd6e372d6bfe21d9df1cb38c2c` and tagged it `v0.1.42` on clean `main`.

## v0.1.43 rejected package

v0.1.43 is rejected and must not be reused. The package stopped before mutation with `ERROR: Manifest arrays have the wrong lengths.` The user command and filename were correct; the installer was malformed because literal NUL bytes were embedded where escaped `\0` separators were intended. See `docs/audit/BASIC_SHARP_v0_1_43_REJECTED_PACKAGE_AUDIT.md`.

## v0.1.44 candidate work

- Re-carries the intended self-hosting foundation from the rejected v0.1.43 package.
- Defines BSharp Compiler Subset 0 as a foundation contract only.
- Adds `docs/audit/BASIC_SHARP_v0_1_43_REJECTED_PACKAGE_AUDIT.md`.
- Adds `spec/self_hosting/BASIC_SHARP_SELF_HOSTING_SUBSET_v1.json`.
- Adds `docs/self_hosting/BASIC_SHARP_SELF_HOSTING_FOUNDATION_v0_1_44.md`.
- Adds `tools/self_hosting_contract.rb` and `tests/test_self_hosting_contract.rb`.
- Updates Company Bible, README, roadmap, runtime contract, validation, changelog, patch notes, session log, and changed-files record.
- Advances live version truth to `0.1.44`.
- Regenerates all current version-bearing runtime fixture hashes together.
- Adds the self-hosting contract tool to the Trial-by-Fire validation inventory.

## Explicit exclusions

No Profile 8, new creator syntax, changed meaning, timers, randomness, loops, collections, functions, string interpolation, native code generation, engine bridge, rendering, editor, IDE, BSharp native document app, licensing, monetization, Project Oracle, or BASIC# Semantic Oracle implementation. v0.1.44 does not replace Ruby and does not claim BASIC# is self-hosted.

## Validation status

The build workspace lacks native Ruby. Ruby-WASM was restored for focused fixture diagnosis. Native owner acceptance remains mandatory and must run the complete installer from exact accepted v0.1.42.

The v0.1.44 version-bearing fixture hashes are:

```text
Text-value Save:       410f9b77ec4d58485c693ba0bc6439808d312da43e9ead1006baf2498d2ed6e8
Number-change result: c3156c0b7df4730cf3534c93fe88235f433dc6e01ff2910a5dc8bc36cee64963
Compound-IF result:   d67504e22737c0e79ca299c09cce53a8a966479d2fc81e9d3b26d60ac507d597
OTHERWISE result:     b9e68aef8cd1faa764333edfa0f9b730c3289e64dc895212ca6ff72fa7002969
```

## Package scope and rollback

The installer requires exact accepted v0.1.42 commit `1d79a6221a388ffd6e372d6bfe21d9df1cb38c2c`, tag `v0.1.42`, branch `main`, clean tree, base hashes, payload hashes, and exact manifest scope. Any post-mutation failure restores every replaced v0.1.42 file and removes every v0.1.44 path.

## Owner installation sequence

1. Download the exact changed-files-only ZIP into `~/Downloads`.
2. Run the one-command installer supplied with delivery.
3. Do not commit if any phase fails; rollback is automatic.
4. After the installer prints native PASS, commit all manifest-listed changes and tag `v0.1.44`.
5. Create the accepted full-project snapshot and record its SHA-256 before beginning another build.

## Next action

Run native owner installation and validation. v0.1.44 is not accepted until Derek's machine reports every sealed gate as PASS and Derek commits/tags the result.

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
