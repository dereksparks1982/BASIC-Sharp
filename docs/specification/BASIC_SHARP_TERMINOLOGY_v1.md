# BASIC# Terminology v1

This record fixes the words used when discussing BSharp Meaning Profile 1.

| Term | Meaning |
|---|---|
| BASIC# | The language. Pronounced Basic Sharp. |
| BSharp | Safe written form used where `#` is unsafe. |
| Head | A top-level source section name: KINDS, DEFINE, START, WHEN, or IF. |
| Body | Ordered lines between `[` and `].` following a Head. |
| Connector | `<then>` or accepted equivalent `<than>`, joining a result action to WHEN or IF. |
| Thing | One uniquely named world object. |
| Kind | A classification that may inherit from one parent Kind. |
| Kind family | A Kind and its complete ancestor chain. |
| Fact | A START or IF statement about a Thing's state, relationship, or value. |
| Event | A normalized actor, event word, and optional target supplied to WHEN matching. |
| WHEN rule | One event pattern plus an ordered action body. |
| IF rule | One condition plus an ordered action body that wakes false-to-true. |
| Official word | A creator-facing executable action beginning with `(`. |
| Action body | Ordered official words belonging to one WHEN or IF rule. |
| Event context | Actual Things bound by a matched Kind reference. |
| `that Kind` | The singular actual Thing selected in the current event context. |
| `every Kind` | All direct and inherited members in definition order. |
| Whole-number value | A named integer amount from 0 through 2,147,483,647. |
| Follow-up event | An event explicitly created by `(cause` after the current body and IF settlement. |
| BSharp IR / BSIR | BSharp Intermediate Representation, the readable resolved program document. |
| BSharp Save | Deterministic settled-world state in `.bsave.json`. |
| BSharp ASK | Read-only deterministic inspection answers. |
| Meaning Profile | An implementation-neutral set of stable semantics and conformance fixtures. |
| Profile 1 | `bsharp.meaning.v1`, established by BASIC# v0.0.24. |
| Bootstrap implementation | The current Ruby compiler and runtime used to grow BASIC#. |
| Conformance case | Source plus implementation-neutral expected observations proving one meaning area. |

Ruby class names, method names, Struct layouts, caches, and internal helper names are implementation vocabulary, not BASIC# language terminology.
