# BASIC# v0.1.35 Build Handshake

## Approved build

- Title: **Direct BSBC Runtime-Transition Validation Repair and Complete Profile 3 Re-Carry**
- Accepted base: clean `main` at commit `3566b02`, tag `v0.1.32`
- Rollback: commit `3566b02`, tag `v0.1.32`
- Target: `v0.1.35`
- Project scope: 107 modified paths, 76 added paths, 0 deleted paths, 183 total project paths.
- Package utility: one installer/validator script inside the ZIP; it is not an installed project path.
- Package: `BASIC_Sharp_Ruby_Bootstrap_Compiler_v0_1_35_DIRECT_BSBC_RUNTIME_TRANSITION_VALIDATION_REPAIR_AND_COMPLETE_PROFILE_3_RE_CARRY_CHANGED_FILES_ONLY.zip`

## Included behavior

- Re-carries the complete owner-approved Profile 3 feature set because v0.1.33 and v0.1.34 were rejected and both installers restored v0.1.32.
- Preserves the v0.1.34 emitter accessor repair and corrected Profile 2 Save fixture.
- Replaces the stale direct-BSBC and reference-runtime banner literals in `tools/runtime_transition.rb` with the live `BasicSharp::VERSION` identity.
- Adds a regression test that rejects hard-coded runtime banner versions in the standalone transition audit.
- Tightens direct `.bsbc` CLI coverage to require the exact active BSharp VM version.
- Advances every active compiler, runtime, generated artifact, test, record, and package identity to v0.1.35 while preserving rejected-build evidence.

## Explicit exclusions

No new creator-facing syntax or meaning; no collision, physics, rendering, controller remapping, arithmetic, repetition, modules, editor, IDE, engine bridge, self-hosting, licensing, or monetization work.

## Acceptance gate

The installer must verify the exact accepted v0.1.32 Git base and clean tree, verify every base and payload hash, install exactly the manifest scope, compile every Ruby file with warnings enabled, parse every JSON file, run the complete native Ruby suite, run every established and Profile 3 validation lane, preserve Profile 1 and Profile 2 artifacts, verify exact Git scope, and restore v0.1.32 on any post-mutation failure. `tools/runtime_transition.rb` must prove both the direct-BSBC BSharp VM banner and explicit reference-runtime banner against `BasicSharp::VERSION`. Do not commit or tag until Derek accepts the installed build.
