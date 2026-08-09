# BASIC# Runtime Contract v0.1.67

v0.1.67 adds `move_3d` as a host command emitted by `BasicSharp::GameInput` when a resolved `CONTROLS for PLAYER` declaration uses 3D movement intent.

Required movement meanings:

- `forward` and `backward` operate on the z axis.
- `left` and `right` operate on the x axis as strafe-style movement.
- Diagonal 3D movement is normalized by the existing diagonal scalar.
- Keyboard, D-pad, and left-stick directional inputs map to the active movement context.

Out of scope: camera pitch/yaw, physics engine integration, graphics, engine bridge, and controller remapping UI.
