# BASIC# Release Package Preflight v0.1.64

v0.1.64 adds a release preflight gate so a changed-files package cannot be entered into acceptance validation merely because one local symptom was repaired.

The gate checks the active patch manifest, version identity, package filename, installer name, manifest counts, payload byte counts, payload SHA-256 values, Git changed-file scope, and validation-inventory inclusion for the release-hardening tools.

This does not remove the DKLab compatibility bridge and does not claim BASIC# is fully self-hosted.
