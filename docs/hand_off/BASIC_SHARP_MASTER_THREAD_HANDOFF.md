# BASIC# Master Thread Handoff

## Current candidate

- **Accepted base:** v0.1.44 Self-Hosting Foundation and Rejected Package Repair Record
- **Accepted commit:** `b630b031666a527d8549e6715e59065071a3efd0`
- **Accepted tag:** `v0.1.44`
- **Accepted branch:** `main`
- **Accepted native validation:** 452 runs, 8,027 assertions, zero failures, errors, or skips; full native Trial-by-Fire gauntlet PASS with results SHA-256 `5b6bfad1b846bfdea7761ff1712f7bb48abce854cc59fce4068b573b9c8ea717`
- **Candidate:** v0.1.46 Plain-English Movement and Input Contract
- **Project path:** `/home/dereksparks1982/DKLab/Projects/BASIC#`
- **Package:** `BASIC_Sharp_Ruby_Bootstrap_Compiler_v0_1_46_PLAIN_ENGLISH_MOVEMENT_AND_INPUT_CONTRACT_CHANGED_FILES_ONLY.zip`
- **Language scope:** Profiles 1-7 only; no new creator syntax, bytecode profile, Save format, engine bridge, controller driver layer, or Ruby replacement

## Canonical authority

Read `docs/company_bible/BASIC_SHARP_COMPANY_BIBLE.md` completely before any proposal or build. The active self-hosting contract is `spec/self_hosting/BASIC_SHARP_SELF_HOSTING_SUBSET_v1.json`. The active input-device contract is `spec/input/BASIC_SHARP_INPUT_DEVICE_MAPPING_v1.json`.

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

## v0.1.46 candidate work

- Re-carries the intended movement/input scope after v0.1.45 failed native validation and rolled back to v0.1.44.
- Adds `docs/audit/BASIC_SHARP_v0_1_45_REJECTED_BUILD_AUDIT.md`.
- Adds the input-device mapping contract for keyboard, mouse/keyboard, PS5, Xbox, and generic gamepad events.
- Adds `spec/input/BASIC_SHARP_INPUT_DEVICE_MAPPING_v1.json`.
- Adds `docs/language/BASIC_SHARP_PLAIN_ENGLISH_MOVEMENT_AND_INPUT_v0_1_46.md`.
- Adds `tools/input_device_contract.rb` and `tests/test_input_device_contract.rb`.
- Extends `BasicSharp::GameInput` to normalize arrow keys, device buttons, and left-stick axes into existing top-down and platform movement host commands.
- Updates platform and Demon Killer input tests/stress tools.
- Updates Company Bible, README, roadmap, runtime contract, validation, changelog, patch notes, session log, changed-files record, and master handoff.
- Advances live version truth to `0.1.46`.

## Explicit exclusions

No Profile 8, new creator syntax, controller remapping UI, platform-specific driver layer, haptics, camera controls, engine bridge, rendering, editor, IDE, self-hosting expansion, Ruby replacement, licensing, monetization, Project Oracle, or BASIC# Semantic Oracle implementation.

## Validation status

The build workspace lacks native Ruby. Ruby-WASM is used for focused input and fixture validation. Native owner acceptance remains mandatory and must run the complete installer from exact accepted v0.1.44.

The v0.1.46 version-bearing fixture hashes are:

```text
Text-value Save:       d017c872c42cf19681f4cc1d12294b89d3590d779ff11a254d6d475fb06a2f4a
Number-change result: 5aff7cf11f60937e0f2b1f9d1551b07b65442ca3791e5c70385c7b08d246dd76
Compound-IF result:   4b26523add4393d83923796fcf1b6000cbea590fcd685862a0e4afdb3d4053ae
OTHERWISE result:     e7bf4ea88b6785fb2bc75979c665be1aaca0d9129d6e27b017c0b418187c4f6e
```

## Package scope and rollback

The installer requires exact accepted v0.1.44 commit `b630b031666a527d8549e6715e59065071a3efd0`, tag `v0.1.44`, branch `main`, clean tree, base hashes, payload hashes, and exact manifest scope. Any post-mutation failure restores every replaced v0.1.44 file and removes every v0.1.46 path.

## Owner installation sequence

1. Download the exact changed-files-only ZIP into `~/Downloads`.
2. Run the one-command installer supplied with delivery.
3. Do not commit if any phase fails; rollback is automatic.
4. After the installer prints native PASS, commit all manifest-listed changes and tag `v0.1.46`.
5. Create the accepted full-project snapshot and record its SHA-256 before beginning another build.

## Next action

Run native owner installation and validation. v0.1.46 is not accepted until Derek's machine reports every sealed gate as PASS and Derek commits/tags the result.

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
