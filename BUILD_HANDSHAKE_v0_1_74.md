# BASIC# v0.1.74 Build Handshake

Project: BASIC# Ruby Bootstrap Compiler
Version: v0.1.74 Self-Hosting Milestone 2 Slice 1: Semantic Resolver Independence
Required base: v0.1.73
Required base commit: `f41d70a59f26def52ebb253ea1ad8f20c6e8bc0b`
Required base tag: `v0.1.73`
Package: `BASIC_Sharp_Ruby_Bootstrap_Compiler_v0_1_74_SELF_HOSTING_MILESTONE_2_SEMANTIC_RESOLVER_INDEPENDENCE_CHANGED_FILES_ONLY.zip`

## Completed changes

- Added `SmallCompilerSubsetSemanticResolver` as the primary semantic stage for BSharp Compiler Subset 0.
- The subset IR emitter no longer obtains its primary document from the production `SemanticResolver`.
- The production Ruby `SemanticResolver` remains a separate referee for exact parity comparison.
- The independent resolver source neither requires `compiler/resolver.rb` nor calls `SemanticResolver.new`.
- Exact BSharp IR parity remains required before subset output can advance to BSBC and BSharp VM execution.
- The self-hosting execution corpus expands to 18 fixtures and 56 events.
- A dedicated v0.1.73 object-interaction fixture proves open, close, lock, and take survive the independent semantic path.
- Ruby remains the bootstrap compiler. This build is not full self-hosting and does not add Profile 8.

## Validation floor

- 76 discovered test files.
- 592 runs / 9,382 assertions / 0 failures / 0 errors / 0 skips.
- Full normal and no-locale suites are required in the installer.
- The independent semantic-resolver gate, all required stress/tool validation, deterministic fixture sweep, release gates, and full Trial by Fire remain mandatory before FINAL PASS.

## Rollback

Reset exactly to accepted `v0.1.73` at `f41d70a59f26def52ebb253ea1ad8f20c6e8bc0b` before applying a repaired candidate after any failed post-mutation validation.

## Closeout order

FINAL PASS -> accepted snapshot -> local Git commit/tag -> GitHub push/peeled-tag verification -> next build.
