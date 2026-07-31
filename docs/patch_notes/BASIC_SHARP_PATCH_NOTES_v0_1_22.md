# BASIC# Patch Notes v0.1.22

BASIC# can now save a fully settled world into a deterministic BSharp Save file and restore it later with the matching `.bsharp` or `.bsir.json` program.

```bash
ruby compiler/basic_sharp.rb program.bsharp --run "player attacks henry" --save-world world.bsave.json
ruby compiler/basic_sharp.rb program.bsharp --load-world world.bsave.json --run "henry attacks player"
```

Loading does not replay START, startup IF rules, or startup caused events. Save files are validated completely before runtime state changes, and failed writes preserve the previous save.
