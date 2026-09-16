# BSIR Platform Movement Contract v0.0.36

Platform movement selects `bsharp.meaning.v4`. It retains the Profile 3 `controls`, `hover_declarations`, and `context_declarations` meaning keys.

Resolved left/right instructions use:

```json
{
  "type": "platform_move",
  "key": "A",
  "direction": "left",
  "speed": 6,
  "line_number": 3
}
```

Resolved jump instructions use:

```json
{
  "type": "platform_jump",
  "key": "SPACE",
  "speed": 10,
  "line_number": 5
}
```

Keys remain exact uppercase creator tokens. Directions are canonical `left` or `right`. Speeds become positive whole numbers during resolution. `line_number` is diagnostic metadata and is excluded from stable meaning fingerprints.

Profile 1 through Profile 3 documents retain their existing profile selection and meaning.
