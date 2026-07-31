# BASIC# Runtime Contract v0.1.30

## Runtime paths

Profile 1 has three supported execution paths:

1. resolved source through `BasicSharp::Runtime`;
2. saved BSIR through `BasicSharp::Runtime`;
3. validated BSBC through `BasicSharp::BytecodeVirtualMachine`.

Equivalent meaning and event sequences must produce equal settled snapshots, IF truth and active state, follow-up order, save documents, and ASK answers where the underlying representation preserves the required information.

## VM world boundary

The VM accepts only `BasicSharp::BytecodeLoader`. Each VM owns one mutable world. The loader model remains deeply frozen and may be shared by many isolated VMs.

## Save boundary

A VM save may be written only when `save_ready?` is true. A failed or unmatched event makes the current world ineligible for saving until a later successful event. Restore validates the complete candidate before replacing the current world.

## ASK boundary

ASK is read-only. It must preserve the exact snapshot, IF active state, and save readiness.

## Failure boundary

Malformed saves, fingerprint mismatches, invalid state/value records, and invalid relationships raise `WorldSaveError` without partial world replacement. Existing IF and follow-up-event loop limits remain authoritative.
