# BASIC# v0.1.75 Build Handshake

Project: BASIC# Ruby Bootstrap Compiler
Version: v0.1.75 Self-Hosting Milestone 2 Slice 2: BSBC Emitter Independence
Required base: v0.1.74
Required base commit: `6ef4cae79c4e353b54a2bd6376f43200636748f2`
Required base tag: `v0.1.74`
Package: `BASIC_Sharp_Ruby_Bootstrap_Compiler_v0_1_75_SELF_HOSTING_MILESTONE_2_BSBC_EMITTER_INDEPENDENCE_CHANGED_FILES_ONLY.zip`

## Completed changes

- Added `SmallCompilerSubsetBSBCEncoder` as the independent primary BSBC byte encoder for BSharp Compiler Subset 0.
- `SmallCompilerSubsetBSBCEmitter` now obtains its primary byte stream from the independent subset encoder.
- The production Ruby `BytecodeEmitter` remains a separate referee and is not required by the independent encoder.
- Exact byte-for-byte BSBC parity, golden SHA-256 parity, loader acceptance, BSharp VM execution parity, and Ruby-referee runtime parity remain mandatory.
- Added a dedicated Profile 7 independence fixture combining open, close, lock, take, whole-number increase, IF, and OTHERWISE.
- The self-hosting execution corpus expands to 19 fixtures and 57 events.
- The bounded subset now independently owns reader, parser, semantic resolution, IR generation, and BSBC generation stages under Ruby referee control.
- Ruby remains the bootstrap compiler. This build is not full self-hosting, does not add Profile 8, and does not change the BSBC format.

## Validation floor

- 77 discovered test files.
- 599 runs / 9,503 assertions / 0 failures / 0 errors / 0 skips.
- Full normal and no-locale suites are required in the installer.
- The BSBC-emitter-independence gate, all required stress/tool validation, deterministic fixture sweep, release gates, and full Trial by Fire remain mandatory before FINAL PASS.

## Rollback

Reset exactly to accepted `v0.1.74` at `6ef4cae79c4e353b54a2bd6376f43200636748f2` before applying a repaired candidate after any failed post-mutation validation.

## Closeout order

FINAL PASS -> accepted snapshot -> local Git commit/tag -> GitHub push/peeled-tag verification -> next build.
