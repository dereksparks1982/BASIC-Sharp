# DK Godot v0.4.70 Company Bible Addendum - Post-Build Git and No Hard Gate Rule

Status: mandatory workflow rule
Recorded in: DK Godot v0.4.70 - APPLE TREE REWARD CONSISTENCY AND PIE REWARD BUILD

## Post-build Git documentation

After each new patch, build, hotfix, or release package is accepted as the next local working version, perform the local Git documentation step before moving on:

1. Review `git status`.
2. Stage the accepted project changes.
3. Commit with the accepted version/build name.
4. Tag the accepted version.
5. Confirm the working tree is clean or intentionally documented.

This records the accepted working state in local Git before the next build begins.

## No hard compliance gate rule

NASA-inspired compliance gates and tool-based hard blocking standards are rejected for DK workflow unless Derek explicitly approves a specific gate later.

Validation tools may report problems, warnings, mismatches, or risks. They must not become a Companion-style blocker that refuses work merely because a number, rule, or automated preference does not match what the tool expected.

Authority remains:

- Derek decides.
- Tools advise.
- No new automated gatekeeper is added by default.
