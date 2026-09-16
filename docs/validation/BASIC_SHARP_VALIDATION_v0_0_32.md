# BASIC# Validation v0.0.32

## Candidate status

Core implementation, deterministic Profile 2 fixtures, focused tests, stress coverage, syntax compilation, path-scope checks, and package-integrity checks are performed before delivery. Final acceptance remains conditional on the changed-files-only installer completing every native-Ruby gate on Derek's clean accepted repository.

## Build-environment results

```text
Profile 2 focused tests: 30 runs, 168 assertions
Failures: 0
Errors: 0
Skips: 0

WebAssembly-compatible regression: 314 runs, 7,334 assertions
Failures: 0
Errors: 0
Skips: 0

Complete suite discovered: 348 runs
Native-only cases deferred to installer: 34

Text event stress: 10,000 events per runtime path
Shadow parity: 25 independently reconstructed events
Save/restore stress: 100 cycles
ASK questions: 4
Result: PASS
```

Ruby syntax compilation also passes for all project Ruby files. JSON parsing, fixture hashes, exact profile identities, source/BSIR/bytecode determinism, and Profile 2 runtime fixture hashes are package gates.

The 34 deferred cases are the exact tests that require native process spawning through `Open3`, atomic file replacement, or native directory behavior. The WebAssembly run produced no BASIC# assertion failure; those cases stopped at unavailable host operations. The bytecode-emitter atomic-output tool and preferred-runtime command-wrapper tool stop at the same host boundary and are rerun by the installer.

## Native-Ruby result required before acceptance

The accepted v0.0.31 regression floor is 309 runs and 7,376 assertions with zero failures, errors, or skips. v0.0.32 must meet or exceed that floor and add the new Profile 2 tests. The final exact full-suite count is intentionally not claimed here because the build environment supplies Ruby through WebAssembly and cannot exercise native `Open3`, process CLI, atomic rename, or installed-extension behavior.

The installer runs native Ruby with warnings enabled and rejects any warning or nonzero status. It then runs:

- the complete test suite;
- all established source/runtime stress tools;
- Meaning Profile 1 and Profile 2 conformance;
- Company Bible audit;
- Bytecode Contract, Emitter, Loader, VM, VM stress, and preferred-runtime transition;
- creator text stress;
- Profile 1 artifact preservation;
- manifest, base hash, payload hash, scope, and direct-install path verification.

## Installation and rollback proofs

The package manifest identifies every approved project path, its operation, base hash where applicable, payload hash, size, and package utility. The installer requires clean `main` at exact commit `e7126c1f7e1963a72abb367687bfa0483fb59b64` with tag `v0.0.31`. It validates all hashes before mutation, installs only the 85 project paths, and restores the pre-install state if any post-mutation check fails.

## Acceptance rule

Do not commit or tag v0.0.32 until the installer reports a warning-free pass on Derek's native Ruby environment. On success, Derek may inspect the candidate, commit the installed project changes, and tag `v0.0.32` using the normal accepted workflow.
