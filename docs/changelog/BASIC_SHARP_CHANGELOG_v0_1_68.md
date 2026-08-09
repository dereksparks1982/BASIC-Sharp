# BASIC# Changelog v0.1.68

- Added plain-English player action declarations for jump, attack, interact, and pause.
- Added engine-neutral `input_action` command emission from keyboard, mouse, PS5, Xbox, and generic gamepad inputs.
- Preserved v0.1.67 2D and 3D movement intent as the movement floor.
- Resealed validation inventory and release preflight records for v0.1.68.

Repair note:
- Repaired the candidate by resealing the Profile 2 deterministic fixture hashes for Profile 2 text-value saves, Profile 5 number-change expected output, Profile 6 compound-IF expected output, and Profile 7 OTHERWISE expected output after installer validation found a stale `save_document_sha256`.
