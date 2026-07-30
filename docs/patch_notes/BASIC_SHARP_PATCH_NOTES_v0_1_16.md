# BASIC# Patch Notes v0.1.16

BASIC# now hardens the Kind inheritance machinery already introduced in v0.1.15.

The runtime calculates family distances once, then reuses them while choosing Triggers. Deep families, many overlapping Triggers, equal-distance ties, malformed saved BSharp IR, and unknown Thing Kinds now have explicit tests and plain explanations.

No new BASIC# words or syntax were added.
