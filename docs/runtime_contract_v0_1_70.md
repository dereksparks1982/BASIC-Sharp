# BASIC# Runtime Contract v0.1.70

v0.1.70 does not change creator-facing runtime behaviour.

The release expands validation pressure around the existing runtime:

- Source, saved-BSIR, and BSBC runtime parity must hold under larger event counts.
- Input mapping and movement intent must produce identical command streams from source and loaded BSBC models.
- Save/restore, ASK, generated programs, and hostile artifact rejection remain guarded.
