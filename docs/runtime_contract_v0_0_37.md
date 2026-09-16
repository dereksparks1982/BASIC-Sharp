# BASIC# Runtime Contract v0.0.37

The preferred path remains source or saved BSIR -> deterministic in-memory BSBC -> complete loader validation -> direct BSharp VM execution. `BasicSharp::Runtime` remains the protected reference oracle.

Profile 5 requires parity for startup, events, action steps, atomic errors, IF settlement, world snapshots, ASK, Save format 5, restore, replay, and canonical reports. Shadow verification stops on any disagreement.

Profiles 1 through 4 remain accepted and unchanged. A runtime without Profile 5 support must reject its bytecode before execution.
