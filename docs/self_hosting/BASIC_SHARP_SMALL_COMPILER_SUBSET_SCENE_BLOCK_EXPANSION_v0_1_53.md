# BASIC# Small Compiler Subset Scene/Block Expansion v0.1.62

**Build:** v0.1.62  
**Status:** non-production expansion harness under Ruby referee  
**Canonical spec:** `spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_SCENE_BLOCK_EXPANSION_v1.json`

v0.1.62 adds the small compiler subset **scene/block expansion** lane. It validates larger ordered BASIC# scene and block shapes while Ruby remains the production parser, resolver, compiler path, and referee.

The expansion harness is implemented in `compiler/small_compiler_subset_scene_block_expansion.rb` and executed by `tools/small_compiler_subset_scene_block_expansion.rb`.

## What this build proves

- The subset path can read more than a single tiny scene shape.
- Larger ordered blocks can combine `KINDS`, `DEFINE`, `START`, `WHEN`, `IF`, `OTHERWISE`, `CONTROLS`, `HOVER`, and `CONTEXT` fixtures.
- Valid expanded fixtures still match the Ruby Parser plus SemanticResolver referee.
- Valid expanded fixtures lock normalized BSharp IR SHA256 digests.
- Broken expanded block shapes still map to plain-English error records through the v0.1.52 error contract.

## What this build does not do

This is not the production compiler path. It does not replace `compiler/parser.rb`, `compiler/resolver.rb`, the Ruby bootstrap compiler, the v0.1.51 IR golden parity harness, or the v0.1.52 error contract.

No Profile 8, new creator-facing syntax, runtime change, BSharp Bytecode change, web export, browser work, engine bridge, or Ruby retirement is allowed in this build.

## Relationship to the self-hosting bridge

The scene/block expansion lane strengthens the self-hosting bridge by making the small compiler subset carry larger BASIC# shapes under proof. It is still a referee-controlled lane, not a self-hosting claim.

Self-hosting umbrella spec: `spec/self_hosting/BASIC_SHARP_SELF_HOSTING_SUBSET_v1.json`.
