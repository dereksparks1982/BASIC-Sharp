# BASIC# Changelog v0.1.35

- Re-carried the complete Profile 3 work after v0.1.34 failed owner-side runtime-transition validation and rolled back to v0.1.32.
- Corrected the standalone transition audit to derive direct-BSBC and reference-runtime banners from `BasicSharp::VERSION`.
- Added regression coverage that rejects hard-coded runtime banner versions.
- Tightened direct `.bsbc` CLI coverage to require the exact active BSharp VM identity.
- Preserved both rejected-build records and automatic rollback evidence.
- Advanced active compiler, runtime, generated artifacts, tests, documentation, manifest, and package identity to v0.1.35.
