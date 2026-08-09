# BASIC# Release Forensic Overlay v0.1.69

v0.1.69 adds a pre-mutation release forensic overlay gate.

The gate copies the accepted project state to a temporary candidate tree, overlays the changed-files payload, and checks the sealed Trial by Fire validation inventory against that overlaid tree before the active project is mutated.

The gate reports all sealed inventory mismatches together. It is designed to catch stale records such as handoff, roadmap, Company Bible, tool, test, fixture, and package-document hash drift before acceptance validation begins.

This is release machinery only. It does not add new creator syntax, does not change runtime behaviour, does not remove the DKLab compatibility bridge, and does not claim BASIC# is fully self-hosted.
