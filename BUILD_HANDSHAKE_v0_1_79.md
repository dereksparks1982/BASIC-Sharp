# BASIC# Build Handshake v0.1.79

- Project: BASIC# Ruby Bootstrap Compiler
- Version: v0.1.79
- Release: Self-Hosting Milestone 2 Slice 6 - Independent Compiler Driver + BSBC Artifact Round Trip
- Required base: v0.1.78
- Required base commit: `fac658396e719188b1a980d4d23e34ff81e7e86a`
- Required base tag: `v0.1.78`
- Package: `BASIC_Sharp_Ruby_Bootstrap_Compiler_v0_1_79_SELF_HOSTING_MILESTONE_2_INDEPENDENT_COMPILER_DRIVER_AND_BSBC_ARTIFACT_ROUND_TRIP_CHANGED_FILES_ONLY.zip`
- Rollback point: v0.1.78 at `fac658396e719188b1a980d4d23e34ff81e7e86a`

## Completed scope

- Add `SmallCompilerSubsetDriver` in front of the accepted v0.1.78 independent pipeline.
- Compile BASIC# source text or `.bsharp` files into real persisted `.bsbc` artifacts using the independent encoder atomic-write path.
- Reload saved artifacts with `SmallCompilerSubsetBSBCLoader` and execute them with `SmallCompilerSubsetBSBCVirtualMachine`.
- Prove deterministic artifact bytes and disassembly, source-free execution after successful compile, and atomic preservation on failed compilation.
- Require exact in-memory, persisted-artifact, production-VM referee, and Ruby-runtime referee parity.
- Preserve Profiles 1 through 7, the accepted BSBC layout, and existing creator-facing BASIC# syntax and written action order.

## Changed files

The authoritative changed-path inventory is `docs/changed_files/BASIC_SHARP_CHANGED_FILES_v0_1_79.txt` and `BASIC_SHARP_PATCH_MANIFEST.json`.

## Validation

Build-side complete normal and no-locale suites pass at 651 runs / 9,930 assertions / 0 failures / 0 errors / 0 skips. Acceptance additionally requires every sealed validation tool, deterministic fixture sweep, release package preflight, release forensic overlay, whole-language gauntlet, full-count Trial by Fire, final version check, and unmistakable `FINAL PASS`.

## Known risk and rollback

The critical risk is hidden delegation through a production compiler, loader, VM, or runtime path. Constructor-disable and exact artifact/runtime parity proofs guard that boundary. Any failed candidate returns to accepted v0.1.78 before a repaired v0.1.79 package is applied.

## Continuation

After installer `FINAL PASS`: accepted snapshot first, then local commit/tag, then GitHub push and peeled-tag verification. Do not begin v0.1.80 before v0.1.79 is fully closed.
