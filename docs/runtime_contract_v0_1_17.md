# BASIC# Runtime Contract v0.1.17

## Reactive IF lifecycle

Each runtime owns one active-state bit per IF rule.

A rule wakes only when:

```text
condition was false
condition is now true
```

A rule that remains true stays active and does not run after every unrelated event.

When the condition becomes false, the rule re-arms. It may wake again on a later false-to-true transition.

## Execution order

1. Validate BSharp IR.
2. Load Kind families.
3. Create Things.
4. Apply all START facts.
5. Settle IF rules.
6. Match one WHEN rule for an event.
7. Run the complete WHEN action list.
8. Settle IF rules.
9. Return trace and world state.

No IF check occurs halfway through a multi-action WHEN body or halfway through one IF action list.

## Settling order

- IF rules are checked in creator source order.
- A later rule may make an earlier rule true.
- The earlier rule runs on the next controlled pass.
- Settling continues until no rule wakes or loop protection stops the cycle.

## Loop protection

The runtime records deterministic world and IF-active signatures after firings.

It stops when:

- a prior signature repeats; or
- firings reach `max(256, IF rule count * 8)`.

The runtime returns a plain explanation beginning:

```text
IF rules kept waking each other.
```

No Ruby stack trace is exposed. The current world remains visible. The cycle is not transactionally rolled back.

## Trace shape

Startup traces are available through:

```text
startup_if_rules
startup_if_error
startup_ran
```

Event results include:

```text
if_rules
error
state
```

Each fired IF trace records:

```text
condition
reason
steps
```

## Compatibility

Valid saved BSharp IR fixtures from v0.1.13, v0.1.15, and v0.1.16 remain executable.
