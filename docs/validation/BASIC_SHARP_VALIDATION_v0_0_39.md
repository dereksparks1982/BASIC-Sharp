# BASIC# Validation v0.0.39

## Candidate evidence

- Focused parser/runtime/Save/ASK tests: PASS in Ruby-WASM.
- Meaning Profile 7 conformance: PASS.
- Bytecode Profile 7 contract, loader, disassembly, and direct VM execution: PASS.
- 20,000 alternating branch transitions per runtime with exact parity: PASS.
- Profile 1 through Profile 6 committed BSBC and disassembly preservation: PASS.
- Streamed installer base/payload verification: PASS.
- Forced post-mutation failure restored accepted v0.0.38 byte-for-byte with a clean Git tree: PASS.
- Simulated successful installer path left exactly 111 declared Git paths and matching payload hashes: PASS.

The first native installation attempt ran the complete suite successfully with 431 runs and 7,995 assertions, zero failures, errors, or skips, but the installer rejected that valid result because its handwritten assertion floor was incorrectly set to 7,997. The installer then restored accepted v0.0.38 exactly. The corrected candidate floor is 431 runs and 7,995 assertions with zero failures, errors, skips, warnings, or stderr. Every mandatory tool remains an owner-side acceptance requirement. Ruby-WASM native-only limitations are not treated as owner acceptance.
