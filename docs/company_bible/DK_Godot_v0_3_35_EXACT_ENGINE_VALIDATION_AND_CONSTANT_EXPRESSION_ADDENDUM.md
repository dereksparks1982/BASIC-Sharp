# Company Bible Addendum: Exact Engine Validation and Constant Expressions

**Version:** v0.3.35  
**Date:** 2026-07-09  
**Status:** Mandatory

## Rule

A parser or linter outside Godot must never be described as proof that a changed GDScript will compile in the project's exact Godot version.

For runner, plugin, build-tool, and startup-path changes:

1. Static lint and parse tools may be used as supporting checks.
2. The exact local Godot validation gate remains authoritative.
3. Constructor calls must not be used to initialize `const` values unless the exact project Godot version accepts that expression as compile-time constant.
4. A failed local validation report must be logged and corrected in a new numeric build before roadmap work resumes.
5. Validation standards must not be weakened to hide a tool failure.

## Historical lesson

v0.3.34 passed generic GDScript tooling but failed Godot 4.7 because two packed-array constructor calls were not valid constant expressions. Future records must distinguish static checks from exact-engine validation.
