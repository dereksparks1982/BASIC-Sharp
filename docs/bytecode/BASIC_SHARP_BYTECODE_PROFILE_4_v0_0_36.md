# BSharp Bytecode Profile 4 v0.0.36

Profile `bsharp.bytecode.v4` requires `bsharp.meaning.v4`, profile format version `4`, and fingerprint algorithm `sha256-bsir-meaning-v4`.

The binary keeps the Profile 3 section order:

```text
STRS META KIND THNG STRT EVNT IFRL CTRL HOVR CTXT CODE
```

Platform instructions remain canonical data inside `CTRL`. This preserves the validated, deeply frozen game-declaration model and does not add Ruby serialization or engine-specific objects. Profile 1 through Profile 3 bytecode layouts and committed artifacts remain unchanged.

An older loader rejects profile format version 4 before exposing a partial model. The Profile 4 loader validates the identity prefix, meaning fingerprint, complete section layout, canonical game data, and all inherited bytecode rules before the BSharp VM or host bridge receives the program.

The canonical contract and fixture ledger are under `spec/bytecode_v4/`.
