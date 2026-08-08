# BASIC# Small Compiler Subset IR Emitter v0.1.55

**Build:** v0.1.55  
**Lane:** Small Compiler Subset Emits BSharp IR Under Ruby Referee  
**Status:** Non-production self-hosting runway work

## Purpose

v0.1.55 adds the first small compiler subset BSharp IR emitter. It takes output from `compiler/small_compiler_subset_parser.rb`, builds a controlled compiler-subset program, emits resolved BSharp IR, and compares that IR against the existing Ruby Parser plus SemanticResolver referee.

This is a self-hosting bridge step, not the production compiler path, and not a production compiler replacement.

## Added implementation

```text
compiler/small_compiler_subset_ir_emitter.rb
```

The emitter records:

```text
format: bsharp.small_compiler_subset.ir_emitter.record
version: live BASIC# version
status: ir_emitter_under_ruby_referee
parser_ruby_referee_matches: true/false
ruby_referee_matches: true/false
bsharp_ir: resolved BSharp IR document
```

## Ruby referee rule

Ruby remains the production parser, production resolver, production compiler path, and referee in v0.1.55.

The new emitter must prove that its subset-emitted BSharp IR matches the existing Ruby Parser plus SemanticResolver output for approved fixtures before later self-hosting work may trust it.

## What this build does not do

- It does not replace `compiler/parser.rb`.
- It does not route normal BASIC# compilation through the subset IR emitter.
- It does not claim BASIC# is self-hosted.
- No Profile 8 is added.
- It does not add Profile 8.
- It does not add new creator-facing syntax.
- It does not change runtime behavior.
- It does not change BSharp Bytecode.
- It does not change Save, ASK, input-device behavior, graphics, engine bridge, web export, browser work, or Ruby retirement.

## Governing contracts

```text
spec/self_hosting/BASIC_SHARP_SELF_HOSTING_SUBSET_v1.json
spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_IR_EMITTER_v1.json
```

## Validation

v0.1.55 is accepted only when:

1. `tests/test_small_compiler_subset_ir_emitter.rb` passes.
2. `tools/small_compiler_subset_ir_emitter.rb` passes.
3. The Trial-by-Fire validation inventory includes and seals the new test, tool, spec, and document.
4. The full native validation suite passes on Derek's machine.
5. Derek commits the exact accepted tree and tags `v0.1.55`.

## Next runway step

After v0.1.55 is accepted, the next likely self-hosting build is the small compiler subset emits BSBC bytecode lane, still under Ruby referee control.


## v0.1.55 continuation

The IR emitter lane is the required input for the next self-hosting bridge record: `spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_IR_PARITY_HARNESS_v1.json`. The v0.1.55 parity harness may compute locked golden BSharp IR digests from emitter records, but the emitter remains non-production and Ruby remains the referee.
