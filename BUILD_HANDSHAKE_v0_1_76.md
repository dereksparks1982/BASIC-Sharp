# BASIC# v0.1.76 Build Handshake

Project: BASIC# Ruby Bootstrap Compiler
Version: v0.1.76 Self-Hosting Milestone 2 Slice 3: BSBC Loader Independence
Required base: v0.1.75
Required base commit: `e711ee4e7d4b8c0bbd2f845c1e955423bbc739f3`
Required base tag: `v0.1.75`
Package: `BASIC_Sharp_Ruby_Bootstrap_Compiler_v0_1_76_README_TRUTH_GATE_REPAIR_SELF_HOSTING_MILESTONE_2_BSBC_LOADER_INDEPENDENCE_CHANGED_FILES_ONLY.zip`

## Completed changes

- Added `SmallCompilerSubsetBSBCLoader` as the independent BSBC decoding and validation stage for BSharp Compiler Subset 0.
- The production Ruby `BytecodeLoader` remains a separate referee and is not required by the independent subset loader.
- Added exact trusted-model, summary, fingerprint, instruction, selector, and condition parity checks.
- Added a 16-mutation malformed-artifact campaign with exact rejection parity against the production loader referee.
- Added a bootstrap-only VM adapter so independently loaded trusted models execute through the existing BSharp VM engine without changing normal production routing.
- Added a dedicated Profile 7 loader-independence fixture combining Kind inheritance, text and whole-number values, open/close/lock/take, IF/OTHERWISE, and selector use.
- The self-hosting execution corpus expands to 20 fixtures and 58 events.
- The bounded subset now independently owns source reading, parsing, semantic resolution, IR generation, BSBC generation, and BSBC loading under Ruby referee control.
- Ruby remains the bootstrap compiler. This build is not full self-hosting, does not add Profile 8, and does not change the BSBC format.

## Validation floor

- 78 discovered test files.
- 611 runs / 9,558 assertions / 0 failures / 0 errors / 0 skips.
- README truth repair: canonical `Current self-hosting milestone:` and `Current build:` lines are now validated across the full README, closing the stale-line gap found before Git acceptance.
- Full normal and no-locale suites are required in the installer.
- The BSBC-loader-independence gate, malformed-artifact campaign, all required stress/tool validation, deterministic fixture sweep, release gates, and full Trial by Fire remain mandatory before FINAL PASS.

## Rollback

Reset exactly to accepted `v0.1.75` at `e711ee4e7d4b8c0bbd2f845c1e955423bbc739f3` before applying a repaired candidate after any failed post-mutation validation.

## Closeout order

FINAL PASS -> accepted snapshot -> local Git commit/tag -> GitHub push/peeled-tag verification -> next build.
