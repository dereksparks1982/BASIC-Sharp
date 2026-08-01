# BASIC# Parser Contract v0.1.38

The parser preserves the IF head text. Semantic resolution scans it once while tracking straight double-quoted spans. Standalone lowercase-insensitive `and` and `or` tokens outside quotes are connectors; occurrences inside quoted text remain part of the literal.

Zero connectors retain the accepted atomic-condition parser and old profile. One connector family produces an ordered Profile 6 group. Both families on one line produce: `BASIC# does not mix and and or in one IF yet.` A connector without a complete condition on both sides produces: `Every and or or in an IF must have a complete condition on both sides.` Every clause is resolved and validated before runtime construction.
