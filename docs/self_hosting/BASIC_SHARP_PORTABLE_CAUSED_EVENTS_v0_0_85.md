# BASIC# v0.0.85 source-only candidate: Kind Sets and Caused Events

Status: unaccepted source-only development, direct on GitHub main.
Accepted release/tag: v0.0.84, unchanged.
GitHub base: 8d3aa3f03537cb6e71ea4b09d5956054c524e0e2.
Rollback: revert this development commit to the listed GitHub base.
Validation: no compilation, no executed tests, no GitHub Actions, no installer.

## Purpose

Extend the existing experimental browser source-to-BSIR compilation and
interpreter path with two established BASIC# concepts. The creator-facing
language and meaning Profiles 1 through 7 are unchanged.

## Mass selection

- The official action-only reference every #Kind resolves to a kind_set
  reference in BSIR, with kind_name and deterministic defined candidates.
- The browser applies each supported action in defined Thing order, matching
  the named Kind and its inherited descendants. An empty set changes nothing
  and is logged; the sandbox caps one mass action at 512 selected Things.
- Generic a #Kind remains a WHEN event matcher, not an unbound action target.
  every #Kind is not accepted as a WHEN pattern, IF condition or START subject.
- Unknown Kinds fail at source compilation.

## Caused events

- The official (cause event form generates a structured cause action with a
  BSIR event. Its actor and target must resolve to one named Thing or one
  existing event binding (it). No unbound kind or mass selection is guessed.
- The browser stages each caused event in FIFO order after initiating actions
  and IF settlement. Follow-up events use the established WHEN matcher,
  including named-rule precedence and inherited Kind matching.
- One follow-up can cause another, including event-bound "it" references.
  Missing WHEN rules cause a visible no-match log, not invented behavior.
- A chain is limited to 64 processed follow-up events. On overflow the sandbox
  throws an error and clears remaining queued events rather than recursing
  indefinitely.
- IF rules can stage caused events during START and event settlement.
- The browser does not use eval or execute user-created JavaScript.

## Console and future regression definitions

A new "Alarm and chained events" example describes one bell event changing
every guard and causing a guard to open a gate, which causes a second guard
to attack PLAYER. Additional tests describe set selection, chain order,
event-bound actors, unmatched follow-ups, and self-triggering chain limits.
These test definitions have NOT BEEN EXECUTED.

## Remaining boundaries

This is not full language parity. The experimental interpreter lacks complete
selectors, generalized context-sensitive event matching, movement, CONTROLS,
HOVER, CONTEXT, world saves, independent BSBC emission/loading/VM execution
and the complete Ruby replacement. The accepted Ruby compiler, binary
artifacts, runtime, release tag and production code were not altered.

Next roadmap work: begin a native, Ruby-independent BSBC emission/loader
path only against the documented bytecode contract, preserving all source
grammar and refusing unsupported features. Full validation remains deferred
until the owner authorizes compiling and testing.
