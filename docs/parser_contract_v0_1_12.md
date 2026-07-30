# DKScript Parser Contract v0.1.12

## Public language identity

The public language name is BASIC#.

The current parser, Ruby module, command, repository, and package names remain under the DKScript bootstrap identity. The technical rename is excluded.

## Structure preserved

```text
HEAD
[first Body line
next Body line].
```

The Body begins against its first word. The old child-line structure remains rejected.

## Existing Trigger context preserved

```text
WHEN
[player attacks a guard
<then> (damage that guard].
```

The parser and resolver information for `a guard` and `that guard` remains unchanged.

## v0.1.12 parser status

No syntax change was made.

The version advances because the compiler/runtime package and emitted DKIR are versioned together.

## Preserved rules

- `<then>` and `<than>` are identical Connectors.
- `there` and `their` remain identical where the dictionary applies that pair.
- `(damage`, `(change`, `(carry`, and `(unlock` remain official words.
- No new official word is introduced.
- Exact Thing references remain valid.
- No capitalization or spacing-tolerance rule is silently added.
