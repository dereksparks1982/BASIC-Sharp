# BASIC# OTHERWISE Branches Test v0.1.39

Validation covers false and true startup, both transition directions, quiet unchanged truth, rearming, compound conditions, comments between paired Heads, action ordering, Save/restore, ASK, direct VM/reference parity, malformed OTHERWISE placement, `ELSE` guidance, loop protection, deterministic artifacts, and Profile 1 through Profile 6 byte preservation.

Focused files are `tests/test_otherwise_branches.rb`, `tests/test_meaning_profile_7.rb`, and `tests/test_bytecode_profile_7.rb`. The conformance tools are `tools/meaning_profile_7.rb` and `tools/bytecode_profile_7.rb`. `tools/otherwise_branch_stress.rb` requires at least 20,000 alternating branch transitions per runtime with exact parity.
