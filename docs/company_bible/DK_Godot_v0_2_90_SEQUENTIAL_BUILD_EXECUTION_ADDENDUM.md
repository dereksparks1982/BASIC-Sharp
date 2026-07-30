# DK Godot v0.2.90 Sequential Build Execution Addendum

This addendum records an owner-directed Company Bible rule.

## Mandatory rule

DK work is sequential: one build at a time.

When a session contains Build 1, Build 2, Build 3, or more, those numbers define the queue. Build 1 must be completed, validated, packaged, and handed off before Build 2 begins. Build 2 must be completed before Build 3 begins.

The rule covers:

- Godot builds and patches;
- hotfixes;
- development utilities;
- asset conversion or processing;
- documentation-only packages;
- handshakes and transfer archives;
- validation and packaging work.

No next build begins until the active build is complete or the owner explicitly cancels or reorders it. Parallel build execution is forbidden because it can overload the owner's computer and can mix source states, versions, manifests, and deliverables.
