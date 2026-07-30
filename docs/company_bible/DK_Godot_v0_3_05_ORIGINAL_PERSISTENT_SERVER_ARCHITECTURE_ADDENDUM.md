# DK Godot v0.3.05 Original Persistent Server Architecture Addendum

**Date:** 2026-07-07  
**Status:** Mandatory owner direction

## Original DK server rule

Demon Killer will develop an original DK-made persistent server inspired by the engineering problems solved by RunUO, ServUO, WorldBox-style kingdom simulations, and other persistent worlds. DK may study their public behavior, documentation, architecture, and coding logic, but it must not copy their code into the project or disguise copied code through renaming.

The server is a separate process from the Godot game client. It may continue advancing the world after the client closes. When the machine or server process has been offline, it must use saved timestamps and controlled catch-up simulation rather than pretending code executed without power.

## Time law

The active server clock follows the current Company Bible:

- starting date: Autumn, 09.06.9600 BCE;
- one real-world day equals four full DK world days;
- 365 DK world days equal one DK year;
- the celestial threat begins 369 world years from impact.

## Stability law

Future kingdoms and dynasties should change slowly. Long-lived people, durable institutions, and event-driven historical pressure are preferred over constant random collapse.
