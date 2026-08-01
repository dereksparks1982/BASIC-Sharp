# BASIC# Validation v0.1.36

## Required native acceptance result

```text
minimum runs: 382
minimum assertions: 7,750
failures: 0
errors: 0
skips: 0
Ruby warnings/stderr: 0
```

Every established Profile 1 through Profile 3 test and tool remains mandatory. Profile 4 additionally requires `tools/meaning_profile_4.rb`, `tools/bytecode_profile_4.rb`, and `tools/platform_movement_stress.rb`.

Required proofs include source/BSIR/BSBC parity, reference-runtime/BSharp VM declaration parity, ASK parity, Save format 4 restore, Profile 4 loader/disassembly validation, held input, releases, opposing input, jump gating, landing, ceiling and wall response, variable timing, 10,000 deterministic frames, and byte-identical preservation of all committed Profile 1 through Profile 3 BSBC and disassembly artifacts.

The installer must verify clean `main` at commit `8c5f096`, tag `v0.1.35`, validate every base and payload hash, install exactly the manifest scope, run the complete native suite and every focused/stress lane, and restore exact v0.1.35 after any post-mutation failure.

## Completed build-environment validation

- Focused Profile 4 movement tests: PASS.
- Twenty-five test files completed with zero failures, errors, or skips; ten native-bound files reached only unavailable process-pipe, temporary-directory, or atomic-rename operations with zero assertion failures before those boundaries.
- Stable Meaning Profile 4: PASS (8 cases).
- BSharp Bytecode Profile 4 contract, emission, loading, and fixture hashes: PASS.
- Profile 4 Save and ASK parity: PASS.
- Platform movement stress: PASS (10,000 frames).
- Profile 2 text-value stress Save hash refreshed for the v0.1.36 creator-version identity; rerun required and retained in the final sweep.
- Profile 1 through Profile 3 committed BSBC and disassembly preservation: PASS.
- Every executable default-count validation and stress lane passed, including the refreshed text-value lane.
- Native process-pipe, atomic-rename, complete aggregate, exact Git-scope, and rollback gates remain mandatory in Derek's installer.
