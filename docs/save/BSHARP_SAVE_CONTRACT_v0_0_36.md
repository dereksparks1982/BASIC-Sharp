# BSharp Save Contract v0.0.36

Programs using `bsharp.meaning.v4` write BSharp Save format version `4` with program fingerprint algorithm `sha256-bsir-meaning-v4`.

The fingerprint includes the same normalized game-declaration keys introduced by Profile 3, including resolved platform control bindings and speeds. Runtime key state, velocity, frame time, and host collision facts are transient host-input state and are not saved as world meaning.

Reference-runtime and BSharp VM restores validate format 4, fingerprint identity, typed values, complete world shape, and no-START-replay rules before replacing a world. Profile 1 through Profile 3 Save formats remain unchanged.
