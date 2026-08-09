# BASIC# Patch Notes v0.1.67

v0.1.67 adds the first explicit 2D versus 3D movement-intent proof.

The build recognizes 3D declarations such as `W moves PLAYER forward at 6 speed`, resolves them into `world_move` records, and emits `move_3d` runtime commands. Existing 2D, top-down, platform, mouse, and controller gates continue to pass.
