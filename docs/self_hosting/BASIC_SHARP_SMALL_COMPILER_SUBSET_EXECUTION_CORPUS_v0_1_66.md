# BASIC# Small Compiler Subset Execution Corpus v0.1.66

v0.1.66 expands the BSBC execution parity lane from a smaller proof set into a sealed execution corpus.

The corpus proves that approved BASIC# subset programs can move through this chain:

```text
BASIC# source
-> BSharp IR
-> BSBC bytecode
-> BSharp Virtual Machine execution
-> Ruby referee runtime parity
```

This remains a referee-controlled milestone. Ruby is not retired, BASIC# is not fully self-hosted, Profile 8 is not added, and the DKLab compatibility bridge is not removed.

The corpus gate requires at least 17 fixtures, at least 12 categories, and at least 50 event executions across the sealed fixtures. It is intentionally tied to existing release gates so a larger corpus cannot ship with stale deterministic hashes or an unaudited package manifest.
