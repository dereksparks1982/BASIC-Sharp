# BASIC# Parser Contract v0.0.23

v0.0.23 adds no creator-language syntax, Head, Connector, or official word.

The accepted v0.0.22 parser behavior remains unchanged:

- `KINDS`, `DEFINE`, `START`, `WHEN`, and `IF` remain the only Heads.
- `(damage`, `(change`, `(carry`, `(unlock`, and `(cause` remain the executable official words.
- Whole-number values, `that Kind`, `every Kind`, IF conditions, and caused-event text retain their accepted forms.

`--ask` and `--ask-json` are bootstrap-tool CLI options. ASK questions are interpreted by `compiler/ask.rb`, not by the BASIC# source parser.
