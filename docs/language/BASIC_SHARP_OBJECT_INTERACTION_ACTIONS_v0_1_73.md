# BASIC# Plain-English Object Interaction Actions v0.1.73

Creator-facing actions:

```text
(open @north gate
(close @north gate
(lock @north gate
(take @brass key
```

Canonical meaning:

- `(open target` -> change target to `open`
- `(close target` -> change target to `closed`
- `(lock target` -> change target to `locked`
- `(take target` -> carry target

These words use existing selector rules. Exact `@object`, established `it`, and `every #Kind` continue to mean what they already meant. Retired selector forms are not restored.

CONTEXT entries may execute the same actions directly, for example `"Open" when it is closed (open it`.
