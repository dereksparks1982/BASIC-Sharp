# BASIC# Stable Meaning Specification v7

Profile identifier: `bsharp.meaning.v7`.

Profile 7 includes every accepted Profile 1 through Profile 6 meaning and adds one optional OTHERWISE action list to an IF rule. The two bodies are mutually exclusive for one settlement. The complete atomic or compound condition determines the selected body.

Initial settlement runs the body matching current truth. Later settlement runs IF only for false-to-true and OTHERWISE only for true-to-false. Unchanged truth performs no branch action. Saved settled branch state survives restore. The official source word is `OTHERWISE`; `ELSE` has no Profile 7 meaning.
