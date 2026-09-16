# BASIC# Parser Contract v0.0.16

## Grammar status

v0.0.16 changes no creator-facing grammar.

The supported Kind declaration remains:

```text
KINDS
[dragon is a creature].
```

## Kind rules

- A Kind has one direct parent.
- The parent must already be known in source order.
- A second parent is rejected.
- A circular family is rejected with the loop path.
- Family lookup is cached inside the dictionary.
- Adding a parent clears that cache so later selectors see the new family truth.

## Matching meaning carried forward

- A Thing belongs to its direct Kind and every stored ancestor.
- Exact named Things remain distinct from Kind selectors.
- `a Kind`, `the Kind`, and `that Kind` keep their existing meanings.
- No multiple inheritance is accepted.

## Unchanged structure

- A Head begins a statement.
- `[` opens the Body and touches its first word.
- `].` ends the Body.
- `<then>` is a Connector.
- `(damage` and the other approved official words keep their visible action marker.
