# BASIC# v0.0.30 Patch Notes

BASIC# can now run a validated `.bsbc` world, inspect it with ASK, save it, restore it later, and continue deterministic execution without replaying START.

The new stress lane runs 10,000 events through source, BSIR, and BSBC paths, then tests repeated restore cycles, ASK saturation, isolated VMs, malformed-save recovery, and both loop guards.

This build does not add new BASIC# words or syntax.
