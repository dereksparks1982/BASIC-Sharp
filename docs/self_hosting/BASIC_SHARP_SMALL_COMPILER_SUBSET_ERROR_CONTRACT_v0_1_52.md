# BASIC# Small Compiler Subset Error Contract v0.1.63

**Build:** v0.1.63  
**Status:** `plain_english_error_contract_under_ruby_referee`  
**Spec:** `spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_ERROR_CONTRACT_v1.json`  
**Parent self-hosting spec:** `spec/self_hosting/BASIC_SHARP_SELF_HOSTING_SUBSET_v1.json`

v0.1.63 adds the plain-English error contract for the small compiler subset. The contract gives invalid subset examples stable error IDs, source line numbers, severity, creator-facing explanations, and the underlying Ruby-referee diagnostic that produced each result.

## Implementation

- `compiler/small_compiler_subset_error_contract.rb`
- `spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_ERROR_CONTRACT_v1.json`
- `tools/small_compiler_subset_error_contract.rb`
- `tests/test_small_compiler_subset_error_contract.rb`

## Why this matters

Self-hosting cannot move forward if bad BASIC# fails with cryptic compiler noise. This build makes the next bridge safer by locking the shape and wording of common invalid subset errors before the subset is allowed to carry more work.

## Guardrails

This is not the production compiler path. It does not replace `compiler/parser.rb`, `compiler/resolver.rb`, the Ruby bootstrap compiler, or the v0.1.51 IR golden parity harness.

No Profile 8 is added. No creator-facing syntax changes. No valid-program runtime meaning changes. No BSharp Bytecode changes. No Save, ASK, input-device, web export, browser, engine bridge, or Ruby retirement work is allowed in this build.

## Acceptance

v0.1.63 is accepted only when:

1. Every invalid fixture matches its locked stable error IDs, line numbers, severities, plain messages, source messages, and digest.
2. Valid small compiler subset IR golden parity from v0.1.51 still passes.
3. The new error contract tool passes inside the Trial-by-Fire validation inventory.
4. Existing Profiles 1 through 7, BSharp Bytecode profiles, runtime transition, movement/input, tokenizer/reader, parser, IR emitter, and IR parity validations remain green.
5. Derek commits the exact accepted tree and tags `v0.1.63`.

After v0.1.63 is accepted, the next likely self-hosting build is controlled subset expansion or the bytecode-emission lane, still under Ruby referee control.


## Five Point relationship

This error contract serves the Five Point Paradigm by protecting the Radical Human Bridge and Proof Under Fire points. A language for non-programmers cannot let invalid creator text fall into cryptic compiler output. Bad input must fail clearly, consistently, and with evidence.
