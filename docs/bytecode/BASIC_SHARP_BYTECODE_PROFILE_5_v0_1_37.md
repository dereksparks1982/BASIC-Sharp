# BSharp Bytecode Profile 5 v0.1.37

Profile identity is `bsharp.bytecode.v5`; required meaning is `bsharp.meaning.v5`; fingerprint algorithm is `sha256-bsir-meaning-v5`; header profile-format version is 5.

New action opcodes:

- `0x27 INCREASE_VALUE selector reference value_name amount`
- `0x28 DECREASE_VALUE selector reference value_name amount`

New condition opcodes:

- `0x35 VALUE_AT_LEAST subject value_name amount`
- `0x36 VALUE_MORE_THAN subject value_name amount`
- `0x37 VALUE_AT_MOST subject value_name amount`
- `0x38 VALUE_LESS_THAN subject value_name amount`

Profile 5 retains the Profile 4 section layout and all earlier instructions. The loader rejects new opcodes in earlier profiles and exposes no partial model after rejection. The BSharp VM executes Profile 5 directly without reconstructing BSIR or calling the reference runtime.
