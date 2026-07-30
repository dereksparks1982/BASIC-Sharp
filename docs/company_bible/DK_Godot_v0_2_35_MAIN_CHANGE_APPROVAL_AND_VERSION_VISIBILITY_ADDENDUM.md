# Company Bible Addendum - v0.2.35 Main Change Approval And Version Visibility

Date: 2026-07-04
Status: Mandatory

## Main Approval

Before every edit to `scenes/Main.tscn`, Derek must be told why Main is required, exactly what will change, what existing systems could be affected, what external backup will be created, and whether a safer non-Main route exists.

Approval is specific to the described Main change. Expanded Main work requires a new explanation and approval.

## Rule Exceptions

No project rule may be silently bypassed. When a rule genuinely blocks safe or necessary work, the conflict, smallest requested exception, risks, alternatives, and affected files must be explained first. Only Derek may approve the exception, and every approved exception must be documented in the Company Bible/addendum, changelog, and session log.

## Version Visibility

Every numbered patch/build must update the Godot Project Manager identity, application version, runtime default build string, active scene overrides, visible running-game version label, package name, and versioned documentation.

A stale active version surface is a failed build-hygiene Goblin.

## Main Change Approved For This Build

Derek approved the v0.2.35 Main edit after being told it was limited to:

- advancing the Main scene build string;
- adding one visible top-of-screen version label under the existing HUD;
- preserving all gameplay, map, door, player, enemy, resurrection, and combat nodes.

An external pre-edit Main backup was created before the scene was changed.
