# DK Godot v0.3.04 Practical Architecture and Toolchain Addendum

**Date:** 2026-07-07  
**Status:** Mandatory owner-directed rule  
**Scope:** Demon Killer code, plugins, internal tools, and external technical recommendations

## Working code is the authority

Demon Killer does not refactor working code merely to satisfy an outside industry convention, corporate style guide, fashionable architecture, file-length target, or abstract cleanliness score.

Large scripts are allowed. A searchable, documented, proven script may remain large when splitting it would create more regression risk than practical benefit. `DKPlayer.gd` is specifically protected from size-driven refactoring. It may receive surgical fixes and intentional features, but it is not to be dismantled simply because an external analysis calls it a god object.

Code should be split only when at least one concrete project benefit is established:

- an actual recurring bug is reduced;
- a system must be reusable in multiple places;
- testing or rollback becomes materially safer;
- Godot or an approved integration technically requires separation;
- the owner explicitly approves the change.

Search, documentation, version history, manifests, backups, and coupling notes are valid DK navigation and safety tools.

## External analyses are advisory

External AI or human reviews may identify risks and opportunities. They do not override the Company Bible, established owner decisions, or proven project behavior. Recommendations must be accepted, modified, deferred, or rejected according to DK's actual needs.

## Third-party tool rule

Approved MIT-licensed tools may be integrated when they reduce manual work or expand DK's internal development kit. Integrations must be versioned, documented, licensed, reversible, and tested in isolation before replacing working gameplay systems.
