# BASIC# Runtime Contract v0.0.48

v0.0.48 changes no runtime semantics.

The build adds a tokenizer/reader implementation under Ruby referee supervision, but the accepted runtime, BSharp IR, BSharp Bytecode, Save format, ASK behavior, input devices, movement meaning, and VM behavior remain unchanged from v0.0.47 except for live version identity.

## Active self-hosting records

```text
spec/self_hosting/BASIC_SHARP_SELF_HOSTING_SUBSET_v1.json
spec/self_hosting/BASIC_SHARP_TOKENIZER_READER_CONTRACT_v1.json
docs/self_hosting/BASIC_SHARP_TOKENIZER_READER_CONTRACT_v0_0_47.md
docs/self_hosting/BASIC_SHARP_TOKENIZER_READER_IMPLEMENTATION_v0_0_48.md
compiler/tokenizer_reader.rb
```

Ruby remains the production parser and reference referee. v0.0.48 does not route compiler parsing through the new tokenizer/reader implementation.
