# BASIC# Plain-English 2D and 3D Movement Intent v0.0.68

BASIC# v0.0.68 separates 2D screen movement from 3D facing-direction movement.

In a 2D or top-down style control declaration, W may mean up or north. In a 3D control declaration, W may mean forward, S may mean backward, and A/D may mean left/right strafe.

```basic
CONTROLS for PLAYER
[
    W moves PLAYER forward at 6 speed
    S moves PLAYER backward at 6 speed
    A moves PLAYER left at 6 speed
    D moves PLAYER right at 6 speed
].
```

The resolved BSharp IR lowers these declarations to `world_move` records. Keyboard and gamepad inputs map underneath that intent, so a controller D-pad up or left-stick up can also mean forward in a 3D movement context.

This build does not add camera controls, engine bridge code, graphics, Profile 8, or a controller remapping UI.
