# BASIC# Parser Contract v0.0.19

## Preserved structure

BASIC# continues to use a Head followed by one Body:

```text
HEAD
[first line
next line].
```

Current executable Heads remain `KINDS`, `DEFINE`, `START`, `WHEN`, and `IF`.

## New whole-number forms

### START value

```text
Thing has NUMBER VALUE_NAME
```

Example:

```text
henry has 10 health
```

### Damage amount

```text
(damage TARGET by NUMBER
```

The older `(damage TARGET` form remains valid and means one damage.

### Exact value assignment

```text
(change VALUE_NAME of TARGET to NUMBER
```

This is distinct from the preserved state form:

```text
(change TARGET to STATE
```

### Exact-value IF condition

```text
Thing has NUMBER VALUE_NAME
```

## Numeric rules

- NUMBER uses digits only.
- Accepted range is 0 through 2,147,483,647.
- Damage amounts use 1 through 2,147,483,647.
- Value names are one plain word.
- Negative numbers, decimals, fractions, commas, number words, and scientific notation are rejected plainly.

## Protected exclusions

No arithmetic expressions, variables, constants, comparisons, AND, OR, units, percentages, or new official words are introduced.
