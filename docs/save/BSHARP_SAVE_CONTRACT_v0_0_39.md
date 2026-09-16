# BSharp Save Contract v0.0.39

Save format 7 supports `bsharp.meaning.v7`. For every IF rule with OTHERWISE, the save records the last settled branch as `IF` or `OTHERWISE` together with the existing deterministic runtime state.

Restore validates the program fingerprint, rule ordering, branch value, and state before mutation. Restoring a settled rule must not spuriously rerun either branch. Profile 1 through Profile 6 saves remain governed by their accepted formats.
