# BASIC# Parser Contract v0.0.39

The canonical Heads are `KINDS`, `DEFINE`, `START`, `WHEN`, `IF`, `OTHERWISE`, `CONTROLS`, `HOVER`, and `CONTEXT`.

The parser pairs an OTHERWISE section only with the immediately preceding meaningful IF statement. Comments and blank lines are not meaningful Heads. OTHERWISE has no condition text and its Body contains `|then` actions. A second OTHERWISE, an intervening Head, a standalone OTHERWISE, or `OTHERWISE` followed by text is invalid. `ELSE` always fails with `BASIC# uses OTHERWISE instead of ELSE.`
