# DKIR Meaning Contract v0.1.19

## Starting value

```json
{
  "subject": { "type": "object", "name": "henry" },
  "relation": "has",
  "value_name": "health",
  "amount": 10
}
```

## Damage amount

```json
{
  "action": "damage",
  "target": { "type": "object", "name": "henry" },
  "amount": 3
}
```

An accepted older damage action without `amount` means 1.

## Exact value assignment

```json
{
  "action": "change",
  "value_name": "charges",
  "target": { "type": "object", "name": "brass bell" },
  "to_amount": 2
}
```

## Exact-value condition

```json
{
  "relation": "has",
  "subject": { "type": "object", "name": "henry" },
  "value_name": "damage",
  "amount": 3
}
```

## Validation authority

- Numeric fields must be JSON integers, not numeric-looking text.
- Values use 0 through 2,147,483,647.
- Damage amounts use 1 through 2,147,483,647.
- Value names are nonempty one-word text.
- Duplicate START assignments for the same Thing and value are rejected.
- Numeric shape validation occurs before START changes the world.
- Runtime selection is recalculated from loaded Things; serialized candidates remain debug information only.
