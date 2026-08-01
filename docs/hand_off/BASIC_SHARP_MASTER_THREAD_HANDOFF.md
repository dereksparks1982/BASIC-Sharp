# BASIC# Master Thread Handoff

## Current candidate

- **Accepted base:** v0.1.36 Plain-English Platform Movement and BSharp Profile 4
- **Accepted commit:** `ef43056`
- **Accepted tag:** `v0.1.36`
- **Accepted branch:** `main`
- **Accepted native validation:** 382 runs, 7,750 assertions, zero failures, errors, or skips; all focused and stress lanes passed
- **Accepted snapshot:** `BASIC_SHARP_v0_1_36_ACCEPTED_COMMIT_ef43056.zip`
- **Accepted snapshot SHA-256:** `33a4565c71ffcd73193e58f8d9b7f6eb907b3eb9325673ed6389e693e08b3e16`
- **Candidate:** v0.1.37 Plain-English Number Changes, Comparisons, and BSharp Profile 5
- **Exact project scope:** 45 modified, 51 added, 0 deleted; 96 paths total
- **Project path:** `/home/dereksparks1982/DKLab/Projects/BASIC#`
- **Package:** `BASIC_Sharp_Ruby_Bootstrap_Compiler_v0_1_37_PLAIN_ENGLISH_NUMBER_CHANGES_COMPARISONS_AND_BSHARP_PROFILE_5_CHANGED_FILES_ONLY.zip`

## Canonical authority

Read `docs/company_bible/BASIC_SHARP_COMPANY_BIBLE.md` from beginning to end before every proposal or build. It is the only active Company Bible.

## v0.1.36 acceptance

Derek installed v0.1.36 from accepted v0.1.35. Native validation passed with 382 runs and 7,750 assertions, zero failures, errors, or skips, and all mandatory tools. Derek committed it as `ef43056`, tagged `v0.1.36`, confirmed a clean `main` tree, and created the accepted snapshot named above. That exact snapshot is the required v0.1.37 base.

## v0.1.37 completed candidate work

- Added `(increase value of Thing by N` and `(decrease value of Thing by N` for positive whole-number amounts.
- Added exact threshold conditions: `has at least`, `has more than`, `has at most`, and `has less than`.
- Preserved existing `has N value` exact equality without changing its profile or behavior.
- Enforced the existing whole-number range of 0 through 2,147,483,647.
- Made missing-value, wrong-type, overflow, underflow, and `every #kind` failures atomic: all selected Things change or none do.
- Carried new meaning through source parsing, resolver, BSIR, stable Meaning Profile 5, BSharp Bytecode Profile 5, loader, disassembly, direct BSharp VM execution, reference runtime, ASK, Save format 5, runtime transition, and parity.
- Added `INCREASE_VALUE`, `DECREASE_VALUE`, `VALUE_AT_LEAST`, `VALUE_MORE_THAN`, `VALUE_AT_MOST`, and `VALUE_LESS_THAN` bytecode records.
- Added a complete number-change sample, deterministic BSIR/BSBC/disassembly/Save/input/expected fixtures, 10 meaning cases, focused tests, and a 20,000-event number-change stress lane.
- Preserved committed Profile 1 through Profile 4 BSBC and disassembly artifacts byte-for-byte.
- Updated the one canonical Company Bible, README, roadmap, contracts, validation record, changelog, patch notes, session log, changed-files ledger, manifest, handshake, and this cumulative handoff.

## Validation gate

Native owner validation must report at least the final recorded suite totals with:

```text
minimum runs: 394
minimum assertions: 7,791
failures: 0
errors: 0
skips: 0
Ruby warnings/stderr: 0
```

All established tools remain mandatory. New lanes are `tools/meaning_profile_5.rb`, `tools/bytecode_profile_5.rb`, and `tools/number_change_stress.rb`. Validation must prove source/BSIR/BSBC/reference/BSharp VM parity, ASK, Save/restore, threshold crossing and rearming, set atomicity, overflow/underflow rejection, and exact Profile 1–4 artifact preservation.

## Explicit exclusions

No decimals, negative numbers, multiplication, division, percentages, general equations, value-to-value calculations, random numbers, timers, collections, loops, `OTHERWISE`, engine bridge, rendering, editor, IDE, self-hosting, optimizer, JIT, native code, licensing, or monetization.

## Risks and controls

- Older runtimes reject Profile 5 rather than silently ignoring new number meaning.
- Increase/decrease validate every selected target before the first mutation.
- Threshold IF rules retain accepted false-to-true waking, source ordering, rearming, and loop protection.
- Profile 1 through Profile 4 compatibility is protected by committed-artifact reproduction and hash tests.
- The installer requires clean `main`, exact commit `ef43056`, tag `v0.1.36`, exact base hashes, exact payload hashes, and exact changed-path scope before mutation.

## Rollback

```text
commit ef43056
tag v0.1.36
```

Any post-mutation failure restores every replaced v0.1.36 file and removes every newly added v0.1.37 path.

## Continuation

Derek installs v0.1.37 and runs native validation. When it passes, give the Git commit/tag commands immediately, then give the accepted-snapshot command and propose the next focused build without making Derek ask what comes next.

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
