# BASIC# Runtime Contract v0.0.47

v0.0.47 changes no runtime semantics.

Stable Meaning Profiles 1 through 7, BSharp Bytecode Profiles 1 through 7, BSharp Save formats, BSharp ASK behavior, the BSharp VM preferred runtime, and the v0.0.46 input-device meaning layer remain the accepted language/runtime surface.

This build adds the tokenizer/reader contract:

```text
spec/self_hosting/BASIC_SHARP_TOKENIZER_READER_CONTRACT_v1.json
docs/self_hosting/BASIC_SHARP_TOKENIZER_READER_CONTRACT_v0_0_47.md
tools/tokenizer_reader_contract.rb
tests/test_tokenizer_reader_contract.rb
```

The contract freezes deterministic reader records and comment behavior for future self-hosting work while Ruby remains the reader authority.

This build also records the universal-standard and AI-tooling doctrine:

```text
docs/strategy/BASIC_SHARP_UNIVERSAL_STANDARD_AND_AI_TOOLING_DOCTRINE_v0_0_47.md
```

This build adds no Profile 8, no creator-facing syntax, no BSharp IR change, no bytecode change, no Save change, no ASK change, no runtime behavior change, no input-device behavior change, no engine bridge, no web export, no browser work, no licensing work, no funding claim, and no Ruby replacement.
