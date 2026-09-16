# BASIC# Runtime Contract v0.0.21

## Event execution order

For one externally supplied event, the runtime uses this fixed order:

```text
1. Match one WHEN rule.
2. Complete its full action list in source order.
3. Settle all reactive IF rules.
4. Run the first follow-up event.
5. Settle IF rules again.
6. Continue until no follow-up events remain.
```

## First-created, first-run rule

Follow-up events run in the order they are created. Events created by a follow-up event are appended after events already waiting.

Direct WHEN-body causes are staged before IF-caused events. No follow-up event runs until IF settlement finishes.

## Explicit event creation

Only `(cause` creates a follow-up event. Damage, change, carry, unlock, values, states, and relationships do not generate hidden events.

## Context

A `that Kind` reference is resolved into a concrete Thing name when the cause action runs. The later event does not carry a loose previous-reference pointer.

Each event performs a fresh WHEN match and establishes a fresh context.

## Failure behavior

- A staged event is discarded if a later action in the same body fails.
- Direct and IF-caused events are discarded if IF settlement fails.
- Completed world changes before the error retain their existing accepted behavior.
- A follow-up event that matches no WHEN rule is nonfatal and later waiting events continue.
- A runtime error inside a follow-up event stops later waiting events.

## Loop protection

One external event may execute at most 1,024 follow-up events. Attempting another produces exactly:

```text
Events kept causing more events.

BASIC# stopped this chain after 1,024 follow-up events so it would not run forever.
```

The report shows the final three event names before the stop and bounds the visible event list. Structured results retain all 1,024 executed follow-up events.

## Startup IF behavior

An IF rule that is true after START may explicitly cause an event. That startup event line finishes during runtime construction before an external event is accepted.

## Preserved behavior

Kind inheritance, exact-match priority, nearest-Kind priority, source-order ties, singular context, deterministic set actions, reactive IF wake/re-arm rules, values, amounts, atomicity, source/saved-BSIR parity, and retired-DKIR behavior remain intact.
