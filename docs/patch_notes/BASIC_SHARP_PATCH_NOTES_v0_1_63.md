# BASIC# Patch Notes v0.1.63

v0.1.63 hardens the foundation before pushing self-hosting farther.

- BASIC# now explicitly reads source, BSharp IR, BSharp Save, and text fixtures as UTF-8 where the project controls file reads.
- A new UTF-8 contract proves `samples/text_values.bsharp` and `samples/text_values.bsir.json` run under a minimal/no-locale Ruby environment without `Encoding::CompatibilityError`.
- Elderedd remains the canonical identity direction.
- DKLab remains a retired compatibility bridge.
- New BSBC execution parity proves selected subset programs execute in the BSharp VM exactly like the Ruby referee runtime.
- The roadmap has one consolidated current continuation lane.
- No production syntax or runtime meaning changes are introduced.

## Repaired Candidate

The first v0.1.63 candidate was rejected by `tools/text_value_stress.rb` because the sealed Text Value save fixture hash was stale after the v0.1.63 version/save identity change. The repaired candidate preserves the same version number because no v0.1.63 package was accepted, commits no bridge removal, and reseals the deterministic save fixture expectation.
