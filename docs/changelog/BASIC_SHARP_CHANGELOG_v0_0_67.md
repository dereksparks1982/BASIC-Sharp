# BASIC# Changelog v0.0.67

## Plain-English 2D and 3D Movement Intent

- Added 3D movement control declarations using forward/backward/left/right intent.
- Added `world_move` lowering for 3D movement controls.
- Added runtime emission of `move_3d` commands with x/z velocity fields.
- Added keyboard and gamepad proof that W or D-pad up means forward in a 3D movement context.
- Preserved existing 2D/top-down and platform movement behavior.
- Preserved Elderedd path proof and DKLab compatibility bridge.
