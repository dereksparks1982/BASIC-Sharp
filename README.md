# BASIC#

**A scripting language made for non-programmers, by non-programmers.**

BASIC# is an experimental programming language for creating games, applications, and interactive worlds using clear, structured English. It is designed to help people turn ideas into working software without first mastering conventional programming syntax.

## Intro

Instead of cryptic commands, BASIC# uses familiar words and a small set of consistent visual guides. Creators define things, describe their starting state, and tell the program what should happen when something changes.

BASIC# uses `@name` for a particular Thing, `#kind` for a type of Thing, `PLAYER` for the player, `WHEN` and `IF` for rules, `|then` for results, and `(` before action words. These marks are intentional parts of the language.

## Try BASIC# in your browser

**[Open the BASIC# Live Console](https://dereksparks1982.github.io/BASIC-Sharp/)**

Write a BASIC# program, click **Execute**, trigger supported events, and see what happens to characters and objects. This is an early experimental console. It understands only part of the language and does not yet run the full BSharp bytecode VM.

## What BASIC# is being built to do

- Make **games and interactive worlds** with plain-English descriptions, characters, events, and rules.
- Help people create **useful apps and tools** without the usual technical barriers.
- Make program behavior understandable through **readable code and helpful errors**.
- Become an increasingly independent language with its own intermediate representation (BSharp IR), bytecode (BSBC), and virtual machine (BSharp VM).

## Development status

The current accepted release is **v0.0.84**. New browser-console and compiler work is being developed toward v0.0.85, but has not been accepted or fully tested. The production compiler still relies on Ruby for bootstrapping and reference behavior. BASIC# is **not yet fully self-hosted**.

## Documentation

- [Complete technical history](docs/history/BASIC_SHARP_TECHNICAL_HISTORY.md)
- [Development roadmap](docs/roadmap/BASIC_SHARP_ROADMAP.md)
- [Documentation guide](docs/BASIC_SHARP_DOCUMENTATION_MAP.md)
- [Company Bible](docs/company_bible/BASIC_SHARP_COMPANY_BIBLE.md)

## License / Legal

Copyright © 2026. **All rights reserved.** Public access to this repository does not grant an open-source license. See [LICENSE](LICENSE) for the full terms.
