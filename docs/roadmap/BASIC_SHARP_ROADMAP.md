# BASIC# Bootstrap Roadmap

## Current position

```text
BASIC# source
-> Ruby bootstrap parser and resolver
-> DKIR debug document
-> runtime execution
-> Trigger context and plain trace
-> inherited Kind matching
-> Kind-family hardening
-> reactive IF rules and loop protection  [CURRENT CANDIDATE: v0.1.17]
-> owner validation and acceptance
-> multiple selected Things
-> values and amounts
-> event ordering and queue design
-> save/load world state
-> ASK-style introspection
-> stable meaning specification
-> bytecode
-> BASIC# VM
-> DK Engine bridge
-> BASIC# self-hosting compiler
```

## Completed foundation

- Controlled Body structure.
- Kinds, Things, Facts, Triggers, Connectors, and official words.
- DKIR debug JSON.
- START world construction.
- Exact and inherited WHEN matching.
- Per-event `that Kind` context.
- Plain runtime trace and errors.
- BASIC# identity and Company Bible integration.
- Deep Kind-family hardening and stress.
- Reactive IF false-to-true wake-up.
- IF re-arming after false.
- START and event-time IF settling.
- Source-order IF cascades.
- Loop protection with plain explanations.
- Source and saved-DKIR parity.

## Immediate continuation after v0.1.17 acceptance

The next roadmap lane is **Multiple Selected Things** unless the owner changes direction.

The proposal must define:

- how a plural Kind selection is written;
- deterministic selection order;
- whether actions apply to all selected Things or one at a time;
- how `that Kind` behaves with more than one Thing;
- ambiguity and empty-selection explanations;
- source and saved-DKIR meaning;
- stress, rollback, files, exclusions, and package name.

No v0.1.18 implementation begins without the complete proposal and Derek's explicit approval.

## Protected design rules

- BASIC# is made for non-programmers, by non-programmers.
- The compiler and engine do the heavy lifting.
- Ruby remains scaffolding.
- No new official word enters casually.
- One Kind has one direct parent until explicitly changed.
- IF completes rule bodies before another IF check.
- Timing and event queues remain separate future work.
