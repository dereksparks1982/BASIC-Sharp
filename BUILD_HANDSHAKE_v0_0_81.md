# BASIC# Build Handshake v0.0.81

- Project: BASIC# Ruby Bootstrap Compiler
- Version: v0.0.81
- Release: Self-Hosting Milestone 2 Slice 8 - Native Parser Dispatch Integration
- Required base: v0.0.80
- Required base commit: `62b8a3ffc2eb80d785f80e5b6ba61fa210c5a336`
- Required base tag: `v0.0.80`
- Branch: `main`
- Package: `BASIC_Sharp_Ruby_Bootstrap_Compiler_v0_0_81_SELF_HOSTING_MILESTONE_2_NATIVE_PARSER_DISPATCH_INTEGRATION_CHANGED_FILES_ONLY.zip`
- Installer: `APPLY_BASIC_SHARP_v0_0_81.sh`
- Rollback point: v0.0.80 at `62b8a3ffc2eb80d785f80e5b6ba61fa210c5a336`

## Completed scope

- Add `SmallCompilerSubsetNativeDispatch` as the bounded bridge from the independent parser to the BASIC#-authored BSBC compiler component.
- Route the nine accepted top-level parser heads through the native component instead of a Ruby accepted-head dispatch table.
- Expose native dispatch invocation activity through the independent pipeline and driver.
- Fail closed when the native artifact is missing, returns an unclassified decision, or returns a deliberately wrong decision.
- Add a sabotage proof that a wrong native dispatch cannot silently fall back to Ruby routing.
- Add a controlled bootstrap proof using the accepted v0.0.80 native artifact for generation #1 and the generated v0.0.81 artifact for generation #2.
- Require byte-identical generation #1 and generation #2 BSBC plus deterministic disassembly.
- Preserve separate production and Ruby referee parity.
- Preserve Profiles 1 through 7, creator-facing BASIC# syntax, BSBC binary layout, Save meaning, ASK, input behavior, and existing game-making semantics.

## Native artifact fixed point

```text
BSBC SHA-256: cbebf931b65acc7d8ff75409a08d78624bdd9589b60c9c06cbbf66270a19d297
Disassembly SHA-256: fbd05ee0cbe94fd4a0fa17e4b257afbd2faa6a1df4ebda0dc2fd9b431ae1c20c
```

The v0.0.81 source comment/version changes the source and BSharp IR records but does not change the locked compiler decisions or BSBC bytes.

## Changed files

The authoritative changed-path inventory is `docs/changed_files/BASIC_SHARP_CHANGED_FILES_v0_0_81.txt` and `BASIC_SHARP_PATCH_MANIFEST.json`.

## Validation

Build-side complete normal and no-locale suites pass at 670 runs / 10,052 assertions / 0 failures / 0 errors / 0 skips. The native parser dispatch integration gate passes against the preserved accepted v0.0.80 bootstrap artifact, including all nine heads, invocation proof, invalid-head rejection, wrong-dispatch sabotage, constructor fences, independent compile/execute, fixed point, and production/Ruby referee parity.

Native acceptance additionally requires every sealed validation tool, all established stress/tool lanes, deterministic fixture sweep, release package preflight, release forensic overlay, whole-language gauntlet, full-count Trial by Fire, final version verification, and one unmistakable `FINAL PASS`.

## Known risk and rollback

The critical risk is ceremonial integration where Ruby still secretly decides parser routing. v0.0.81 controls that risk with fail-closed native dispatch, explicit invocation counts, source inspection against the former Ruby head table, wrong-dispatch sabotage, constructor-disable proofs, and fixed-point bootstrap regeneration.

Any failed candidate returns to exact accepted v0.0.80 and removes only v0.0.81 added paths before a repaired v0.0.81 package is applied.

## Continuation

After installer `FINAL PASS`: accepted snapshot first, then local commit plus annotated tag, then SSH GitHub push and peeled-tag verification. Do not begin v0.0.82 before v0.0.81 is fully closed.

Build-side full-count Trial by Fire was also validated at the locked counts: 128,000 events on each of four execution paths, 128,000 platform frames, 32,000 ASK questions, 64,000 combined input/movement frames, 1,250 Save checkpoints, 320 isolated worlds, follow-up boundaries 1023/1024/1025, 384 deterministic generated programs, and 3,072 mutations per boundary (12,288 hostile artifacts plus 3,040 truncated bytecode prefixes). Because the build host imposes a per-command execution ceiling, the canonical Trial by Fire phases were run in exact-count isolated processes; the release installer runs the canonical unsharded gauntlet natively before FINAL PASS.
