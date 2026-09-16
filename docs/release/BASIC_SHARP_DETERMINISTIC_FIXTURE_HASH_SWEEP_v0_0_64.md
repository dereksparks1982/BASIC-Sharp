# BASIC# Deterministic Fixture Hash Sweep v0.0.64

v0.0.64 adds a deterministic fixture hash sweep gate to prevent single-goblin repairs.

The sweep runs the complete version-sensitive fixture family together: text values, number changes, compound IF, OTHERWISE, and small compiler subset BSBC execution parity. A candidate is rejected if any stale expected hash, save document hash, or sealed fixture record remains.

The correct repair pattern is to reseal the full family together, then re-run the full installer validation sequence.
