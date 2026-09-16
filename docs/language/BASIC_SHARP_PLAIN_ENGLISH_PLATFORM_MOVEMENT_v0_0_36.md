# BASIC# Plain-English Platform Movement v0.0.36

## Creator form

```bsharp
CONTROLS for PLAYER
[
    A moves PLAYER left at 6 speed
    D moves PLAYER right at 6 speed
    SPACE makes PLAYER jump at 10 speed
].
```

Each key is written as one uppercase word. Each speed is a positive whole number. A platform declaration needs exactly one left job, one right job, and one jump job. A key cannot perform two platform jobs, and platform movement cannot be mixed with the accepted top-down control model.

The creator does not write polling loops, delta-time arithmetic, velocity storage, gravity, grounded checks, jump locks, wall/ceiling response, or engine calls. BASIC# owns those mechanics beneath the declaration.

## Stable behavior

- Holding left or right requests that direction at its declared speed.
- Holding both directions cancels horizontal movement.
- Releasing a direction stops its horizontal request on the next frame.
- Jump starts only when the jump key is newly pressed and the host reports grounded.
- Holding the jump key does not create repeated jumps.
- A jump pressed while airborne is consumed rather than silently buffered.
- Landing clears vertical velocity.
- A ceiling hit clears upward velocity before gravity continues.
- A left or right wall hit blocks velocity into that wall.
- Built-in gravity is `30` movement units per second squared.
- Frame time is derived from nondecreasing `time_ms`, with the first frame at zero elapsed time and later frames capped at `0.25` seconds for stall safety.

This build does not add animation, slopes, ladders, swimming, wall jumps, double jumps, coyote time, variable jump height, acceleration, controller remapping, rendering, or an engine-specific bridge.
