# BASIC# Changelog v0.1.74

## Self-Hosting Milestone 2 Slice 1: Semantic Resolver Independence

BSharp Compiler Subset 0 now owns an independent `SmallCompilerSubsetSemanticResolver` for its primary semantic-resolution path. `SmallCompilerSubsetIREmitter` consumes that independent result, while the production Ruby `SemanticResolver` remains a separate referee used only to prove exact parity.

The self-hosting execution corpus expands to 18 fixtures and 56 events, including a dedicated object-interaction case that carries the accepted v0.1.73 open, close, lock, and take actions through independent semantic resolution, BSBC emission, loading, BSharp VM execution, and Ruby-referee comparison.

Ruby remains the bootstrap compiler. No Profile 8, normal production compiler routing change, bytecode-format change, or runtime-meaning change is introduced.
