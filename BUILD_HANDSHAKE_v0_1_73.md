# BASIC# v0.1.73 Build Handshake

Project: BASIC# Ruby Bootstrap Compiler
Version: v0.1.73 Plain-English Object Interaction Actions
Required base: v0.1.72
Required base commit: `db1776050d74bf3f6110986fe0a52a78e103bb43`
Required base tag: `v0.1.72`
Package: `BASIC_Sharp_Ruby_Bootstrap_Compiler_v0_1_73_PLAIN_ENGLISH_OBJECT_INTERACTION_ACTIONS_HANDOFF_CONTRACT_REFERENCE_REPAIR_CHANGED_FILES_ONLY.zip`

## Completed changes

- `(open target` canonicalizes to the proven state-change primitive with state `open`.
- `(close target` canonicalizes to the proven state-change primitive with state `closed`.
- `(lock target` canonicalizes to the proven state-change primitive with state `locked`.
- `(take target` canonicalizes to the proven carry primitive.
- Existing exact-object, `it`, and `every #Kind` selector meaning is preserved.
- CONTEXT interactions can use the new creator-facing words.
- No Profile 8 and no bytecode-format change are introduced.

## Validation floor

- 75 discovered test files.
- 583 runs / 9,320 assertions / 0 failures / 0 errors / 0 skips.
- Full normal and no-locale suites are required in the installer.
- Required stress/tool validation and Trial by Fire full native counts remain required before FINAL PASS.

## Rollback

Reset exactly to accepted `v0.1.72` at `db1776050d74bf3f6110986fe0a52a78e103bb43` before applying a repaired candidate after any failed post-mutation validation.

## Closeout order

FINAL PASS -> accepted snapshot -> local Git commit/tag -> GitHub push/verify -> next build.

## Same-version handoff contract reference repair

- Preserves the v0.1.73 object-interaction implementation unchanged.
- Repairs the master handoff so the existing self-hosting, tokenizer/reader, subset parser, IR emitter, IR parity, error-contract, and scene/block-expansion validators can verify their required literal spec paths.
- Regenerates the dependent validation inventory, release preflight, and patch-manifest byte/hash records.
- Full native validation remains mandatory before acceptance.
