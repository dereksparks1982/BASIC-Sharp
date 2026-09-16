# BASIC# Parser Contract v0.0.22

v0.0.22 adds no creator-language syntax, Head, Connector, or official word.

The accepted v0.0.21 parser behavior remains unchanged:

- `KINDS`, `DEFINE`, `START`, `WHEN`, and `IF` remain the only Heads.
- `(damage`, `(change`, `(carry`, `(unlock`, and `(cause` remain the executable official words.
- `(cause` continues preserving complete event text, including names containing `to` or `by`.
- Whole-number values and amounts retain their accepted ranges and shapes.
- `that Kind` and `every Kind` retain their accepted scopes.

`--save-world` and `--load-world` are bootstrap-tool CLI options. They are not parsed as BASIC# source and do not create hidden world actions.
