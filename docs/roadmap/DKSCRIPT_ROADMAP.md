# DKScript Roadmap

## Current position

```text
DKScript source
-> reader and parser
-> meaning resolver
-> DKIR
-> first runtime execution  [CURRENT: v0.1.09]
-> runtime expansion
-> bytecode / VM decision
-> DK Engine
-> DK Studio
```

## Completed foundation

- Controlled DKScript Body structure using `[` and `].`.
- Heads, Kinds, Things, Facts, Triggers, Connectors, and official words.
- User-defined one-word Kinds.
- Plain-language diagnostics and duplicate-diagnostic cleanup.
- DKIR debug JSON emission.
- First runtime Thing creation and START Fact application.
- One-pass IF checking.
- One-event WHEN matching.
- First executable official words: `(damage`, `(change`, `(carry`, `(unlock`.

## Next runtime lane

The immediate next lane is to make event references survive from the Trigger into the Connector lines, especially phrases such as `that guard`, without adding a second syntax.

## Later lanes

- More complete state and relation handling.
- Event queue and repeated event processing.
- Timing and repetition.
- Runtime save/load.
- Bytecode and VM evaluation.
- DK Engine bridge.
- DK Studio tools.
- Small complete proof game.

## Locked exclusions after v0.1.09

- No return to Godot as the permanent platform.
- No duplicate natural-language and traditional-language syntax.
- No silent rewriting of the creator's source.
- No new official word without an explicit language decision.
