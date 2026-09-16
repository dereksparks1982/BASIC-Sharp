# BASIC# Build Handshake v0.0.31

- Project: BASIC# Ruby Bootstrap Compiler
- Required base: v0.0.30
- Required commit: `30e1506`
- Required tag: `v0.0.30`
- Target: v0.0.31
- Build: BSharp VM Preferred Runtime Transition and Shadow Parity Verification
- Package: `BASIC_Sharp_Ruby_Bootstrap_Compiler_v0_0_31_BSHARP_VM_PREFERRED_RUNTIME_TRANSITION_AND_SHADOW_PARITY_CHANGED_FILES_ONLY.zip`
- Completed: default source/BSIR execution through in-memory BSBC and the BSharp VM, explicit reference-runtime opt-in, independent shadow parity verification, mismatch stopping, accepted-record continuity repair, and external Claude review evaluation.
- Excluded: reference-runtime deletion, new syntax or meaning, new bytecode profile, binary-layout changes, optimization, JIT, native code, editor, IDE, engine bridge, self-hosting, licensing, and monetization.
- Validation: 309 runs, 7,376 assertions, zero failures/errors/skips; all established lanes and the new preferred-runtime transition lane pass.
- Known risks: the preferred VM and reference oracle remain Ruby-hosted; shadow verification is intentionally slower because it reconstructs and independently replays both engines before committing each verified event.
- Rollback: commit `30e1506`, tag `v0.0.30`.
- Continuation: install, owner-validate, commit, and tag v0.0.31. Then choose the smallest creator-facing Profile 2 capability required for useful programs and eventual self-hosting.
