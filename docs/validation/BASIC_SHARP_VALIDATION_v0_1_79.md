# BASIC# Validation v0.1.79

Required acceptance validation:

- independent `SmallCompilerSubsetDriver` regression and tool gate
- persisted BSBC artifact round-trip regression and tool gate
- primary driver path must survive with production compiler/runtime constructors disabled
- real `.bsbc` bytes must equal the accepted independent in-memory encoder bytes
- saved artifact must reload through the independent loader and execute through the independent BSharp VM
- deterministic repeated artifact bytes and readable disassembly
- source-free execution after successful artifact creation
- failed source compilation must not overwrite an existing accepted artifact
- exact in-memory, persisted-artifact, production BSharp VM referee, and Ruby Runtime referee parity
- Profiles 1-7 compatibility and no new creator-facing syntax
- complete normal test suite
- complete no-locale test suite
- sealed validation inventory and every required stress/tool lane
- deterministic fixture hash sweep
- release forensic overlay and package preflight
- whole-language gauntlet and full native Trial by Fire
- final installed version check

Accepted v0.1.78 floor: 633 runs, 9,786 assertions, 0 failures, 0 errors, 0 skips. Native installer validation remains authoritative for release acceptance.

Build-side v0.1.79 complete normal and no-locale suites: 651 runs, 9,930 assertions, 0 failures, 0 errors, 0 skips.
