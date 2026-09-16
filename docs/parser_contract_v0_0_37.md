# BASIC# Parser Contract v0.0.37

The parser continues to use the accepted Heads, Bodies, `|then`, `@`, `#`, `PLAYER`, comments, and opening-parenthesis official-word grammar.

New official words are `(increase` and `(decrease`. Their canonical structure is:

```text
(increase VALUE_NAME of REFERENCE by POSITIVE_WHOLE_NUMBER
(decrease VALUE_NAME of REFERENCE by POSITIVE_WHOLE_NUMBER
```

IF `has` conditions recognize four multiword comparison phrases before the numeric literal: `at least`, `more than`, `at most`, and `less than`. Without one of those phrases, `has N value` remains exact equality.
