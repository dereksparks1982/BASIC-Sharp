# BASIC# v0.0.33 Rejected Build Audit

**Date:** 2026-07-31  
**Status:** Preserved failure record  
**Accepted baseline:** v0.0.32, commit `3566b02`, tag `v0.0.32`

## What happened

Derek installed the v0.0.33 changed-files package from the exact accepted v0.0.32 base. Base identity, hashes, path installation, Ruby syntax, JSON parsing, the complete automated suite, and the first thirteen focused lanes passed. The complete suite reported:

```text
368 runs
7,686 assertions
0 failures
0 errors
0 skips
```

The next focused lane, `tools/bytecode_emitter.rb`, failed with:

```text
undefined method `profile' for an instance of BasicSharp::BytecodeEmitter
```

The tool correctly expected the Profile 3 emitter identity through a public read-only reader. `BytecodeEmitter` stored `@profile` and exposed the same value inside `model`, but did not expose `profile` itself.

During v0.0.34 validation, the later `tools/text_value_stress.rb` lane also exposed a stale deterministic Save hash inherited from v0.0.32. The Save meaning was correct; the serialized document now truthfully reports the current compiler version, so the expected deterministic hash required the matching v0.0.34 value. v0.0.33 never reached this later lane on Derek's machine because the emitter lane stopped first.

## Recovery

The rollback-safe installer restored every modified v0.0.32 file and removed every v0.0.33 added path. v0.0.33 was not accepted, committed, tagged, or used as a baseline.

## Corrective action

v0.0.34 re-carries the complete approved v0.0.33 feature set from the same accepted v0.0.32 base, adds the missing read-only profile accessor, adds direct Profile 1/2/3 regression coverage, refreshes the stale Profile 2 Save-document fixture hash, and keeps both focused lanes mandatory. The streamed one-command installer path is also repaired so it does not depend on `BASH_SOURCE` being available when read through standard input.
