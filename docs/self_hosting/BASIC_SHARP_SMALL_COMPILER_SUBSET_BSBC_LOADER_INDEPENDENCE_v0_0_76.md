# BASIC# v0.0.76 Small Compiler Subset BSBC Loader Independence

Self-Hosting Milestone 2 Slice 3 gives BSharp Compiler Subset 0 an independent BSBC trust boundary through `SmallCompilerSubsetBSBCLoader`.

The bounded proof path is:

```text
TokenizerReader
-> SmallCompilerSubsetParser
-> SmallCompilerSubsetSemanticResolver
-> BSharp IR
-> SmallCompilerSubsetBSBCEncoder
-> BSharp Bytecode
-> SmallCompilerSubsetBSBCLoader
-> BSharp VM execution engine
```

The subset loader parses and validates Profile 1 through Profile 7 BSBC without requiring, instantiating, calling, or inheriting from the production `BytecodeLoader`. The production Ruby loader remains a separate referee. Valid trusted models, summaries, fingerprints, and disassembly must match exactly.

The loader is a trust boundary, so happy-path parity is not enough. A sealed 16-mutation malformed-artifact campaign covers header identity, unsupported profiles, section geometry, truncation, invalid indexes, invalid instruction/selector/condition codes, operand-width corruption, bad code targets, record-count corruption, and trailing data. The independent loader and production referee must reject every mutation with the same deterministic message.

The execution-parity lane feeds a model validated by `SmallCompilerSubsetBSBCLoader` into the unchanged BSharp VM execution implementation through a bootstrap-only adapter. Runtime event results, final snapshots, and BSharp Save documents remain under Ruby referee parity.

This is not the production compiler path, not full self-hosting, and not Ruby retirement. Normal BASIC# production bytecode loading remains unchanged.

Canonical contracts:

```text
spec/self_hosting/BASIC_SHARP_SELF_HOSTING_SUBSET_v1.json
spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_BSBC_LOADER_INDEPENDENCE_v1.json
spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_BSBC_EXECUTION_PARITY_v1.json
```
