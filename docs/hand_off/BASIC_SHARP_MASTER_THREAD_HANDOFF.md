# BASIC# Master Thread Handoff

## Current candidate

- **Accepted base:** v0.1.38 Plain-English Compound IF Conditions and BSharp Profile 6
- **Accepted commit:** `3a92d4e`
- **Accepted tag:** `v0.1.38`
- **Accepted branch:** `main`
- **Accepted native validation:** 412 runs, 7,903 assertions, zero failures, errors, or skips; all focused and stress lanes passed
- **Accepted snapshot:** `BASIC_SHARP_v0_1_38_ACCEPTED_COMMIT_3a92d4e.zip`
- **Accepted snapshot SHA-256:** `f96024127eec66324b11f745fb3569974f8b90ef35f385fb2822ad4ba8eb9dea`
- **Candidate:** v0.1.39 Plain-English OTHERWISE Branches and BSharp Profile 7
- **Exact project scope:** 58 modified, 53 added, 0 deleted; 111 paths total
- **Project path:** `/home/dereksparks1982/DKLab/Projects/BASIC#`
- **Package:** `BASIC_Sharp_Ruby_Bootstrap_Compiler_v0_1_39_PLAIN_ENGLISH_OTHERWISE_BRANCHES_AND_BSHARP_PROFILE_7_CHANGED_FILES_ONLY.zip`

## Canonical authority

Read `docs/company_bible/BASIC_SHARP_COMPANY_BIBLE.md` from beginning to end before every proposal or build. It is the only active Company Bible.

## v0.1.38 acceptance

Derek installed v0.1.38 from accepted v0.1.37. Native validation passed with 412 runs and 7,903 assertions, zero failures, errors, or skips, and all mandatory tools. Derek committed it as `3a92d4e`, tagged `v0.1.38`, confirmed a clean `main` tree, and created the accepted snapshot named above. That exact snapshot is the required v0.1.39 base.

## v0.1.39 completed candidate work

- Added a directly following `OTHERWISE` action block to IF rules, with blank lines and comments permitted between the paired Heads.
- Made each two-sided rule run its current branch once at START, IF on false-to-true, OTHERWISE on true-to-false, and remain quiet while unchanged.
- Preserved ordinary IF behavior and supported both atomic and Profile 6 compound conditions.
- Rejected standalone, misplaced, repeated, and conditional OTHERWISE sections; `ELSE` is rejected with guidance to use `OTHERWISE`.
- Carried branch meaning through source, BSIR, Stable Meaning Profile 7, BSharp Bytecode Profile 7, loader, disassembly, BSharp VM, reference runtime, ASK, Save format 7, restore, runtime transition, and parity.
- Added a complete sample, deterministic fixtures, 10 meaning cases, focused tests, and a 20,000-transition-per-runtime alternating-branch stress lane.
- Preserved committed Profile 1 through Profile 6 BSBC and disassembly artifacts byte-for-byte.
- Updated the one canonical Company Bible, README, roadmap, contracts, validation record, changelog, patch notes, session log, changed-files ledger, manifest, handshake, and this cumulative handoff.

## Validation gate

Native owner validation must report at least the final recorded suite totals with:

```text
minimum runs: 431
minimum assertions: 7,995
failures: 0
errors: 0
skips: 0
Ruby warnings/stderr: 0
```

All established tools remain mandatory. New lanes are `tools/meaning_profile_7.rb`, `tools/bytecode_profile_7.rb`, and `tools/otherwise_branch_stress.rb`. Validation must prove both startup branches, both truth transitions, quiet unchanged states, source/BSIR/BSBC/reference/BSharp VM parity, ASK, Save/restore, compound conditions, malformed placement, loop protection, and exact Profile 1–6 artifact preservation.

## Explicit exclusions

No `ELSE`, `ELSE IF`, chained OTHERWISE branches, nested IF blocks, general `not`, mixed `and`/`or`, parentheses, value-to-value comparisons, decimals, equations, random numbers, timers, loops, collections, engine bridge, rendering, editor, IDE, self-hosting, optimizer, JIT, native code, licensing, or monetization.

## Risks and controls

- Older runtimes reject Profile 7 rather than silently ignoring OTHERWISE meaning.
- Pairing is structural and requires OTHERWISE to be the next meaningful Head after its matching IF.
- Branch actions complete before reactive settlement resumes; accepted ordering and loop protection remain authoritative.
- Profile 1 through Profile 6 compatibility is protected by committed-artifact reproduction and hash tests.
- The installer requires clean `main`, exact commit `3a92d4e`, tag `v0.1.38`, exact base hashes, exact payload hashes, and exact changed-path scope before mutation.

## Rollback

```text
commit 3a92d4e
tag v0.1.38
```

Any post-mutation failure restores every replaced v0.1.38 file and removes every newly added v0.1.39 path.

The first v0.1.39 candidate package was rejected on Derek's native machine after the complete suite passed with 431 runs and 7,995 assertions, zero failures, errors, or skips. Its installer had an incorrect handwritten floor of 7,997 assertions. The installer restored accepted v0.1.38 exactly. The corrected v0.1.39 candidate uses the observed 7,995-assertion floor; no language, runtime, bytecode, Save, ASK, or scope behavior changed.

## Continuation

Derek installs v0.1.39 and runs native validation. When it passes, give the Git commit/tag commands immediately, then give the accepted-snapshot command and propose the next focused build only after reading the accepted v0.1.39 records.

## Accepted recent history

- v0.1.24 Stable Meaning Specification and Conformance Profile 1, `28e5b5b`.
- v0.1.25 Canonical Company Bible Consolidation, `dadd813`.
- v0.1.26-v0.1.28 BSharp Bytecode Profile 1 architecture, emission, disassembly, loading, and validation.
- v0.1.29-v0.1.30 first BSharp VM, parity, Save, ASK, and hardening.
- v0.1.31 preferred BSharp VM runtime and shadow parity, `e7126c1`.
- v0.1.32 creator-facing text values and Profile 2, `3566b02`.
- v0.1.33 and v0.1.34 rejected; rollback restored v0.1.32.
- v0.1.35 complete Profile 3 re-carry and runtime-transition repair, `8c5f096`.
- v0.1.36 plain-English platform movement and Profile 4, `ef43056`.
- v0.1.37 plain-English number changes, comparisons, and Profile 5, `8eb1fbe`.
- v0.1.38 plain-English compound IF conditions and Profile 6, `3a92d4e`.
