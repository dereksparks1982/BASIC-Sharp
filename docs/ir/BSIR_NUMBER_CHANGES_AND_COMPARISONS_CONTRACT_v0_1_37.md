# BSIR Number Changes and Comparisons Contract v0.1.37

Profile 5 action records use:

```json
{"action":"increase","value_name":"score","target":{},"amount":10}
{"action":"decrease","value_name":"health","target":{},"amount":3}
```

Whole-number IF records retain `relation: "has"`, `value_name`, and `amount`. Threshold records add exactly one `comparison` value: `at_least`, `more_than`, `at_most`, or `less_than`. Exact equality omits `comparison`, preserving earlier BSIR.

Any new number-change action or threshold comparison selects `bsharp.meaning.v5`. Line numbers and raw text remain diagnostic-only and do not affect meaning fingerprints.
