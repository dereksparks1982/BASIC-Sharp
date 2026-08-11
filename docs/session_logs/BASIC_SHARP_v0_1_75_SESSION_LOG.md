# BASIC# v0.1.75 Session Log

Scope approved: Self-Hosting Milestone 2 Slice 2, BSBC Emitter Independence.

Implemented `SmallCompilerSubsetBSBCEncoder` as the primary subset byte-generation stage. The subset BSBC emitter now uses that encoder directly and keeps the production `BytecodeEmitter` on a separate referee path. Added explicit source-independence proof, exact byte parity across the sealed fixtures, and a Profile 7 mixed object-interaction/numeric/IF/OTHERWISE execution-corpus case.

During candidate validation, the complete version-sensitive IR, runtime-smoke, self-hosting-corpus, and deterministic runtime fixture families were regenerated together for v0.1.75 rather than weakening or bypassing their gates. Release workflow remains full validation -> FINAL PASS -> accepted snapshot -> local Git -> GitHub.
