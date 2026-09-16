# BASIC# Patch Notes v0.0.68

v0.0.68 adds plain-English input action mapping. A creator can declare `PLAYER can jump`, `PLAYER can attack`, `PLAYER can interact`, and `PLAYER can pause` inside `CONTROLS for PLAYER`. BASIC# then maps keyboard, mouse, PS5, Xbox, and generic gamepad events to one shared `input_action` command.


Repair note: this package reseals the stale deterministic fixture hashes found during first installer validation and repair, without changing the approved input-mapping scope.
