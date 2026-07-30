# DK Godot v0.2.33 Company Bible Addendum - Build Response Boilerplate Cleanup

Date: 2026-07-04

## Rule

Do not repeat generic build-response boilerplate such as “I could not run Godot validation here, so test this in-editor” in every DK patch/build response.

Derek already understands the tool limitation. Mention validation/tooling limitations only when newly relevant, specifically asked, or when a concrete validation failure/limitation affects the patch.

## Reason

Repeated generic validation disclaimers add noise and slow the build handoff. DK build responses should stay focused on the actual install file, actual changes, and actual test targets.
