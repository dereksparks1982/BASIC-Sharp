# BASIC# Number Changes and Comparisons Test v0.1.37

Required focused coverage includes parsing, BSIR, profile selection, all four threshold boundaries, exact equality preservation, missing values, text/number mismatch, invalid amounts, single-target overflow/underflow, `every #kind` atomicity, IF crossing/rearming, BSBC opcode identity, loader rejection, direct VM execution, reference parity, ASK, Save/restore, and deterministic fixtures.

`tools/number_change_stress.rb` performs 10,000 increases and 10,000 decreases independently in the BSharp VM and reference runtime, validates every event result, checks threshold rearming, and separately proves overflow and underflow atomicity.
