# BASIC# Validation v0.1.80

Required acceptance validation:

- first BASIC#-authored compiler component source, spec, checked-in BSBC, readable disassembly, tool, and regression
- independent driver compilation of the native BASIC# compiler component
- primary native proof must survive with production compiler/runtime constructors disabled
- real persisted BSBC must reload and execute through the independent loader and independent BSharp VM after the temporary source copy is removed
- all nine accepted block heads must produce the locked compiler-domain decisions
- repeated compilation must be byte-identical and disassembly-identical
- production BytecodeEmitter, production BSharp VM, and Ruby Runtime referee parity
- Company Bible canonical header version must equal `BasicSharp::VERSION`
- Profiles 1-7 compatibility and no new creator-facing syntax
- complete normal test suite
- complete no-locale test suite
- sealed validation inventory and every required stress/tool lane
- deterministic fixture hash sweep
- release forensic overlay and package preflight
- whole-language gauntlet and full native Trial by Fire
- final installed version check

Accepted v0.1.79 floor: 651 runs, 9,930 assertions, 0 failures, 0 errors, 0 skips. Native installer validation remains authoritative for release acceptance.

Build-side v0.1.80 complete normal and no-locale suites: 660 runs, 9,998 assertions, 0 failures, 0 errors, 0 skips.
