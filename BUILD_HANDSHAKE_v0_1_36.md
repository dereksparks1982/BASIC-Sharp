# BASIC# v0.1.36 Build Handshake

## Approved build

- Title: **Plain-English Platform Movement and BSharp Profile 4**
- Accepted base: clean `main` at commit `8c5f096`, tag `v0.1.35`
- Rollback: commit `8c5f096`, tag `v0.1.35`
- Target: `v0.1.36`
- Project scope: 43 modified paths, 48 added paths, 0 deleted paths, 91 total project paths.
- Package utility: one installer/validator script inside the ZIP; it is not an installed project path.
- Package: `BASIC_Sharp_Ruby_Bootstrap_Compiler_v0_1_36_PLAIN_ENGLISH_PLATFORM_MOVEMENT_AND_BSHARP_PROFILE_4_CHANGED_FILES_ONLY.zip`

## Included behavior

- Adds creator-chosen left/right/jump speed declarations under `CONTROLS for PLAYER`.
- Hides polling, release, timing, velocity, gravity, grounded jump gating, wall/ceiling/landing response, and engine calls.
- Adds deterministic `move_with_collisions` host commands.
- Carries platform movement through BSIR, Meaning Profile 4, Bytecode Profile 4, loader, BSharp VM, reference runtime, ASK, Save format 4, shadow parity, samples, fixtures, tests, and stress validation.
- Preserves accepted top-down controls and Profile 1 through Profile 3 artifacts.

## Explicit exclusions

No engine bridge, rendering, animation, slopes, ladders, swimming, wall/double jumps, variable jump height, acceleration, coyote time, controller remapping, camera, editor, IDE, self-hosting, licensing, monetization, optimizer, JIT, or native machine code.

## Acceptance gate

The installer verifies the exact accepted Git base and clean tree, every base and payload hash, exact 91-path scope, Ruby syntax with warnings enabled, every JSON file, the complete native suite at no fewer than 382 runs and 7,750 assertions, all established and Profile 4 tool lanes, byte-identical Profile 1 through Profile 3 artifacts, and exact Git scope. Any post-mutation failure restores v0.1.35 exactly. After native PASS, give Derek the Git commit and tag commands immediately.
