# DKScript Parser Contract v0.1.11

> **Historical naming note:** This record predates the v0.1.14 technical identity migration. At the time recorded below, BASIC# still used the working technical name `DKScript`. Old package names, commands, paths, and Git messages are preserved as audit history.


## Public language identity

The public language name selected by the owner is BASIC#.

The current parser, Ruby module, command, repository, and package names remain under the historical DKScript bootstrap identity in v0.1.11. A technical rename is excluded.

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

The v0.1.10 parser and resolver information used for `a guard` and `that guard` remains unchanged.

## v0.1.11 parser status

No syntax change was made.

## Preserved rules

- `<then>` and `<than>` are identical Connectors.
- `there` and `their` remain identical where the dictionary applies that pair.
- `(damage`, `(change`, `(carry`, and `(unlock` remain official words.
- No new official word is introduced.
- Exact Thing references remain valid.
- No capitalization or spacing-tolerance rule is silently added.
