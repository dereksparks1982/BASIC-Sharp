# BASIC# v0.1.37 Build Handshake

## Approved build

- Title: **Plain-English Number Changes, Comparisons, and BSharp Profile 5**
- Accepted base: clean `main` at commit `ef43056`, tag `v0.1.36`
- Accepted snapshot SHA-256: `33a4565c71ffcd73193e58f8d9b7f6eb907b3eb9325673ed6389e693e08b3e16`
- Rollback: commit `ef43056`, tag `v0.1.36`
- Target: `v0.1.37`
- Exact project scope: 45 modified, 51 added, 0 deleted; 96 paths total.
- Package utility: one installer/validator script inside the ZIP; it is not an installed project path.
- Package: `BASIC_Sharp_Ruby_Bootstrap_Compiler_v0_1_37_PLAIN_ENGLISH_NUMBER_CHANGES_COMPARISONS_AND_BSHARP_PROFILE_5_CHANGED_FILES_ONLY.zip`

## Included behavior

- Adds atomic whole-number `increase` and `decrease` actions.
- Adds `at least`, `more than`, `at most`, and `less than` IF comparisons.
- Adds Stable Meaning Profile 5, BSharp Bytecode Profile 5, Save format 5, direct VM execution, ASK, fixtures, tests, and stress validation.
- Preserves exact equality and Profile 1 through Profile 4 artifacts.

## Explicit exclusions

No decimals, negatives, multiplication, division, percentages, equations, value-to-value calculations, random numbers, timers, collections, loops, `OTHERWISE`, engine bridge, rendering, editor, IDE, self-hosting, optimizer, JIT, native code, licensing, or monetization.

## Acceptance gate

The installer verifies the exact accepted Git base and clean tree, every base and payload hash, exact project scope, Ruby syntax with warnings enabled, every JSON file, the complete native suite at no fewer than 394 runs and 7,791 assertions, all established and Profile 5 tool lanes, byte-identical Profile 1 through Profile 4 artifacts, and exact Git scope. Any post-mutation failure restores v0.1.36 exactly. After native PASS, give Derek the Git commit and tag commands immediately.
