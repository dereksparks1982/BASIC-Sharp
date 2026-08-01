# BSharp Bytecode Profile 6 v0.1.38

Profile identity is `bsharp.bytecode.v6`, requiring `bsharp.meaning.v6` and profile-format header value 6. It retains the Profile 5 container and adds two condition opcodes:

| Opcode | Code | Operand | Meaning |
|---|---:|---|---|
| `ALL_CONDITIONS` | `0x39` | `clause_count` | every following atomic clause must be true |
| `ANY_CONDITIONS` | `0x3A` | `clause_count` | at least one following atomic clause must be true |

An IFRL group record is followed by exactly `clause_count` existing atomic condition records, then the action block and source-order fields. A group must contain at least two clauses. Nested group opcodes are rejected. The loader validates the full group before exposing its deeply frozen model; the VM executes it directly without rebuilding BSIR or calling the reference runtime.
