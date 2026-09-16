# BASIC# Plain-English Input Mapping v0.0.70

BASIC# v0.0.70 preserves the accepted input mapping that lets a creator declare player actions by meaning instead of writing a separate script for every device.

```basic
CONTROLS for PLAYER
[
    W moves PLAYER forward at 6 speed
    S moves PLAYER backward at 6 speed
    A moves PLAYER left at 6 speed
    D moves PLAYER right at 6 speed
    PLAYER can jump
    PLAYER can attack
    PLAYER can interact
    PLAYER can pause
].
```

When those action meanings are declared, keyboard, mouse, PS5, Xbox, and generic gamepad inputs can emit the same engine-neutral `input_action` command. For example, Space, PS5 Cross, Xbox A, and a generic south button all become the `jump` action. A left mouse click and the controller attack buttons become the `attack` action.

This build does not add controller remapping UI, per-player custom remapping syntax, a platform driver layer, camera controls, engine bridge code, graphics, Profile 8, or Ruby replacement.

## Device coverage

Keyboard, mouse, PS5, Xbox, and Generic gamepad inputs are covered for jump, attack, interact, and pause action mapping.


## v0.0.70 carry-forward note

This document remains the current input mapping reference while v0.0.70 hardens release forensics. No new input syntax is added in v0.0.70.
