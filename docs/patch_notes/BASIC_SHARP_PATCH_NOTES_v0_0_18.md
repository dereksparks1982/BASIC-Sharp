# BASIC# Patch Notes v0.0.18

BASIC# can now run an official word on every compatible Thing:

```text
(damage every guard
(change every guard to angry
```

Selection follows creator definition order and includes descendant Kinds. One action line finishes across the whole set before the next line starts.

Plural actions do not replace singular `that Kind` context. A known empty set is explained and skipped without stopping later actions.

Large result sets stay complete internally while the human report shows a bounded summary instead of hundreds of repetitive lines.
