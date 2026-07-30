# BASIC# Bootstrap Roadmap

## Current position

```text
BASIC# source
-> Ruby bootstrap parser and resolver
-> DKIR debug document
-> first runtime execution
-> runtime Trigger context
-> plain-language runtime trace
-> focused runtime stress and DKIR contract
-> technical identity migration and Company Bible integration
-> inherited Kind matching  [CURRENT CANDIDATE: v0.1.15]
-> owner validation and acceptance
-> Kind-family stress and hardening
-> runtime expansion
-> stable meaning specification
-> bytecode
-> BASIC# VM
-> DK Engine bridge
-> DK Engine
-> BASIC# self-hosting compiler
```

## Completed foundation

- Controlled Body structure using `[` and `].`.
- Heads, Kinds, Things, Facts, Triggers, Connectors, and official words.
- User-defined direct Kinds and stored direct parent relationships.
- Plain-language diagnostics and duplicate-diagnostic cleanup.
- DKIR debug JSON emission.
- First runtime Thing creation and START Fact application.
- One-pass startup IF checking.
- Exact one-event WHEN matching.
- Executable official words: `(damage`, `(change`, `(carry`, `(unlock`.
- Named Thing matching for `a guard` and other Kinds.
- Per-event context for `that guard` and inherited `that Kind` references.
- Plain unknown-Thing and wrong-Kind runtime errors.
- BASIC# public and technical identity.
- Complete Company Bible integration.
- Formal DKIR meaning contracts.
- Focused runtime stress runner and automated stress suite.
- Duplicate Thing and invalid DKIR-format protection.
- Direct, parent, grandparent, and root inherited Kind matching.
- Exact Trigger priority and nearest compatible Kind priority.
- Unknown-parent and circular-family protection.

## Immediate next build after v0.1.15 acceptance

### Kind-Family Stress and Hardening

The next build should attack the new inheritance machinery rather than immediately stacking another feature on top of it.

Likely focus:

- deep but bounded parent chains;
- many overlapping ancestor Triggers;
- direct-versus-parent-versus-root priority under load;
- duplicate and malformed Kind entries in saved DKIR;
- deterministic source-order tie behavior;
- many descendant Things selected repeatedly;
- performance measurements for family walking;
- plain explanations remaining stable under failure;
- no unrelated language expansion.

The exact build still requires a full proposal and Derek's explicit approval.

## Near-term lane

1. Kind-family stress and hardening.
2. More complete IF behavior.
3. Multiple selected Things.
4. Formal values and amounts.
5. Event ordering and queue design.
6. Save/load world state.
7. ASK-style introspection.
8. Runtime recovery.
9. Stable meaning specification gate.

## Protected design rules

- BASIC# is made for non-programmers, by non-programmers.
- The compiler and engine do the heavy lifting.
- `[` touches the first Body word.
- `(damage` is the official word.
- `(` is a creator-facing visual guide.
- `<then>` is a Connector, not the result.
- `then` and `than` are identical.
- `there` and `their` are identical where already supported.
- Ruby is scaffolding, not BASIC# syntax or meaning.
- No new official word enters casually.
- One Kind has one direct parent until Derek explicitly approves otherwise.
