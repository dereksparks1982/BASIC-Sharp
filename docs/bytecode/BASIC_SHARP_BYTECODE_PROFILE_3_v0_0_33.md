# BSharp Bytecode Profile 3

Profile `bsharp.bytecode.v3` requires `bsharp.meaning.v3`, format version 3, and section order `STRS META KIND THNG STRT EVNT IFRL CTRL HOVR CTXT CODE`. `CTRL`, `HOVR`, and `CTXT` contain canonical UTF-8 JSON arrays. The loader validates all sections before the VM receives an immutable model.
