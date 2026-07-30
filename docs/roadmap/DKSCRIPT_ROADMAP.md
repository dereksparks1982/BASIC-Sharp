# BASIC# / DKScript Bootstrap Roadmap

## Current position

```text
BASIC# source
-> DKScript Ruby bootstrap reader and parser
-> meaning resolver
-> DKIR
-> first runtime execution
-> runtime Trigger context
-> BASIC# identity and beginner-first foundation
-> plain-language runtime trace  [CURRENT: v0.1.12]
-> focused runtime stress test
-> repair anything exposed
-> Kind Families
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
- User-defined direct Kinds.
- Plain-language diagnostics and duplicate-diagnostic cleanup.
- DKIR debug JSON emission.
- First runtime Thing creation and START Fact application.
- One-pass IF checking.
- Exact one-event WHEN matching.
- First executable official words: `(damage`, `(change`, `(carry`, `(unlock`.
- Named Thing matching for `a guard` and other direct Kinds.
- Per-event context for `that guard`.
- Plain unknown-Thing and wrong-Kind runtime errors.
- Public language name recorded as BASIC#.
- Owner doctrine recorded: “A script language made for non-programmers, by non-programmers.”
- Historical BASIC research and outside Grok and Copilot reviews logged.
- Plain-language runtime trace for matches, selected Things, official words, and immediate changes.

## Immediate next work

### v0.1.13 Focused Runtime Stress Test

The stress test should pressure only working features:

- hundreds of defined Things;
- many Things of the same Kind;
- exact and Kind-based Triggers together;
- thousands of repeated event runs;
- repeated `(damage` and `(change`;
- `(carry` relation changes;
- unknown Things and wrong Kinds;
- source and saved-DKIR parity;
- no state leaking between separate runtime sessions;
- deterministic results from identical worlds and events;
- plain trace correctness under repeated execution.

The stress package should add tests and reports, not new syntax.

If the stress test exposes a defect, the next version repairs that defect before Kind Families.

## Kind Families after stress testing

```text
KINDS
[creature is a thing
dragon is a creature
wyrm is a dragon].
```

The creator should understand the family without being taught inheritance terminology.

Required behavior:

- one clear parent per Kind;
- direct and family lookup;
- plain unknown-parent explanation;
- plain circular-family explanation;
- source and DKIR parity.

## Later runtime lanes

- Multiple selected Things.
- More complete state and relation handling.
- Expanded IF behavior.
- Multiple matching rules and event ordering.
- Event queue and repeated event processing.
- Values and amounts.
- Timing and repetition.
- Groups and collections.
- Runtime save and load.
- ASK-style introspection.
- Understandable runtime recovery.
- Bytecode and BASIC# VM.
- DK Engine bridge.
- Small complete proof game.
- BASIC# compiler written in BASIC#.

## Pre-bytecode protection

Before bytecode and the VM, BASIC# needs a stable meaning specification covering:

- Head and Body behavior;
- Kind and Thing behavior;
- Trigger selection;
- Connector behavior;
- official word behavior;
- DKIR meaning.

This must protect the working language, not trigger a giant rewrite.

## Locked protections after v0.1.12

- No duplicate natural-language and traditional-syntax versions.
- No creator-facing compiler jargon.
- No hidden Ruby semantics becoming BASIC# law.
- No new official words without owner approval.
- No technical rename without a separate migration.
- No feature is complete until the creator can understand what happened.
