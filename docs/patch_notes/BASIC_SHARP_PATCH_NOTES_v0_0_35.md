# BASIC# v0.0.35 Patch Notes

This repair carries forward the complete Profile 3 build and fixes the v0.0.34 validation defect. Direct `.bsbc` execution was already using the BSharp VM; the standalone audit was comparing its correct v0.0.34 output with a stale v0.0.32 string. Both the VM and reference-runtime banner checks now follow the live BASIC# version automatically. No new creator-facing syntax or language meaning was added.
