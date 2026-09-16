# BASIC# Small Compiler Subset Semantic Resolver v0.0.74

## Status

Self-Hosting Milestone 2, Slice 1. The BSharp Compiler Subset 0 path now owns a separate semantic resolver implementation under Ruby referee control.

## What changed

`compiler/small_compiler_subset_semantic_resolver.rb` resolves the subset parser's AST into canonical BSharp IR without calling or requiring the production `SemanticResolver` implementation.

`compiler/small_compiler_subset_ir_emitter.rb` now uses `SmallCompilerSubsetSemanticResolver` for its primary document. The existing Ruby `Parser` plus `SemanticResolver` path remains separate and is used only as the referee comparison.

The accepted boundary is:

`TokenizerReader -> SmallCompilerSubsetParser -> SmallCompilerSubsetSemanticResolver -> BSharp IR -> subset BSBC -> BSharp VM`

The production Ruby compiler remains the bootstrap compiler and reference referee. This is not full self-hosting and it does not retire Ruby.

## v0.0.73 object interaction proof

The v0.0.74 semantic-resolver lane explicitly carries the accepted `(open`, `(close`, `(lock`, and `(take` actions through the independent resolver and requires exact parity with the Ruby referee. Those actions continue to canonicalize to the existing state-change and carry primitives.

## Guardrails

- No Profile 8.
- No new creator-facing syntax.
- No production compiler routing change.
- No runtime meaning, BSBC format, Save, ASK, input-device, graphics, browser, or web-export change.
- Ruby remains bootstrap compiler and referee authority for this milestone slice.

## Canonical foundation

`spec/self_hosting/BASIC_SHARP_SELF_HOSTING_SUBSET_v1.json` remains the canonical self-hosting foundation contract. Ruby remains the bootstrap compiler and referee authority.
