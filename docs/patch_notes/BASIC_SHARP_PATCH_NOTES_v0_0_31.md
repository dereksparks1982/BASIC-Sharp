# BASIC# Patch Notes v0.0.31

BASIC# source and saved BSIR now run through the same validated BSharp Bytecode and BSharp VM road as direct `.bsbc` files. Ruby remains the temporary bootstrap host, while the older reference runtime is retained behind an explicit diagnostic option.

Use `--verify-runtime-parity` to make both engines independently check the same work and stop if their meaning diverges.
