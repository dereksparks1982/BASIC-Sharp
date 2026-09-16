# BASIC# Validation v0.0.75

Required acceptance validation:

- dedicated BSBC emitter independence tests and tool gate
- independent encoder source must not require or call the production `BytecodeEmitter`
- exact byte-for-byte subset BSBC parity against the production Ruby referee
- golden BSBC SHA-256 and loader-summary parity
- existing BytecodeLoader acceptance of independent bytes
- BSharp VM and Ruby referee execution parity
- Profile 1-7 compatibility, including the mixed Profile 7 independence fixture
- complete normal test suite
- complete no-locale test suite
- sealed validation inventory
- all required stress/tool lanes
- deterministic fixture hash sweep
- release forensic overlay and package preflight
- full native Trial by Fire gauntlet
- final installed version check

Current suite floor: 77 test files, 599 runs, 9,503 assertions, 0 failures, 0 errors, 0 skips.
