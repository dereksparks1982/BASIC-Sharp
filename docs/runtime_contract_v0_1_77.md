# BASIC# Runtime Contract v0.1.77

v0.1.77 changes bounded self-hosting execution ownership, not creator-facing runtime meaning. `SmallCompilerSubsetBSBCVirtualMachine` must execute the trusted model from `SmallCompilerSubsetBSBCLoader` with exact event-result, final-world, Save, selector, action-order, IF/OTHERWISE, follow-up-event, and loop-protection parity against the production `BytecodeVirtualMachine` and `BasicSharp::Runtime` referees. Production runtime routing, Save, ASK, input behavior, and the BSBC binary format remain unchanged.
