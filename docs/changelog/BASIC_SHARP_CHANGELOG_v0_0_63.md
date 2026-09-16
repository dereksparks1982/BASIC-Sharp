# BASIC# Changelog v0.0.63

## Added

- Added UTF-8 source reading contract and validation under a minimal/no-locale Ruby environment.
- Added Elderedd path bridge contract to prove the canonical Elderedd path direction while preserving the DKLab compatibility bridge.
- Added small compiler subset BSBC execution parity from source to BSharp IR to BSBC to BSharp VM execution against the Ruby referee runtime.

## Changed

- Explicit UTF-8 file reads are now used for BASIC# source, BSharp IR JSON, BSharp Save JSON, and text fixtures where the project controls file reading.
- Consolidated the roadmap current continuation material into one active v0.0.63 lane so older lane records do not masquerade as the next step.

## Preserved

- Ruby remains the bootstrap compiler and reference referee.
- DKLab remains retired compatibility/history only and is not removed in this build.
- GitHub private repository rule and build closeout order remain active.

## Excluded

No language syntax, runtime meaning, bytecode format, Profile 8, BCS implementation, Project Oracle, or Demon Killer change.

## Repaired Candidate

The first v0.0.63 candidate was rejected by `tools/text_value_stress.rb` because the sealed Text Value save fixture hash was stale after the v0.0.63 version/save identity change. The repaired candidate preserves the same version number because no v0.0.63 package was accepted, commits no bridge removal, and reseals the deterministic save fixture expectation.
