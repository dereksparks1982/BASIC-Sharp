# BASIC# v0.1.82 Native Semantic Routing Integration

v0.1.82 is Self-Hosting Milestone 2, Slice 9. The independent semantic resolver now asks a checked-in BASIC#-authored BSBC component which accepted semantic family each AST entry belongs to before the resolver performs the corresponding bounded semantic work.

The Ruby host derives only a neutral semantic input name from the AST class name. It does not keep a second semantic-family-to-route answer table and does not silently repair a missing or wrong native decision. Route shape is validated after the BASIC# decision. A wrong-route sabotage must therefore fail visibly.

Accepted routed families are Kind definitions, Thing definitions, starting facts, WHEN event rules, IF/OTHERWISE rules, CONTROLS declarations, HOVER declarations, and CONTEXT declarations.

The v0.1.81 native parser dispatch remains active upstream. Ruby remains bootstrap and referee authority; this is bounded compiler self-hosting progress, not full self-hosting and not Ruby retirement.

The semantic router source is `compiler/native/first_bsharp_semantic_router.bsharp`; its persisted artifacts are `first_bsharp_semantic_router.bsbc` and `.bsbc.txt`. The integration contract is `spec/self_hosting/BASIC_SHARP_NATIVE_SEMANTIC_ROUTING_INTEGRATION_v1.json`.

Canonical self-hosting contract: `spec/self_hosting/BASIC_SHARP_SELF_HOSTING_SUBSET_v1.json`.
