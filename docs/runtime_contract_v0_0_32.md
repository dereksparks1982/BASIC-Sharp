# BASIC# Runtime Contract v0.0.32

This contract extends the accepted v0.0.31 runtime contract only for creator-facing text values.

- The BSharp VM remains the preferred runtime for source, BSIR, and BSBC.
- The Ruby runtime remains the reference oracle and explicit diagnostic path.
- Programs without text retain Meaning/Bytecode Profile 1 behavior.
- Text programs require Meaning/Bytecode Profile 2.
- START, CHANGE, IF, Save, ASK, restore, shadow parity, event order, selection order, atomicity, IF rearming/cascades, and loop bounds operate consistently for typed text.
- Literal text is exact; identifier normalization never reaches it.
- A named value slot is not allowed to alternate between whole-number and text schema.
- Unsupported text syntax or malformed artifacts are rejected deterministically.
- Shadow verification stops on any result, world, ASK, Save, restore, or replay disagreement.

The exact fixture authority is `spec/runtime_v2/BASIC_SHARP_TEXT_VALUE_RUNTIME_FIXTURES_v1.json`.
