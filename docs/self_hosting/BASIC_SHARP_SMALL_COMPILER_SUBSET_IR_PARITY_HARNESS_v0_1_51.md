# BASIC# Small Compiler Subset IR Golden Parity Harness v0.1.63

**Build:** v0.1.63  
**Status:** `ir_golden_parity_under_ruby_referee`  
**Spec:** `spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_IR_PARITY_HARNESS_v1.json`

v0.1.63 adds the first golden BSharp IR parity harness for the small compiler subset. The harness computes deterministic SHA256 digests from normalized BSharp IR emitted by `compiler/small_compiler_subset_ir_emitter.rb` and compares those digests against the Ruby Parser plus SemanticResolver referee.

## Implementation

- `compiler/small_compiler_subset_ir_parity_harness.rb`
- `tools/small_compiler_subset_ir_parity_harness.rb`
- `tests/test_small_compiler_subset_ir_parity_harness.rb`
- `spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_IR_PARITY_HARNESS_v1.json`

## Guardrails

This is not the production compiler path. It does not replace `compiler/parser.rb`, `compiler/resolver.rb`, or the Ruby bootstrap compiler. It does not route normal BASIC# compilation through the parity harness.

No Profile 8 is added. No creator-facing syntax changes. No runtime, BSharp Bytecode, Save, ASK, input-device, web export, browser, engine bridge, or Ruby retirement work is allowed in this build.

## Acceptance

v0.1.63 is accepted only when:

1. The parity harness tool passes inside the Trial-by-Fire validation inventory.
2. Every sealed fixture produces the locked golden BSharp IR SHA256 digest.
3. Every subset-emitted BSharp IR digest matches the Ruby Parser plus SemanticResolver referee digest.
4. Existing Profiles 1 through 7, BSharp Bytecode profiles, runtime transition, movement/input, tokenizer/reader, parser, and IR emitter validations remain green.
5. Derek commits the exact accepted tree and tags `v0.1.63`.

After v0.1.63 is accepted, the next likely self-hosting build is the small compiler subset emits BSBC bytecode lane, still under Ruby referee control.


Self-hosting umbrella spec: `spec/self_hosting/BASIC_SHARP_SELF_HOSTING_SUBSET_v1.json`.

## v0.1.63 continuation

The IR golden parity lane is the required valid-program guard for `spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_ERROR_CONTRACT_v1.json`. The v0.1.63 error contract locks invalid-program diagnostics while this v0.1.51 parity harness continues to protect valid small-subset BSharp IR output.
