# BASIC# Runtime Contract v0.0.19

## Thing values

Every runtime Thing owns a value map. `damage` is built in and begins at 0. Custom values are established through START.

## Damage

- `(damage Thing` adds 1.
- `(damage Thing by N` adds N.
- Damage is cumulative damage received.
- Damage does not automatically change health.
- Overflow above 2,147,483,647 is rejected before mutation.

## Exact value assignment

`(change health of henry to 7` replaces Henry's health with 7. It does not add, subtract, or infer a formula.

Custom values must already exist. For set targets, every selected Thing is checked before anyone changes. Missing values and overflow produce no partial mutation.

## Exact-value IF

`henry has 3 damage` is exact equality. It follows the reactive IF rules already established:

- wake on false to true;
- stay quiet while true;
- re-arm after false;
- finish the full WHEN action list before IF settlement;
- use source order and loop protection.

## Ordering

- Selection follows deterministic object/definition order.
- One action line completes across its full set before the next line.
- Singular `that Kind` context remains singular.
- IF settlement begins after the complete WHEN body.

## Runtime trace

Amount actions report old and new values. Structured results retain value name, old amount, new amount, action amount where applicable, ordered targets, and complete changes. Human output remains bounded for large sets.

## Compatibility

Older valid damage actions with no `amount` mean one. Valid accepted BSharp IR fixtures from v0.0.13, v0.0.15, v0.0.16, v0.0.17, and v0.0.18 remain executable.
