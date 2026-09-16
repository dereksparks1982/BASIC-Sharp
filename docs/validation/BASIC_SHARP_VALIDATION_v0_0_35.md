# BASIC# Validation v0.0.35

## Required native acceptance result

```text
minimum runs: 370
minimum assertions: 7,698
failures: 0
errors: 0
skips: 0
Ruby warnings/stderr: 0
```

Every established stress, Meaning Profile, Bytecode Contract, Emitter, Loader, VM, runtime transition, text value, comment, Demon Killer input, and game interaction lane must pass. The runtime-transition lane must prove direct `.bsbc` remains on the BSharp VM and explicit reference mode remains on `BasicSharp::Runtime`, with both banners derived from `BasicSharp::VERSION`. Profile 1 and Profile 2 committed BSBC and disassembly hashes must remain unchanged. The package must match the exact manifest scope and restore accepted v0.0.32 if any post-install gate fails.

The build environment can exercise parser, resolver, runtime, VM, Profile 3, comment, interaction, and static package gates through Ruby WebAssembly, but it cannot reproduce native `Open3`, process CLI, or atomic-rename behavior. Derek's native installer result remains the acceptance authority. Do not commit or tag v0.0.35 before every native gate passes and Derek accepts the build.

## Completed build-environment validation

- Ruby syntax compilation: PASS.
- JSON parsing: PASS.
- Twenty-three test files: PASS with zero failures, errors, or skips.
- Ten native-bound test files: zero assertion failures before stopping only at unavailable `Open3` pipes or temporary-directory operations.
- Meaning Profiles 1, 2, and 3, Company Bible, bytecode contract, loader, VM, Demon Killer input, game interaction, and comment lanes: PASS.
- Runtime, Kind family, IF, multiple selection, values, follow-up event, Save, ASK, VM hardening, and text-value stress lanes at their default counts: PASS.
- Direct `.bsbc` execution independently reported `BSharp Virtual Machine v0.0.35`; explicit reference mode independently reported `BASIC# Runtime v0.0.35`.
- The standalone emitter lane reached the unavailable atomic-write operation; the complete emitter model tests reported zero assertion failures before native boundaries.
- The standalone transition lane reached the unavailable `Open3` pipe; its live-version regression test passed in the automated suite.

The remaining native-only checks stay mandatory in the installer and are not waived.
