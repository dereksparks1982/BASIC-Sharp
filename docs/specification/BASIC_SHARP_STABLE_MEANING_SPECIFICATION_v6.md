# BASIC# Stable Meaning Specification v6

Meaning Profile 6 extends Profiles 1–5 only when an IF contains two or more complete clauses joined by one connector.

- `and`: all ordered clauses are true.
- `or`: one or more ordered clauses are true.
- Supported clauses are the accepted state, negated state, relation, exact-number, exact-text, and four threshold meanings.
- Quoted connector words do not split a clause.
- The complete group owns false-to-true waking and rearming.
- Mixed connectors, empty clauses, and nested groups are invalid.

The machine-readable authority is `spec/meaning_v6/BASIC_SHARP_MEANING_PROFILE_v6.json` with ten deterministic cases. Programs without compound IF conditions retain their earlier meaning profile and behavior.
