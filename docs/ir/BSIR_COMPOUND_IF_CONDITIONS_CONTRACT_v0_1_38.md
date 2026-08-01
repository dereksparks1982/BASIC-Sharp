# BSIR Compound IF Conditions Contract v0.1.38

Profile 6 records a compound IF condition as an object with the original `raw` text, a `connector` of `and` or `or`, and an ordered `clauses` array containing at least two existing atomic condition records. Nested compound records are forbidden.

```json
{
  "raw": "PLAYER has at least 100 score and @boss is dead",
  "connector": "and",
  "clauses": [
    {"type": "value_at_least", "subject": "player", "value_name": "score", "value": 100},
    {"type": "state_is", "subject": "boss", "state": "dead"}
  ]
}
```

Any compound condition selects `bsharp.meaning.v6` and fingerprint algorithm `sha256-bsir-meaning-v6`. Clause order, connector, literals, and atomic meanings participate in deterministic fingerprinting.
