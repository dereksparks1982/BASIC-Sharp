# BASIC# v0.1.45 Rejected Build Audit

## Status

v0.1.45 is rejected and must not be committed, tagged, or used as a baseline.

## Accepted base preserved

The accepted base remains v0.1.44 commit `b630b031666a527d8549e6715e59065071a3efd0`, tag `v0.1.44`, branch `main`.

## Failure

Derek ran the v0.1.45 installer natively. The installer verified the exact v0.1.44 base, installed 34 modified and 11 added paths, then failed during the complete test suite:

```text
TestPlatformMovement#test_ps5_xbox_and_generic_gamepads_drive_same_platform_meaning
Expected: -10.0
  Actual: -9.52
```

The installer restored exact v0.1.44 after the failure.

## Cause

The Xbox jump assertion expected raw jump velocity after the previous platform frame had already advanced time by 16ms. Platform gravity correctly changed `-10.0` to `-9.52` because `30.0 * 0.016 = 0.48`.

The controller mapping contract was not the broken behavior. The rejected build contained a timing/isolation mistake in the test.

## Repair

v0.1.46 re-carries the intended v0.1.45 movement/input contract from accepted v0.1.44, isolates the Xbox jump assertion on a fresh `GameInput` instance at `time_ms` 0, and preserves the same keyboard, mouse/keyboard, PS5, Xbox, and generic gamepad scope.

No new creator syntax, controller driver integration, engine bridge, Profile 8, or Ruby replacement is included in the repair.
