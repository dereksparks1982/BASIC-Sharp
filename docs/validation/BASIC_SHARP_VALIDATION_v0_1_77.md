# BASIC# Validation v0.1.77

Required acceptance validation:

- dedicated BSharp VM execution independence regression and tool gate
- independent VM source must not require, instantiate, inherit from, or delegate to production `BytecodeVirtualMachine`
- exact event-result, final-world, BSharp Save, selector, action-order, object-interaction, number/text mutation, IF/OTHERWISE, follow-up-event, and loop-protection parity
- production `BytecodeVirtualMachine` and `BasicSharp::Runtime` remain separate referees
- 1,024-event high-volume deterministic parity and 1,024 follow-up-event boundary proof
- complete 21-fixture / 60-event execution corpus
- Profiles 1-7 compatibility
- complete normal test suite
- complete no-locale test suite
- sealed validation inventory and all required stress/tool lanes
- deterministic fixture hash sweep
- release forensic overlay and package preflight
- full native Trial by Fire gauntlet
- final installed version check

Accepted base floor: 611 runs, 9,558 assertions, 0 failures, 0 errors, 0 skips. Candidate counts may grow but must never shrink below that floor.

Build-side candidate suite after Slice 4 integration: 622 runs, 9,717 assertions, 0 failures, 0 errors, 0 skips. Native installer validation remains authoritative for acceptance.
