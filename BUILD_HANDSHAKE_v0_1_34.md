# BASIC# v0.1.34 Rejected Build Handshake

- Base: accepted `v0.1.32`, commit `3566b02`, tag `v0.1.32`, branch `main`, clean tree.
- Candidate: v0.1.33 Profile 3 Validation Repair and Complete Feature Re-Carry.
- Attempted scope: 106 modified paths, 68 added paths, 0 deleted paths, 174 total project paths.
- Owner-side suite: 369 runs, 7,692 assertions, 0 failures, 0 errors, 0 skips.
- Focused lanes passed through `tools/bytecode_vm_stress.rb`.
- Rejection: `tools/runtime_transition.rb` hard-coded the retired `v0.1.32` VM banner while the v0.1.34 candidate correctly reported `BSharp Virtual Machine v0.1.34`.
- The direct `.bsbc` route remained the BSharp VM; the version-sensitive validator produced the false failure.
- Result: the installer restored the exact v0.1.32 project state. v0.1.34 was not accepted, committed, tagged, or made a baseline.
- Repair version: v0.1.35. The rejected number is not reused.
- Failure audit: `docs/audit/BASIC_SHARP_v0_1_34_REJECTED_BUILD_AUDIT.md`.
