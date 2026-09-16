# BASIC# Runtime Contract v0.0.38

The preferred BSharp VM and protected `BasicSharp::Runtime` oracle support Profiles 1–6. Profile 6 evaluates ordered compound IF groups directly and preserves accepted startup settlement, event completion, false-to-true wakeup, quiet-while-true behavior, rearming, source-order settlement, follow-up ordering, and 1,024-step loop protection.

Source and saved BSIR are deterministically emitted to Profile 6 BSBC in memory, completely validated, and executed by the preferred VM. `--reference-runtime` remains explicit diagnostic use. `--verify-runtime-parity` independently replays both machines and stops on any disagreement in events, worlds, IF state, ASK, Save, restore, or replay.
