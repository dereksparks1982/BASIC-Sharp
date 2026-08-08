# BASIC# Plain-English Movement and Input v0.1.46

v0.1.46 keeps creator source focused on movement meaning instead of hardware details.

The creator still writes one plain `CONTROLS for PLAYER` declaration. The host may then send keyboard, mouse, PS5, Xbox, or generic gamepad events into `BasicSharp::GameInput`, and BASIC# maps those device events to the same engine-neutral host commands.

## Platform movement

```bsharp
CONTROLS for PLAYER
[
    A moves PLAYER left at 6 speed
    D moves PLAYER right at 6 speed
    SPACE makes PLAYER jump at 10 speed
].
```

The declaration above continues to mean left movement, right movement, and grounded jump. v0.1.46 additionally accepts equivalent device input:

| Meaning | Keyboard | PS5 | Xbox | Generic gamepad |
|---|---|---|---|---|
| left | `A`, arrows | d-pad left, left stick left | d-pad left, left stick left | d-pad left, left stick left |
| right | `D`, arrows | d-pad right, left stick right | d-pad right, left stick right | d-pad right, left stick right |
| jump | `SPACE` | Cross | A | south button |

## Top-down movement

Existing top-down controls remain valid:

```bsharp
CONTROLS for PLAYER
[
    W moves PLAYER north
    S moves PLAYER south
    A moves PLAYER west
    D moves PLAYER east
    PLAYER faces mouse pointer
    holding right mouse moves PLAYER toward mouse pointer
].
```

Keyboard arrows, d-pads, and left-stick directions normalize to the same north, south, west, and east movement meaning. Mouse pointer facing, right-mouse hold movement, and context-click priority remain unchanged.

## Boundary

This build adds no new BASIC# source syntax. It does not add controller remapping UI, game-engine driver code, haptics, camera control, graphics, Profile 8, or Ruby replacement.
