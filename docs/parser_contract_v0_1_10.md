# DKScript Parser Contract v0.1.10

## Structure preserved

```text
HEAD
[first Body line
next Body line].
```

The Body begins against its first word. The old child-line structure remains rejected.

## Existing Trigger references used by this build

```text
player attacks a guard
```

The resolver already records `a guard` as one Thing of Kind `guard`.

```text
(damage that guard
```

The resolver already records `that guard` as the guard previously selected by the Trigger.

## v0.1.10 parser status

No new syntax was added. The parser and resolver structures already present in v0.1.09 are now used by the runtime.

## Preserved rules

- `<then>` and `<than>` are identical Connectors.
- `there` and `their` remain identical where the dictionary applies that pair.
- `(damage`, `(change`, `(carry`, and `(unlock` remain official words.
- No new official word is introduced.
- Exact Thing references remain valid.
