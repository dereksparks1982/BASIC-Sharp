# BASIC# Platform Movement Test v0.1.36

Required coverage includes:

- exact parser and resolver output for left, right, jump, keys, and speeds;
- Profile 4 selection only for platform movement;
- opposing input cancellation and key release;
- one grounded jump per new keypress;
- no airborne re-jump or hidden jump buffering;
- landing, ceiling, left-wall, and right-wall response;
- first-frame, variable-frame, capped-frame, and backward-time behavior;
- source, BSIR, BSBC, BSharp VM, reference runtime, ASK, and Save parity;
- Profile 4 contract, fixture, loader, disassembly, and older-runtime boundary;
- 10,000 deterministic platform frames;
- byte-identical preservation of committed Profile 1 through Profile 3 BSBC and disassembly artifacts.
