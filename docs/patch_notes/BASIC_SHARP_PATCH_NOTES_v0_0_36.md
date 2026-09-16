# BASIC# v0.0.36 Patch Notes

Creators can now describe a basic side-scroller controller directly:

```bsharp
CONTROLS for PLAYER
[
    A moves PLAYER left at 6 speed
    D moves PLAYER right at 6 speed
    SPACE makes PLAYER jump at 10 speed
].
```

BASIC# handles polling, releases, timing, velocity, gravity, grounded jump protection, and collision response. The host receives one engine-neutral collision-movement command per frame.

This build does not connect to Godot or Unity and does not add rendering, animation, slopes, ladders, swimming, wall jumps, double jumps, controller remapping, camera behavior, an editor, or an IDE.
