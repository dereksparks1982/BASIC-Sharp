# BASIC# v0.0.85 candidate: Event Interpretation and Reference Binding

Status: UNACCEPTED source-only development on GitHub main.
Accepted release: v0.0.84, preserved.
GitHub base: 708b2d5bdf51fb514f37d89cdb010dd0c1406ad1.
Rollback: Revert this candidate commit to that prior GitHub base.
Validation: NOT RUN. No compilation, tests, binaries, local installation,
GitHub Actions, or release tag creation.

## Objective

Move a bounded set of event interpretation and reference-binding decisions
into the Ruby-independent experimental source-to-BSIR and browser runtime
path, while preserving BASIC# creator-facing grammar.

## New candidate behavior

1. WHEN PLAYER attacks a #creature and bare #Kind event matchers can match
   any defined Thing whose Kind is a member or descendant of that Kind.
2. Inside a WHEN Body, "it" means the one established named Thing, or the
   selected Kind-pattern Thing if there is no explicitly named Thing.
   Ambiguous or unbound "it" is an error, not a guess.
3. Event-bound "it" uses a BSIR "previous" reference with kind_name,
   selected during event execution. No new creator syntax is required.
4. Exact named Thing matches take precedence over general Kind rules.
   Within Kind rules, the nearest Kind ancestor wins; equal-distance
   rules retain their original source order.
5. The browser console lets a user type an event such as
   PLAYER attacks @goblin. The sandbox finds the matching WHEN rule,
   selects the target, runs supported actions and settles IF rules.
6. Available-event buttons expand the selected rules across known Things
   and remove shadowed duplicate entries. The event button list is
   capped at 120, but typed event entry remains available.
7. Added a two-creature example demonstrating Kind inheritance and "it".
   Compiler and browser regression definitions were added but not run.
8. Unknown Things, unsupported selectors, ambiguity and unmatched events
   are rejected rather than quietly accepted.

## Scope boundaries

No every #Kind set actions, chained (cause events, generalized arbitrary
selectors, fuzzy parsing, movement, CONTROLS, HOVER, CONTEXT, save migration,
graphics, full BSIR parity, independent browser BSBC emitter or BSharp VM.
The browser continues to interpret only a limited IR subset in JavaScript.
The production Ruby bootstrap compiler and referee remain in place.
Creator-facing syntax and meaning Profiles 1-7 have not changed.

## Changed code

compiler/portable/bsharp_compiler.mjs
compiler/portable/bsharp_sandbox.mjs
site/console.js
site/console.css
index.html
tests/portable_bsharp_compiler.test.mjs
tests/portable_bsharp_sandbox.test.mjs

The roadmap, master handoff, documentation map, console notes, and sealed
file inventory are updated to reflect this source-only candidate.

## Next development boundary

Continue reference selector and caused-event behavior or implement the
independent BSBC bytecode path. Do not claim Ruby retirement, self-hosting,
full correctness or release acceptance without owner-authorized testing.
