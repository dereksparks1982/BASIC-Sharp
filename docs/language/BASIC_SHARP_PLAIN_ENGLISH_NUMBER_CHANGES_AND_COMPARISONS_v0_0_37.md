# BASIC# Plain-English Number Changes and Comparisons v0.0.37

## Actions

```bsharp
|then (increase score of PLAYER by 10
|then (decrease health of PLAYER by 3
```

The value must already exist and be a whole number. The amount must be a positive whole number. The legal result range is 0 through 2,147,483,647.

For one Thing or `every #kind`, BASIC# validates all targets first. A missing value, text value, overflow, or underflow stops the entire action and changes nothing.

## Conditions

```bsharp
IF PLAYER has 100 score
IF PLAYER has at least 100 score
IF PLAYER has more than 100 score
IF PLAYER has at most 100 score
IF PLAYER has less than 100 score
```

Exact equality retains its accepted meaning. Threshold rules use the accepted false-to-true wake, source ordering, rearming, and loop-protection contract.
