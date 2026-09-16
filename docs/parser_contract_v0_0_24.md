# BASIC# Parser Contract v0.0.24

v0.0.24 adds no creator-language syntax, Connector, or official word.

The only accepted Heads are:

```text
KINDS
DEFINE
START
WHEN
IF
```

The abandoned starter names `WORLD`, `STATES`, `RELATIONS`, `ACTIONS`, `WHILE`, and `OTHERWISE` are not Heads. Each receives a plain explanation listing the five current Heads.

The canonical Connector remains `<then>`. `<than>` remains an accepted equivalent with identical meaning.

The executable official words remain `(damage`, `(change`, `(carry`, `(unlock`, and `(cause`.

Parser meaning is now covered by `bsharp.meaning.v1` cases 01 and 13. Ruby parser object layout is not stable language meaning.
