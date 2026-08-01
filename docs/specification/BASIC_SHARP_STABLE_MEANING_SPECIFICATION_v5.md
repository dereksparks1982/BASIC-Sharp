# BASIC# Stable Meaning Specification v5

Stable Meaning Profile 5 extends Profiles 1 through 4 only with:

- atomic increase of an existing whole-number value;
- atomic decrease of an existing whole-number value;
- inclusive lower-bound comparison (`at least`);
- exclusive lower-bound comparison (`more than`);
- inclusive upper-bound comparison (`at most`);
- exclusive upper-bound comparison (`less than`).

The whole-number domain remains 0 through 2,147,483,647. Amounts for increase/decrease are 1 through 2,147,483,647. A failed action mutates no selected Thing and prevents its remaining action body from running.

The normative machine-readable conformance manifest is `spec/meaning_v5/BASIC_SHARP_MEANING_PROFILE_v5.json`, containing 10 deterministic cases.
