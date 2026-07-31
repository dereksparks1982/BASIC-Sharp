# BASIC# Build Handshake v0.1.30

- Project: BASIC# Ruby Bootstrap Compiler
- Required base: v0.1.29
- Required commit: `c5c1374`
- Required tag: `v0.1.29`
- Target: v0.1.30
- Build: VM Parity, BSharp Save, BSharp ASK, and Hardening
- Package: `BASIC_Sharp_Ruby_Bootstrap_Compiler_v0_1_30_VM_PARITY_BSHARP_SAVE_ASK_AND_HARDENING_CHANGED_FILES_ONLY.zip`
- Completed: VM Save and restore, VM ASK, three-path parity, CLI integration, deterministic replay, isolation, malformed-save recovery, and bounded stress reporting.
- Excluded: reference-runtime removal, preferred-path transition, optimization, new bytecode profile, new language features, editor, IDE, engine bridge, self-hosting, licensing, and monetization.
- Validation: 292 runs, 7,262 assertions, zero failures/errors/skips; all established lanes and new VM hardening lane pass.
- Known risks: first VM remains Ruby-hosted; BSBC is not yet declared the preferred runtime path.
- Rollback: commit `c5c1374`, tag `v0.1.29`.
- Continuation: install, owner-validate, commit, and tag v0.1.30. Then decide the preferred runtime path and next Profile 2 capability.
