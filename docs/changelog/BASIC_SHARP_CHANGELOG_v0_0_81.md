# BASIC# Changelog v0.0.81

## Self-Hosting Milestone 2 Slice 8

- Added `SmallCompilerSubsetNativeDispatch`, which executes the BASIC#-authored compiler BSBC component to classify parser heads.
- Integrated native dispatch into `SmallCompilerSubsetParser` for all nine accepted top-level heads.
- Exposed native dispatch invocation counts through the independent pipeline and driver.
- Removed the old accepted-head Ruby dispatch table from the bounded parser route.
- Added fail-closed invalid/unclassified decision handling.
- Added wrong-dispatch sabotage validation proving there is no silent Ruby fallback.
- Added controlled v0.0.80-to-v0.0.81 bootstrap fencing and byte-identical two-generation fixed-point validation.
- Added native parser dispatch spec, documentation, tool, regression tests, and bootstrap-boundary records.
- Regenerated version-sensitive BSharp IR and Save golden hashes only after independent and referee parity remained exact.
- Preserved Profiles 1-7, BSBC binary layout, production routing, creator-facing syntax, and accepted runtime/game-making meaning.
