# BASIC# Validation v0.1.76

Required acceptance validation:

- dedicated BSBC loader independence tests and tool gate
- independent loader source must not require, instantiate, or delegate to the production `BytecodeLoader`
- exact trusted-model, summary, fingerprint, instruction, selector, and condition parity against the Ruby referee
- exact rejection parity across the sealed 16-mutation malformed-artifact campaign
- independent encoder -> independent loader chain acceptance
- BSharp VM execution and Ruby referee runtime parity
- Profile 1-7 compatibility, including the mixed Profile 7 loader-independence fixture
- complete normal test suite
- complete no-locale test suite
- sealed validation inventory
- all required stress/tool lanes
- deterministic fixture hash sweep
- release forensic overlay and package preflight
- full native Trial by Fire gauntlet
- final installed version check

Current suite floor: 78 test files, 611 runs, 9,558 assertions, 0 failures, 0 errors, 0 skips.

The repaired README Current Release Truth Gate must reject stale canonical current-build/current-milestone lines anywhere in the full README, including lines outside the introductory release section.
