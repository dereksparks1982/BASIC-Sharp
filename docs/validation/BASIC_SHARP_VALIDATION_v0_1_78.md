# BASIC# Validation v0.1.78

Required acceptance validation:

- integrated `SmallCompilerSubsetPipeline` regression and tool gate
- primary pipeline must survive with production Lexer, Parser, SemanticResolver, BytecodeEmitter, BytecodeLoader, BytecodeVirtualMachine, and Runtime constructors disabled in an isolated proof process
- `TokenizerReader` primary reader records must not depend on production Lexer output
- exact BSharp IR, BSBC, loader-summary, event-result, final-world, BSharp Save, and deterministic replay parity
- production compiler/runtime components remain separate referees
- Profiles 1-7 compatibility and no new creator-facing syntax
- complete normal test suite
- complete no-locale test suite
- sealed validation inventory and every required stress/tool lane
- deterministic fixture hash sweep
- release forensic overlay and package preflight
- whole-language gauntlet and full native Trial by Fire
- final installed version check

Accepted base floor: 622 runs, 9,717 assertions, 0 failures, 0 errors, 0 skips.

Build-side Slice 5 suite after version-sensitive golden-family regeneration: 633 runs, 9,786 assertions, 0 failures, 0 errors, 0 skips in both normal and no-locale runs. Native installer validation remains authoritative for acceptance.
