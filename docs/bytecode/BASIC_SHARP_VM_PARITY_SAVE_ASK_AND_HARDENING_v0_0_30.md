# BASIC# v0.0.30 VM Parity, BSharp Save, BSharp ASK, and Hardening

## Purpose

v0.0.30 completes the first hardened Profile 1 bytecode runtime milestone. The BSharp VM continues to interpret the validated BSBC model directly, while gaining the same current-world services already available through the reference runtime.

## Three-path rule

Equivalent program meaning and event sequences must reach the same settled world through:

```text
source -> reference Runtime
saved BSIR -> reference Runtime
validated BSBC -> BSharp VM
```

The bytecode path does not reconstruct BSIR and does not call `BasicSharp::Runtime` to execute instructions.

## BSharp Save through the VM

The VM now exposes the existing BSharp Save contract:

- `world_save_state`
- `write_world_save`
- validated restore during construction
- `restore_world_save!`

A restored VM world:

- verifies the exact `sha256-bsir-meaning-v1` fingerprint;
- validates every Thing, Kind, state, relationship, value, and IF record before mutation;
- does not run START, startup IF rules, or startup follow-up events again;
- restores IF active state;
- becomes immediately save-ready;
- leaves the existing VM untouched when validation fails.

The BSharp Save format and format version remain unchanged.

## BSharp ASK through the VM

`BasicSharp::Ask` now operates against either the reference runtime or the BSharp VM through the same read-only inspection boundary. The VM answers questions about:

- Things and Kinds;
- inherited Kind membership;
- states, values, and relationships;
- which WHEN rule would match;
- actions in the selected rule;
- true and active IF rules;
- world origin and settled state;
- loaded-save identity.

ASK does not run events, mutate the world, or change save readiness.

## CLI combinations

Validated `.bsbc` input may now combine:

```text
--run
--load-world
--save-world
--ask
--ask-json
--against
```

Bytecode disassembly remains separate from mutable VM modes.

## Hardening lane

`tools/bytecode_vm_stress.rb` performs a bounded default run of:

- 10,000 events through source, saved BSIR, and BSBC paths;
- 100 save/restore/replay cycles;
- 128 isolated VM worlds over one loader;
- 256 ASK questions;
- malformed-save recovery;
- startup IF-loop protection;
- 1,024 follow-up-event protection;
- repeated deterministic VM replay;
- performance timing for all three execution paths.

Environment variables may lower counts for focused test runs without changing the default validation contract.

## Compatibility

No BSharp Bytecode binary layout, BSharp Save schema, BSharp ASK schema, Meaning Profile 1 behavior, or creator-facing syntax changes in v0.0.30.
