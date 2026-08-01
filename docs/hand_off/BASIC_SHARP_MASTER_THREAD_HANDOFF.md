# BASIC# Master Thread Handoff

## Current candidate

- **Accepted base:** v0.1.37 Plain-English Number Changes, Comparisons, and BSharp Profile 5
- **Accepted commit:** `8eb1fbe`
- **Accepted tag:** `v0.1.37`
- **Accepted branch:** `main`
- **Accepted native validation:** 394 runs, 7,809 assertions, zero failures, errors, or skips; all focused and stress lanes passed
- **Accepted snapshot:** `BASIC_SHARP_v0_1_37_ACCEPTED_COMMIT_8eb1fbe.zip`
- **Accepted snapshot SHA-256:** `eb489631bdab5032e5e5bd3858277d76a4bb86d3bcdb2d132e46ec4dbae9806f`
- **Candidate:** v0.1.38 Plain-English Compound IF Conditions and BSharp Profile 6
- **Exact project scope:** 48 modified, 53 added, 0 deleted; 101 paths total
- **Project path:** `/home/dereksparks1982/DKLab/Projects/BASIC#`
- **Package:** `BASIC_Sharp_Ruby_Bootstrap_Compiler_v0_1_38_PLAIN_ENGLISH_COMPOUND_IF_CONDITIONS_AND_BSHARP_PROFILE_6_CHANGED_FILES_ONLY.zip`

## Canonical authority

Read `docs/company_bible/BASIC_SHARP_COMPANY_BIBLE.md` from beginning to end before every proposal or build. It is the only active Company Bible.

## v0.1.37 acceptance

Derek installed v0.1.37 from accepted v0.1.36. Native validation passed with 394 runs and 7,809 assertions, zero failures, errors, or skips, and all mandatory tools. Derek committed it as `8eb1fbe`, tagged `v0.1.37`, confirmed a clean `main` tree, and created the accepted snapshot named above. That exact snapshot is the required v0.1.38 base.

## v0.1.38 completed candidate work

- Added multiple complete IF conditions joined by only `and` or only `or` on one IF line.
- Made `and` require every clause and `or` require at least one clause, with the complete group owning false-to-true waking and rearming.
- Allowed state, relation, creator-facing text, exact-number, and threshold clauses in source order while preserving quoted connector words literally.
- Rejected mixed connectors and incomplete clauses with plain-English diagnostics; nesting and precedence remain excluded.
- Carried new meaning through source parsing, resolver, BSIR, stable Meaning Profile 6, BSharp Bytecode Profile 6, loader, disassembly, direct BSharp VM execution, reference runtime, ASK, Save format 6, runtime transition, and parity.
- Added `ALL_CONDITIONS` and `ANY_CONDITIONS` bytecode records with exact ordered atomic clauses.
- Added a complete compound-condition sample, deterministic BSIR/BSBC/disassembly/Save/input/expected fixtures, 10 meaning cases, focused tests, and a 20,000-event-per-runtime stress lane.
- Preserved committed Profile 1 through Profile 5 BSBC and disassembly artifacts byte-for-byte.
- Updated the one canonical Company Bible, README, roadmap, contracts, validation record, changelog, patch notes, session log, changed-files ledger, manifest, handshake, and this cumulative handoff.

## Validation gate

Native owner validation must report at least the final recorded suite totals with:

```text
minimum runs: 412
minimum assertions: 7,903
failures: 0
errors: 0
skips: 0
Ruby warnings/stderr: 0
```

All established tools remain mandatory. New lanes are `tools/meaning_profile_6.rb`, `tools/bytecode_profile_6.rb`, and `tools/compound_if_stress.rb`. Validation must prove source/BSIR/BSBC/reference/BSharp VM parity, ASK, Save/restore, startup truth, false-to-true crossing, rearming, quoted connectors, malformed-clause rejection, IF loop protection, and exact Profile 1–5 artifact preservation.

## Explicit exclusions

No mixed `and`/`or` expressions, parentheses, nested condition groups, general `not`, `OTHERWISE`, `every`/`any #kind` conditions, value-to-value comparisons, decimals, equations, random numbers, timers, loops, collections, engine bridge, rendering, editor, IDE, self-hosting, optimizer, JIT, native code, licensing, or monetization.

## Risks and controls

- Older runtimes reject Profile 6 rather than silently ignoring compound meaning.
- The resolver scans connector words outside straight quoted text and validates every clause before execution.
- Compound IF rules retain accepted false-to-true waking, source ordering, rearming, and loop protection.
- Profile 1 through Profile 5 compatibility is protected by committed-artifact reproduction and hash tests.
- The installer requires clean `main`, exact commit `8eb1fbe`, tag `v0.1.37`, exact base hashes, exact payload hashes, and exact changed-path scope before mutation.

## Rollback

```text
commit 8eb1fbe
tag v0.1.37
```

Any post-mutation failure restores every replaced v0.1.37 file and removes every newly added v0.1.38 path.

## Continuation

Derek installs v0.1.38 and runs native validation. When it passes, give the Git commit/tag commands immediately, then give the accepted-snapshot command and propose the next focused build only after reading the accepted v0.1.38 records.

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
