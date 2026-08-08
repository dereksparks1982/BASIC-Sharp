# BASIC# Company Bible

**Version:** v0.1.58  
**Status:** Mandatory and canonical  
**Project:** BASIC#  
**Owner:** Derek  
**Canonical path:** `docs/company_bible/BASIC_SHARP_COMPANY_BIBLE.md`

> A scripting language made for non-programmers, by non-programmers.

## 1. Sole authority and scope

This file is the **one active Company Bible for BASIC#**. It replaces the former collection of standalone Company Bible files, addendums, carryover notes, reinforcement notes, project-bible pointers, and Godot metadata.

Every assistant, developer, tester, tool, and contributor working on BASIC# must read this document from beginning to end before preparing a build proposal or changing the project.

Future mandatory workflow changes must edit this same file in a numbered BASIC# build. **Do not create another standalone Company Bible addendum, carryover file, reinforcement note, or alternate Bible.**

The Company Bible governs authority, workflow, safety, packaging, validation, continuity, identity, and project conduct. It does not replace technical specifications, language contracts, the roadmap, changelogs, validation reports, or the cumulative handoff. Those records keep their distinct jobs.

Demon Killer and Godot-specific lore, gameplay, maps, scenes, doors, controls, art, and engine rules are not active BASIC# company law. Their original records remain recoverable in Git history at accepted BASIC# v0.1.24 commit `28e5b5b`.

## 2. Derek is the final decision-maker

Derek is the owner and final authority for BASIC# and DK LAB work.

- Tools advise, report, and validate. They do not overrule Derek.
- No assistant, contributor, convention, outside reviewer, automated score, or fashionable architecture may silently replace an owner decision.
- An explicit current instruction from Derek governs the approved work. When it changes a permanent rule, the decision must be recorded in this file through the next numbered build.
- Historical records that use the name Dick refer to Derek. Preserve those records as history, but use **Derek** in all new records.

## 3. Required reading order before work

Before proposing or performing a BASIC# build:

1. Acknowledge Derek before beginning lengthy inspection or tool work.
2. Read this complete Company Bible.
3. Read the current master handoff and roadmap.
4. Read the technical contracts, specifications, validation records, and source files relevant to the request.
5. Verify the accepted Git base and actual project state.
6. Ask Derek only when the records do not answer the question or an owner-only decision remains.

Do not ask Derek to repeat a decision already preserved in current project records. Do not guess around missing facts before checking the records.

## 4. Prebuild scope and explicit approval

Before implementation, packaging, file generation, or equivalent build work, state:

- required accepted base version, commit, tag, branch, and clean-tree requirement;
- target numeric version and build title;
- exact purpose and behavior;
- exact files or systems expected to be added, modified, or deleted;
- explicit exclusions;
- risks and controls;
- rollback point and method;
- validation plan;
- exact package filename.

Implementation begins only after Derek explicitly approves that stated scope with a build or patch command. Approval applies only to that scope. If the work expands, stop and obtain approval for the expanded scope.

Discussion, questions, defect reports, design notes, and future ideas are not build approval by themselves.

When Derek says **stop**, all build, tool, packaging, and implementation work stops immediately. Answer him plainly instead of continuing silent work.

## 5. Complete the approved scope

Once Derek approves an exact build:

- complete every approved item in that build unless Derek changes the scope;
- do not silently defer requested items to another version;
- disclose any limitation, exclusion, or failure before delivery;
- do not add unrelated work because it seems helpful;
- finish, validate, package, and hand off the current build before starting another.

When Derek reports that an installed patch did not take, re-carry the missed work in the corrective build, preserve working systems, add a clear verification method when practical, and document the failure and repair. A changelog entry is not proof that a feature actually worked.

## 6. Accepted base and version truth

Every build, patch, hotfix, documentation release, or package uses the **next unused numeric version**.

- Letter suffixes such as `a`, `b`, or `c` are forbidden.
- Rejected or failed packages are not accepted baselines and their version numbers are not reused.
- Never build from an approximate reconstruction of the accepted base.
- Verify the exact accepted commit, tag, branch, clean working tree, and required base-file hashes.
- A dirty or unexpected base stops installation before mutation.
- Every active version surface must agree, including compiler/runtime identity, generated artifacts, package name, manifest, README, tests, changelog, patch notes, session log, validation record, handshake, roadmap, and master handoff where applicable.
- A documentation-only build still advances the version when it changes the active project.

After Derek accepts a build, review `git status`, stage the accepted changes, commit with the accepted build name, tag the version, and confirm the tree is clean before the next build.

## 7. Packaging rules

The default deliverable is one **changed-files-only ZIP**.

- Provide one primary download unless Derek explicitly requests otherwise.
- Preserve project-relative paths directly at archive root. Do not add a duplicate wrapper folder.
- Do not deliver loose project files.
- Package records belong in their proper project directories, not scattered at ZIP root. Approved top-level package control files, such as the manifest, installer, and build handshake, are allowed.
- Every user-facing archive name includes its numeric version.
- Do not create a separate loose SHA/checksum file unless Derek asks. Package and base hashes belong inside the manifest and installer validation.
- A full-project archive is created only when Derek explicitly requests one.

Installer scripts are text control files and must contain zero literal NUL bytes. Any manifest-array transport that uses NUL separators must emit escaped `\0` at runtime, not embed binary NUL characters in the installer source. A NUL-bearing installer is a malformed package and must be rejected rather than worked around.

Every installable BASIC# changed-files package must carry `BASIC_SHARP_PATCH_MANIFEST.json` using:

```text
format = BASIC_SHARP_CHANGED_FILES_PATCH
format_version = 1
package_name = exact archive filename
target_version = exact numeric target
direct_project_root_payload = true
changed_files_only = true
added_paths = exact array
modified_paths = exact array
deletions = exact array
files = payload byte counts and SHA-256 hashes
base_files = accepted-base byte counts and SHA-256 hashes
```

Repair a malformed package. Do not weaken the installer or validator to excuse it.

## 8. Backups and rollback

Git and the validated installer are the primary recovery authorities.

- The installer must verify the base before mutation.
- A post-mutation failure must restore the exact accepted tag and remove untracked candidate files.
- Do not place backup copies inside the active project tree.
- Do not create a routine second backup ZIP for every package.
- An exceptional separate backup is allowed only when Derek requests it or a concrete recovery risk is explained. It remains versioned, clearly labeled, outside the active project, and separate from the installation package.
- The build handshake and master handoff must name the rollback point.

## 9. Validation and evidence

A build is not successful merely because files were written or code compiled.

Validation must be:

- appropriate to the actual change;
- bounded and deterministic where possible;
- non-destructive to the accepted project;
- performed with the strongest available toolchain;
- reported honestly, including limitations and failures;
- repeated owner-side when local tooling cannot reproduce the final environment.

Warnings are treated as failures by default. When a warning or validation exception must remain, stop, explain the exact reason and risk, and obtain Derek's explicit approval. Record the exception in the build documents.

Derek may explicitly accept a documented exception. Automated gates advise and protect the candidate, but they do not become an independent owner.

Do not repeat generic environment-limit boilerplate in every delivery. Mention a limitation when it materially affects that build or Derek asks about it.

Failed runs, rejected packages, contaminated packages, and embarrassing mistakes are permanent evidence. Correct them through dated errata, new current-state entries, failure logs, or a new numbered repair. Do not silently scrub history.

Before sealing any numbered package, audit every generated artifact, expected-result file, manifest, fixture, and protected hash whose bytes can contain or depend on the target version. Regenerate and validate the complete version-bearing fixture inventory together. Do not stop after repairing only the first failed version-sensitive gate, and do not weaken a fixture or validator to make stale expected data pass.

## 10. Documentation and continuity

Every numbered BASIC# deliverable must include the records appropriate to its scope:

- top-level build handshake;
- changelog;
- patch notes;
- session log;
- changed-files record;
- validation record;
- updated patch manifest;
- updated roadmap;
- updated cumulative master handoff.

The one active handoff is:

```text
docs/hand_off/BASIC_SHARP_MASTER_THREAD_HANDOFF.md
```

Do not create new per-version `NEW_THREAD_HANDOFF` files. Existing historical per-version handoffs remain preserved as history, but the master handoff is the continuity spine.

The top of the master handoff must identify the current accepted base or candidate, exact package, completed work, exclusions, validation, risks, rollback, and next action. Its history must preserve accepted versions and material failures.

A numbered deliverable is documentation-incomplete until the master handoff and roadmap are current.

When a mandatory workflow rule changes, edit this canonical Company Bible in the same build. Do not create another Bible file.

After every completed installation or validation decision, state the next concrete step without waiting for Derek to ask what comes next.

## 11. Engineering principles

BASIC# follows these priorities:

```text
1. Correct behavior.
2. Preserve accepted working systems.
3. Understandable and repairable implementation.
4. Deterministic validation and documentation.
5. Conventional elegance only when it serves the first four.
```

- Make the smallest safe change that fulfills the approved scope.
- Do not rewrite functioning code merely to satisfy style fashion.
- Do not break one accepted system to fix another.
- Build real systems before final decoration.
- A rough but working foundation is better than polished theater around missing behavior.
- Keep compatibility bridges when they protect accepted work, unless a deliberate migration has been approved.
- Do not invent hidden behavior, silent corrections, or unapproved language meaning.
- Preserve accepted semantics across future compiler, bytecode, runtime, virtual-machine, editor, and self-hosting implementations.
- Test actual behavior, not merely the presence of files or names.
- No orphan tools or test files. Every added tool must have a defined role, documentation, and validation path.

## 12. BASIC# identity and protected design

Canonical identity:

```text
Language name: BASIC#
Pronunciation: Basic Sharp
Safe written form: BSharp
Safe code/path form: basic_sharp
Ruby namespace: BasicSharp
Creator source extension: .bsharp
Intermediate representation: BSharp Intermediate Representation
Short IR names: BSharp IR and BSIR
World save: BSharp Save
Inspection system: BSharp ASK
Stable Meaning Profile 1: bsharp.meaning.v1
Stable Meaning Profile 2: bsharp.meaning.v2
Stable Meaning Profile 3: bsharp.meaning.v3
Stable Meaning Profile 4: bsharp.meaning.v4
Stable Meaning Profile 5: bsharp.meaning.v5
Stable Meaning Profile 6: bsharp.meaning.v6
Stable Meaning Profile 7: bsharp.meaning.v7
Executable bytecode: BSharp Bytecode
Short bytecode name: BSBC
Bytecode extension: .bsbc
Bytecode Profile 1: bsharp.bytecode.v1
Bytecode Profile 2: bsharp.bytecode.v2
Bytecode Profile 3: bsharp.bytecode.v3
Bytecode Profile 4: bsharp.bytecode.v4
Bytecode Profile 5: bsharp.bytecode.v5
Bytecode Profile 6: bsharp.bytecode.v6
Bytecode Profile 7: bsharp.bytecode.v7
Virtual machine: BSharp Virtual Machine
Virtual machine short name: BSharp VM
```

Protected rules:

- The tagline is **“A scripting language made for non-programmers, by non-programmers.”**
- Do not automatically prefix new BASIC# names with `DK`.
- Historical DKScript and DKIR references remain only where required for truthful history or the exact retired-format diagnostic.
- The opening `(` in official words such as `(damage` is a deliberate creator-facing guide showing that the world is being told to do something. It is not merely parser convenience.
- Difficult machinery belongs beneath understandable creator-facing language.
- “Forgiving input, dependable meaning, canonical output” remains the long-term direction, but tolerance is added only through approved, tested builds.
- Stable Meaning Profile 1 remains the implementation-neutral meaning authority for its covered language behavior. Stable Meaning Profile 2 extends it only with approved creator-facing text values; programs that use no Profile 2 meaning remain Profile 1.
- Profile 2 creator-facing text uses straight double quotes, one-line valid UTF-8, and exact case, punctuation, and spaces. Identifier normalization must never alter literal text. Interpolation, concatenation, escape sequences, and multiline text require later approval.
- **BSharp Bytecode** and **BSBC** are the protected names for compact execution artifacts governed by `bsharp.bytecode.v1` through `bsharp.bytecode.v7`. The accepted Ruby bootstrap may emit deterministic `.bsbc` files, completely validate them into deeply frozen trusted models, reconstruct `.bsbc.txt` diagnostic disassembly, and execute all accepted profiles through the **BSharp Virtual Machine**. The BSharp VM interprets the validated bytecode model directly and must not reconstruct BSIR or call the reference Ruby runtime. Profile 2 adds typed text instructions and role-aware literal strings without weakening Profile 1 identifier validation. Profile 3 adds deterministic controls, hover information, context interaction, and the `CTRL`, `HOVR`, and `CTXT` sections. Profile 4 adds plain-English left/right platform movement, grounded jumping, built-in gravity, frame timing, collision response, and engine-neutral collision-movement commands. Profile 5 adds atomic whole-number increase/decrease actions and exact threshold comparisons. Profile 6 adds ordered plain-English `and` or `or` IF clauses whose complete result owns false-to-true waking and rearming, without changing Profile 1 through Profile 5 meaning. Profile 7 adds an optional `OTHERWISE` action block: the current branch runs once at START, IF runs on false-to-true, OTHERWISE runs on true-to-false, and unchanged truth remains quiet. The protected creator-facing pair is **IF / OTHERWISE**; `ELSE` is not an alias.
- The **BSharp VM is the preferred runtime** for `.bsharp`, `.bsir.json`, and `.bsbc`. Source and saved BSIR enter it through deterministic BSBC emission and complete validation in memory. `BasicSharp::Runtime` remains a protected reference oracle available only through explicit diagnostic use and conformance testing. Shadow parity verification must stop on disagreement rather than silently choosing one engine's result.
- Self-hosting must be earned in stages. The first compiler-writing subset is governed by `spec/self_hosting/BASIC_SHARP_SELF_HOSTING_SUBSET_v1.json` and `docs/self_hosting/BASIC_SHARP_SELF_HOSTING_FOUNDATION_v0_1_44.md`; Ruby remains the bootstrap and reference authority until a BASIC# compiler can reproduce approved outputs under locked validation.
- The input-device meaning layer is governed by `spec/input/BASIC_SHARP_INPUT_DEVICE_MAPPING_v1.json` and `docs/language/BASIC_SHARP_PLAIN_ENGLISH_MOVEMENT_AND_INPUT_v0_1_46.md`. Keyboard, mouse/keyboard, PS5, Xbox, and generic gamepad events map beneath existing creator-facing `CONTROLS for PLAYER` declarations. This is not permission for new syntax, controller remapping UI, platform-specific drivers, engine bridge work, haptics, graphics, or Profile 8.
- The tokenizer/reader self-hosting lane is governed by `spec/self_hosting/BASIC_SHARP_TOKENIZER_READER_CONTRACT_v1.json`, `docs/self_hosting/BASIC_SHARP_TOKENIZER_READER_CONTRACT_v0_1_47.md`, `docs/self_hosting/BASIC_SHARP_TOKENIZER_READER_IMPLEMENTATION_v0_1_48.md`, and `compiler/tokenizer_reader.rb`. It freezes deterministic reader records, comment handling, current Head words, and first future-facing token records while Ruby remains the reader referee and the existing Ruby parser remains production authority. This is not permission to replace `compiler/lexer.rb`, replace `compiler/parser.rb`, route production parsing through the new implementation, claim BASIC# is self-hosted, add Profile 8, add syntax, or change runtime behavior.
- The long-term strategic doctrine is governed by `docs/strategy/BASIC_SHARP_UNIVERSAL_STANDARD_AND_AI_TOOLING_DOCTRINE_v0_1_47.md`. BASIC# / BSharp aims toward a universal creator-facing programming standard for websites, apps, games, tools, automation, and business systems. Compatibility comes before replacement: BASIC# should export to existing standards such as HTML, CSS, JavaScript, and later WebAssembly before any BASIC#/BSharp-native browser is considered. Performance is a first-class goal, but claims must be earned through validated backends rather than hype. This doctrine does not authorize licensing work, funding claims, OpenAI outreach, browser work, or implementation beyond the approved build scope.

Language grammar and runtime behavior belong in specifications and contracts, not duplicated as mutable Company Bible prose.

## 13. Image permission

Planning, questions, corrections, confirmations, visual descriptions, maps, cursor discussion, art direction, or object discussion are not permission to generate or edit an image.

Only generate or edit an image when Derek gives a clear direct command to make, create, draw, render, or edit that picture. Project work must not be mistaken for image-generation permission.

## 14. Attribution and outside analysis

For externally sourced code, assets, libraries, research, or tools, preserve when available:

- creator or organization;
- original title and source;
- license and version;
- acquisition date;
- modifications or integration notes.

Credit creators in good faith even when a license makes attribution optional. Do not claim a candidate source contributed to the active project when it was not actually used.

Development assistance may be credited as:

> Development assistance provided with ChatGPT by OpenAI.

Every meaningful outside audit, AI analysis, consultant report, or testing summary must be evaluated rather than blindly obeyed. Preserve the source or a faithful summary, verify claims against actual project evidence, and record accepted, modified, rejected, or deferred recommendations.

## 15. Shelved ownership and pricing principles

Commercialization is intentionally shelved while BASIC# is being built. No pricing, licensing, activation, payment, account, subscription, or edition-enforcement work begins without a future approved proposal.

The preserved future principles are:

- private/proprietary distribution remains under consideration;
- BASIC# Creator must offer a reasonably priced monthly option;
- annual billing may be an optional discount, never the only route;
- an eligible paid local compiler and IDE version remains usable permanently after the qualifying purchase terms are met;
- a one-time permanent purchase may also be offered;
- hosted services, continuing updates, cloud work, and support may remain subscriptions;
- BASIC# must not use Adobe-style loss of local tool access merely because payment stops.

These are future guardrails, not a current business model.

## 16. Rule conflicts and exceptions

No rule may be silently bypassed or reinterpreted because it is inconvenient.

When a rule genuinely blocks safe or necessary work:

1. identify the exact conflict;
2. explain why the work cannot proceed safely under the existing rule;
3. state the smallest exception requested;
4. state risks, alternatives, and affected files;
5. wait for Derek's explicit decision;
6. document an approved permanent change in this canonical Bible through a numbered build.

Conflict resolutions established by v0.1.25:

| Former conflict | Canonical resolution |
|---|---|
| Build immediately on first mention vs. prebuild approval | Exact proposal and explicit approval are required before implementation. |
| Immediate inclusion vs. scope control | Complete the approved scope; unapproved additions and silent deferrals are both forbidden. |
| Backups inside project vs. outside project | No backup copies inside the active project. Git and installer rollback are primary. |
| Routine extra backup vs. one download | One changed-files package by default; exceptional backup only when justified and separate. |
| Many handoffs vs. one cumulative handoff | Build handshake plus one active master handoff. |
| Loose checksum ban vs. package integrity | Hashes remain inside the manifest; no loose checksum file unless requested. |
| Warnings as failures vs. owner authority | Warnings fail normal validation; Derek may explicitly accept a documented exception. |
| Old owner-name variants | New records use Derek; historical records remain unchanged. |
| Game rules inside Company Bible | Demon Killer/Godot rules remain historical and do not govern BASIC#. |

## 17. v0.1.25 consolidation ledger

The following 74 former active-folder files were reviewed before consolidation. Their original bytes remain in Git history at commit `28e5b5b`.

| Former path | Disposition | Consolidation result |
|---|---|---|
| `docs/company_bible/BASIC_SHARP_COMPANY_BIBLE_CARRYOVER_v0_1_14.md` | MERGED | BASIC# authority, identity, explicit approval, packaging, validation, and Git workflow were carried into the canonical document. |
| `docs/company_bible/COMPANY_BIBLE_ADDENDUM_v0.1.87_No_Loose_Files.md` | MERGED | No-loose-files and direct project-relative packaging rules were retained. |
| `docs/company_bible/COMPANY_BIBLE_ADDENDUM_v0.1.88_NES_Overworld_Cell_Build_Safety.md` | MERGED IN PART | Surgical preservation of working systems was retained; NES map-cell and Main-scene instructions are Demon Killer history. |
| `docs/company_bible/COMPANY_BIBLE_DemonKiller.md` | MERGED IN PART | Company-wide workflow principles were retained; Demon Killer lore, controls, maps, scenes, art, gameplay, and Godot rules were retired from BASIC# authority. |
| `docs/company_bible/COMPANY_BIBLE_DemonKiller.md.meta` | RETIRED METADATA | Obsolete Godot import metadata has no function in the BASIC# documentation tree. |
| `docs/company_bible/DK_Godot_Company_Bible_Carryover_Note.md` | MERGED IN PART | Documentation, changed-files packaging, preservation, and explicit build authority were retained; Godot carryover wording was retired. |
| `docs/company_bible/DK_Godot_v0_1_13_Documentation_Record_Note.md` | MERGED IN PART | Thorough reconstructable history was retained; the game-engine journey remains historical project material. |
| `docs/company_bible/DK_Godot_v0_1_16_Immediate_Patch_Inclusion_Rule.md` | SUPERSEDED | Replaced by exact prebuild scope, explicit approval, and complete execution of the approved scope without silent deferral. |
| `docs/company_bible/DK_Godot_v0_1_17_Documentation_Discipline_Addendum.md` | MERGED | Same-build documentation discipline was retained. |
| `docs/company_bible/DK_Godot_v0_1_18_Immediate_Request_Completion_Reinforcement.md` | MERGED | Once exact scope is approved, the approved work must be completed or limitations disclosed before delivery. |
| `docs/company_bible/DK_Godot_v0_1_18_No_Image_Unless_Explicit_Rule.md` | MERGED IN PART | Direct image permission remains mandatory; Gaia and game-world rules were retired from BASIC# authority. |
| `docs/company_bible/DK_Godot_v0_1_19_FailedPatchRetry_Documentation_Rule.md` | MERGED | Failed or unapplied work must be re-carried, verified, and documented rather than assumed successful. |
| `docs/company_bible/DK_Godot_v0_1_20_Failed_Visual_Patch_Retry_Rule.md` | MERGED | Failed or unapplied work must be re-carried, verified, and documented rather than assumed successful. |
| `docs/company_bible/DK_Godot_v0_1_82_RESTORE_OLD_CELLS_KEEP_NEWMAP_VISIBLE_NO_MAP_REPLACEMENT_RULE.md` | RETIRED PROJECT-SPECIFIC | Demon Killer/Godot scene, map, door, control, visual, or world behavior is not active BASIC# company law. |
| `docs/company_bible/DK_Godot_v0_1_89_MAIN_INSURANCE_POLICY_ADDENDUM.md` | MERGED IN PART | Risk explanation and rollback planning were retained; Main.tscn-specific backup instructions were retired. |
| `docs/company_bible/DK_Godot_v0_1_90_VERSIONING_AND_MAIN_SAFETY_ADDENDUM.md` | MERGED IN PART | Numeric version progression and rollback discipline were retained; Main.tscn rules were retired. |
| `docs/company_bible/DK_Godot_v0_1_91_DOOR_NAMING_AND_MAIN_UID_SAFETY_ADDENDUM.md` | RETIRED PROJECT-SPECIFIC | Demon Killer/Godot scene, map, door, control, visual, or world behavior is not active BASIC# company law. |
| `docs/company_bible/DK_Godot_v0_1_92_PROJECT_IDENTITY_RULE_ADDENDUM.md` | MERGED IN PART | Complete active version identity was retained; Godot-specific surfaces and historical version-territory rules were retired. |
| `docs/company_bible/DK_Godot_v0_2_01_VERSION_DISPLAY_AND_BACKUP_TITLE_RULE_ADDENDUM.md` | MERGED IN PART | Complete active version identity was retained; Godot-specific surfaces and historical version-territory rules were retired. |
| `docs/company_bible/DK_Godot_v0_2_02_ZERO_TWO_TERRITORY_AND_VERSION_HABIT_ADDENDUM.md` | MERGED IN PART | Complete active version identity was retained; Godot-specific surfaces and historical version-territory rules were retired. |
| `docs/company_bible/DK_Godot_v0_2_04_DOOR_TEMPLATE_CREATE_FIX_ADDENDUM.md` | RETIRED PROJECT-SPECIFIC | Demon Killer/Godot scene, map, door, control, visual, or world behavior is not active BASIC# company law. |
| `docs/company_bible/DK_Godot_v0_2_05_DOOR_TEMPLATE_COPY_AND_STALE_LINK_FIX_ADDENDUM.md` | RETIRED PROJECT-SPECIFIC | Demon Killer/Godot scene, map, door, control, visual, or world behavior is not active BASIC# company law. |
| `docs/company_bible/DK_Godot_v0_2_06_DOOR_TEMPLATE_PASTE_NORMALIZER_ADDENDUM.md` | RETIRED PROJECT-SPECIFIC | Demon Killer/Godot scene, map, door, control, visual, or world behavior is not active BASIC# company law. |
| `docs/company_bible/DK_Godot_v0_2_06_PRE_DRAW_ORDER_BACKUP_HANDSHAKE_COMPANY_BIBLE_NOTE.md` | MERGED IN PART | Build handshakes and rollback records were retained; draw-order and scene-backup details were retired. |
| `docs/company_bible/DK_Godot_v0_2_07_CELL_DOOR_DRAW_ORDER_FIX_ADDENDUM.md` | RETIRED PROJECT-SPECIFIC | Demon Killer/Godot scene, map, door, control, visual, or world behavior is not active BASIC# company law. |
| `docs/company_bible/DK_Godot_v0_2_08_DOOR_LINK_NO_DUPLICATE_FIX_ADDENDUM.md` | RETIRED PROJECT-SPECIFIC | Demon Killer/Godot scene, map, door, control, visual, or world behavior is not active BASIC# company law. |
| `docs/company_bible/DK_Godot_v0_2_08_PACKAGE_STRUCTURE_AND_BACKUP_RULES_ADDENDUM.md` | MERGED | Direct-root packages, organized records, no loose checksum files, and external exceptional backups were retained. |
| `docs/company_bible/DK_Godot_v0_2_09_PROJECT_VERSION_OPEN_SCREEN_FIX_ADDENDUM.md` | RETIRED PROJECT-SPECIFIC | No active BASIC# company-wide rule was required from this Demon Killer/Godot-specific record. |
| `docs/company_bible/DK_Godot_v0_2_10_SPRITE_PLAYER_BODYRECT_HOTFIX_ADDENDUM.md` | RETIRED PROJECT-SPECIFIC | Demon Killer/Godot scene, map, door, control, visual, or world behavior is not active BASIC# company law. |
| `docs/company_bible/DK_Godot_v0_2_11_DOOR_CLEANUP_HOTFIX_ADDENDUM.md` | RETIRED PROJECT-SPECIFIC | Demon Killer/Godot scene, map, door, control, visual, or world behavior is not active BASIC# company law. |
| `docs/company_bible/DK_Godot_v0_2_12_DOOR_ORPHAN_CLEANUP_HOTFIX_ADDENDUM.md` | RETIRED PROJECT-SPECIFIC | Demon Killer/Godot scene, map, door, control, visual, or world behavior is not active BASIC# company law. |
| `docs/company_bible/DK_Godot_v0_2_14_DOOR_COPY_PROMOTION_HOTFIX_ADDENDUM.md` | RETIRED PROJECT-SPECIFIC | Demon Killer/Godot scene, map, door, control, visual, or world behavior is not active BASIC# company law. |
| `docs/company_bible/DK_Godot_v0_2_15_DOOR_COPY_UNDO_LINK_HOTFIX_ADDENDUM.md` | RETIRED PROJECT-SPECIFIC | Demon Killer/Godot scene, map, door, control, visual, or world behavior is not active BASIC# company law. |
| `docs/company_bible/DK_Godot_v0_2_17_NO_IN_PROJECT_SCENE_BACKUPS_REPAIR_ADDENDUM.md` | MERGED IN PART | No backup copies inside the active project was retained; scene-specific repair details were retired. |
| `docs/company_bible/DK_Godot_v0_2_33_BUILD_RESPONSE_BOILERPLATE_CLEANUP_ADDENDUM.md` | MERGED | Repeated generic limitation boilerplate remains prohibited unless materially relevant. |
| `docs/company_bible/DK_Godot_v0_2_35_MAIN_CHANGE_APPROVAL_AND_VERSION_VISIBILITY_ADDENDUM.md` | MERGED IN PART | Exact scope approval and documented rule exceptions were retained; Main.tscn-specific approval was retired. |
| `docs/company_bible/DK_Godot_v0_2_38_SEPARATE_BACKUP_DISCRETION_AND_PACKAGE_SEPARATION_ADDENDUM.md` | SUPERSEDED | Git plus installer rollback is primary; only exceptional, explained backups may be separate from the main package. |
| `docs/company_bible/DK_Godot_v0_2_44_ATTRIBUTION_BEYOND_LEGAL_MINIMUM_ADDENDUM.md` | MERGED | Provenance and good-faith creator attribution were retained. |
| `docs/company_bible/DK_Godot_v0_2_81_CAMERA_ZOOM_CONTROL_ADDENDUM.md` | RETIRED PROJECT-SPECIFIC | Demon Killer/Godot scene, map, door, control, visual, or world behavior is not active BASIC# company law. |
| `docs/company_bible/DK_Godot_v0_2_82_BIBLE_FIRST_THEN_ASK_DEREK_ADDENDUM.md` | MERGED | Read the canonical Bible and current records before asking Derek to repeat documented decisions. |
| `docs/company_bible/DK_Godot_v0_2_85_NUMERIC_ONLY_VERSIONING_ADDENDUM.md` | MERGED | Next-unused numeric versioning and prohibition of letter suffixes were retained. |
| `docs/company_bible/DK_Godot_v0_2_88_VERSIONED_DELIVERABLE_ARCHIVE_NAME_ADDENDUM.md` | MERGED | Every user-facing deliverable must identify its numeric version. |
| `docs/company_bible/DK_Godot_v0_2_90_SEQUENTIAL_BUILD_EXECUTION_ADDENDUM.md` | MERGED | One build at a time was retained. |
| `docs/company_bible/DK_Godot_v0_2_96_NO_ORPHAN_TOOL_TEST_FILES_AND_ALWAYS_DOCUMENT_ADDENDUM.md` | MERGED | No orphan tools/tests and same-build documentation were retained. |
| `docs/company_bible/DK_Godot_v0_2_97_DK_LIVE_BUILDER_EXACT_MENU_NAME_ADDENDUM.md` | RETIRED PROJECT-SPECIFIC | Demon Killer/Godot scene, map, door, control, visual, or world behavior is not active BASIC# company law. |
| `docs/company_bible/DK_Godot_v0_2_98_APPROVED_MAIN_MENU_ART_LOCK_ADDENDUM.md` | RETIRED PROJECT-SPECIFIC | Demon Killer/Godot scene, map, door, control, visual, or world behavior is not active BASIC# company law. |
| `docs/company_bible/DK_Godot_v0_3_02_FAITH_MAP_AND_BUILDING_LAYERING_ADDENDUM.md` | RETIRED PROJECT-SPECIFIC | Demon Killer/Godot scene, map, door, control, visual, or world behavior is not active BASIC# company law. |
| `docs/company_bible/DK_Godot_v0_3_04_PRACTICAL_ARCHITECTURE_AND_TOOLCHAIN_ADDENDUM.md` | MERGED IN PART | Practical, maintainable, systems-first architecture was retained; Godot toolchain specifics were retired. |
| `docs/company_bible/DK_Godot_v0_3_05_ORIGINAL_PERSISTENT_SERVER_ARCHITECTURE_ADDENDUM.md` | RETIRED PROJECT-SPECIFIC | Demon Killer server architecture belongs in that project technical record, not BASIC# company law. |
| `docs/company_bible/DK_Godot_v0_3_09_STREAMING_REGION_CELL_AND_HOUSE_SPELLING_ADDENDUM.md` | RETIRED PROJECT-SPECIFIC | Demon Killer/Godot scene, map, door, control, visual, or world behavior is not active BASIC# company law. |
| `docs/company_bible/DK_Godot_v0_3_23_LIVE_BUILDER_LOCAL_VALIDATION_ADDENDUM.md` | MERGED IN PART | Validate with the strongest available tools and record limits; Live Builder specifics were retired. |
| `docs/company_bible/DK_Godot_v0_3_31_CODE_FIRST_MIGRATION_AND_VISUAL_BOUNDARY_ADDENDUM.md` | MERGED IN PART | Behavioral contracts and systems-first migration were retained; game visual-boundary details were retired. |
| `docs/company_bible/DK_Godot_v0_3_32_COMPANY_BIBLE_PREBUILD_CHECKLIST_ENFORCEMENT_ADDENDUM.md` | MERGED | Exact prebuild proposal, owner approval, and stop behavior were retained. |
| `docs/company_bible/DK_Godot_v0_3_34_LIVE_BUILDER_PROJECT_MODE_VALIDATION_ADDENDUM.md` | MERGED IN PART | Validate with the strongest available tools and record limits; Live Builder specifics were retired. |
| `docs/company_bible/DK_Godot_v0_3_35_EXACT_ENGINE_VALIDATION_AND_CONSTANT_EXPRESSION_ADDENDUM.md` | MERGED IN PART | Exact supported-tool validation and safe constants were generalized; Godot details were retired. |
| `docs/company_bible/DK_Godot_v0_3_36_BOUNDED_VALIDATION_SAFETY_ADDENDUM.md` | MERGED | Validation must be bounded, deterministic, and non-destructive. |
| `docs/company_bible/DK_Godot_v0_3_37_WINDOWS_SAFE_VALIDATION_TELEMETRY_ADDENDUM.md` | MERGED IN PART | Portable, non-destructive validation and useful reporting were retained; Windows/Godot telemetry specifics were retired. |
| `docs/company_bible/DK_Godot_v0_3_38_INVISIBLE_REGION_BOUNDARY_RULE_ADDENDUM.md` | RETIRED PROJECT-SPECIFIC | Demon Killer/Godot scene, map, door, control, visual, or world behavior is not active BASIC# company law. |
| `docs/company_bible/DK_Godot_v0_3_45_AUTOMATED_PLAYTEST_PILOT_AND_REPORTING_ADDENDUM.md` | MERGED IN PART | Automated evidence supplements owner testing; Test Pilot specifics were retired. |
| `docs/company_bible/DK_Godot_v0_3_46_CUMULATIVE_THREAD_HANDOFF_AND_CONTINUITY_LOGGING_ADDENDUM.md` | MERGED | One cumulative master handoff and its completion gate were retained. |
| `docs/company_bible/DK_Godot_v0_3_47_DEMON_KILLER_VISUAL_STYLE_AND_COMPACT_PANEL_ADDENDUM.md` | RETIRED PROJECT-SPECIFIC | Demon Killer/Godot scene, map, door, control, visual, or world behavior is not active BASIC# company law. |
| `docs/company_bible/DK_Godot_v0_3_48_OWNER_CONTRIBUTOR_AND_ATTRIBUTION_CLARITY_ADDENDUM.md` | MERGED | Derek is the canonical owner name; historical names and honest contributor roles remain preserved. |
| `docs/company_bible/DK_Godot_v0_3_57_BUILD_THE_GAME_WE_WANT_ADDENDUM.md` | MERGED IN PART | Owner vision outranks committee design; Demon Killer product specifics were retired. |
| `docs/company_bible/DK_Godot_v0_3_69_MIT_INTEGRATION_AND_VISIBLE_UI_RULE_ADDENDUM.md` | MERGED IN PART | Third-party provenance and visible, testable integration were retained; game UI specifics were retired. |
| `docs/company_bible/DK_Godot_v0_3_73_CANONICAL_HANDOFF_COMPLETION_REPAIR_ADDENDUM.md` | MERGED | One cumulative master handoff and its completion gate were retained. |
| `docs/company_bible/DK_Godot_v0_3_77_BUILD_INTEGRATOR_BACKUP_AUTHORITY_ADDENDUM.md` | SUPERSEDED | BASIC# uses Git and installer rollback as primary recovery authorities; routine duplicate backup archives are prohibited. |
| `docs/company_bible/DK_Godot_v0_4_14_WARNING_HYGIENE_AND_SYSTEMS_FIRST_ADDENDUM.md` | MERGED | Systems-first development and warnings-as-failures by default were retained. |
| `docs/company_bible/DK_Godot_v0_4_20_PREBUILD_SCOPE_PREAPPROVAL_AND_STOP_RULE_ADDENDUM.md` | MERGED | Exact prebuild proposal, owner approval, and stop behavior were retained. |
| `docs/company_bible/DK_Godot_v0_4_21_AUDIT_TRAIL_NO_SCRUB_RULE_ADDENDUM.md` | MERGED | Failures and corrections remain permanent evidence rather than being silently scrubbed. |
| `docs/company_bible/DK_Godot_v0_4_37_PATCH_MANIFEST_SCHEMA_AND_ENVIRONMENT_LIMITATION_ADDENDUM.md` | MERGED IN PART | Manifest schema verification and honest environment limits were retained using the BASIC# manifest identity. |
| `docs/company_bible/DK_Godot_v0_4_38_GAIA_STREAMING_CELL_AND_IMAGE_PERMISSION_ADDENDUM.md` | MERGED IN PART | Direct image permission remains mandatory; Gaia and game-world rules were retired from BASIC# authority. |
| `docs/company_bible/DK_Godot_v0_4_70_POST_BUILD_GIT_AND_NO_HARD_GATE_RULE_ADDENDUM.md` | MERGED | Post-acceptance commit/tag and Derek-over-tools authority were retained; documented exceptions remain owner-controlled. |
| `docs/company_bible/PROJECT_BIBLE_DemonKiller.md` | RETIRED POINTER | Retired Demon Killer pointer file is preserved in Git history and has no BASIC# authority. |
| `docs/company_bible/PROJECT_BIBLE_DemonKiller.md.meta` | RETIRED METADATA | Obsolete Godot import metadata has no function in the BASIC# documentation tree. |

## 18. Protected BASIC# visual grammar

The current creator-facing landmarks are `PLAYER` for the built-in player, `#name` for a Kind, `@name` for one particular object, `(word` for an action, `|then` for a result, `//` and `/.` for comments, `[` to open a Body, and `].` to close it. The canonical current Heads are `KINDS`, `DEFINE`, `START`, `WHEN`, `IF`, `OTHERWISE`, `CONTROLS`, `HOVER`, and `CONTEXT`. An IF may join complete conditions with only `and` or only `or`; mixed connectors, nesting, and programming-precedence rules are intentionally outside Profile 6. `OTHERWISE` may directly follow an IF block to form one Profile 7 two-sided reactive rule. BASIC# uses IF / OTHERWISE, never IF / ELSE. A syntax change requires a separately approved build and migration diagnostics.

## 19. Future Company Bible maintenance

The active folder must contain exactly one file:

```text
docs/company_bible/BASIC_SHARP_COMPANY_BIBLE.md
```

The integrity audit is:

```bash
ruby tools/company_bible_audit.rb
```

A future package fails Bible integrity when it creates a second file in this folder, revives a retired addendum as active authority, omits mandatory sections, or points current records at a superseded Bible path.

- The small compiler subset parser lane is governed by `spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_PARSER_v1.json`, `docs/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_PARSER_v0_1_49.md`, and `compiler/small_compiler_subset_parser.rb`. It parses deterministic subset records from TokenizerReader output and compares them against the Ruby Parser referee. It is not the production parser authority and does not permit self-hosting claims, Profile 8, new syntax, runtime changes, web export, browser work, engine bridge, or Ruby retirement.
- The small compiler subset IR emitter lane is governed by `spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_IR_EMITTER_v1.json`, `docs/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_IR_EMITTER_v0_1_50.md`, and `compiler/small_compiler_subset_ir_emitter.rb`. It emits BSharp IR from small compiler subset parser records and compares that output against the Ruby Parser plus SemanticResolver referee. It is not the production compiler path and does not permit self-hosting claims, Profile 8, new syntax, runtime changes, BSharp Bytecode changes, web export, browser work, engine bridge, or Ruby retirement.


### v0.1.51 Small Compiler Subset IR Golden Parity Harness

- The small compiler subset IR golden parity harness lane is governed by `spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_IR_PARITY_HARNESS_v1.json`, `docs/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_IR_PARITY_HARNESS_v0_1_51.md`, and `compiler/small_compiler_subset_ir_parity_harness.rb`. It locks deterministic BSharp IR SHA256 digests for sealed small compiler subset fixtures and compares them against the Ruby Parser plus SemanticResolver referee. It is not the production compiler path and does not permit self-hosting claims, Profile 8, new syntax, runtime changes, BSharp Bytecode changes, web export, browser work, engine bridge, or Ruby retirement.


### v0.1.58 Small Compiler Subset Error Contract

- The small compiler subset plain-English error contract lane is governed by `spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_ERROR_CONTRACT_v1.json`, `docs/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_ERROR_CONTRACT_v0_1_52.md`, and `compiler/small_compiler_subset_error_contract.rb`. It locks stable error IDs, line numbers, severities, creator-facing explanations, and source diagnostics for invalid small compiler subset examples. It is not the production compiler path and does not permit self-hosting claims, Profile 8, new syntax, runtime changes, BSharp Bytecode changes, web export, browser work, engine bridge, or Ruby retirement.


## 20. Five Point Paradigm

The BASIC# Five Point Paradigm is the five-point decision system for deciding whether work is still on mission.

At the centre:

```text
Turn human intent into real software behaviour.
```

A BASIC# direction is healthy only when it serves all five points:

1. **Huge Human Problem** - most people can imagine software they cannot build because programming is still locked behind syntax, tooling rituals, and machine-facing errors.
2. **Radical Human Bridge** - BASIC# lets creators describe what should happen in protected plain-English structure, then lets the compiler and runtime translate that intent into software behaviour.
3. **Breakthrough Machine** - the project must contain real machinery under the words: reader, tokenizer, parser, BSharp IR, bytecode, runtime, virtual machine, Save, ASK, contracts, and validation.
4. **Proof Under Fire** - every accepted build must be proven by tests, contracts, fixture hashes, golden parity, rollback installers, Trial by Fire, clean Git state, and warnings-as-failures validation.
5. **Creator Ownership** - BASIC# must protect creators from lock-in, hostile pricing, and Adobe-style loss of local tool access. Compatibility before conquest and creator ownership remain product law.

Moonshot language says to aim high. The Five Point Paradigm says to aim high, prove every step, and keep the creator from being sacrificed to the machine.

## 21. Documentation Map

The canonical BASIC# documentation map is:

```text
docs/BASIC_SHARP_DOCUMENTATION_MAP.md
```

The map is the front door to the documentation library. It does not replace the Company Bible, roadmap, handoff, specifications, validation inventory, changelogs, patch notes, or session logs. It tells future readers where those records live and what order to read them in.

The documentation stack should remain a navigable library, not an unindexed dragon hoard. New major documentation areas must either be listed in the map or intentionally explained elsewhere in the same accepted build.


### v0.1.58 Small Compiler Subset Scene/Block Expansion

- The small compiler subset scene/block expansion lane is governed by `spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_SCENE_BLOCK_EXPANSION_v1.json`, `docs/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_SCENE_BLOCK_EXPANSION_v0_1_53.md`, and `compiler/small_compiler_subset_scene_block_expansion.rb`.
- It expands the sealed subset to larger ordered scene/block fixtures while Ruby remains the production parser, resolver, compiler path, and referee.
- It is not the production compiler path and does not permit self-hosting claims, Profile 8, new syntax, runtime changes, BSharp Bytecode changes, web export, browser work, engine bridge, or Ruby retirement.


Symbol table contract spec: `spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_SYMBOL_TABLE_CONTRACT_v1.json`.


ByteTide decision record: the name was considered as a creator-facing metaphor for bytecode flow, then passed on for now. Official system terms remain bytecode and BSBC.

Reference: `docs/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_SYMBOL_TABLE_CONTRACT_v0_1_54.md`.


## v0.1.58 Symbol Table Contract and ByteTide Decision

The v0.1.58 lane adds `compiler/small_compiler_subset_symbol_table_contract.rb`, `spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_SYMBOL_TABLE_CONTRACT_v1.json`, and `docs/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_SYMBOL_TABLE_CONTRACT_v0_1_54.md`.

ByteTide decision record: ByteTide was considered as a creator-facing metaphor for bytecode flow, then passed on. BASIC# keeps bytecode and BSBC as official system terms. This is a documentation decision only, not a rename.


### v0.1.58 small compiler subset BSBC emission

BASIC# v0.1.58 adds the first small compiler subset lane that emits real BSBC bytecode under Ruby referee control. It proves source -> BSharp IR -> BSBC bytes -> bytecode loader for sealed fixtures without replacing Ruby and without claiming BASIC# is self-hosted.

Reference: `spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_BSBC_EMITTER_v1.json`.
Reference: `docs/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_BSBC_EMITTER_v0_1_55.md`.

Reference: `compiler/small_compiler_subset_bsbc_emitter.rb`.


### v0.1.58 small compiler subset BSBC golden parity

BASIC# v0.1.58 adds the BSBC Golden Parity Harness under Ruby referee control. It locks approved subset source -> BSharp IR -> BSBC bytes -> bytecode loader summaries against sealed golden expectations without replacing Ruby and without claiming BASIC# is self-hosted.

Reference: `spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_BSBC_PARITY_HARNESS_v1.json`.
Reference: `docs/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_BSBC_PARITY_HARNESS_v0_1_56.md`.

Reference: `compiler/small_compiler_subset_bsbc_parity_harness.rb`.


## v0.1.58 Self-Hosting Fixture Corpus

- Spec: `spec/self_hosting/BASIC_SHARP_SELF_HOSTING_FIXTURE_CORPUS_v1.json`
- Doc: `docs/self_hosting/BASIC_SHARP_SELF_HOSTING_FIXTURE_CORPUS_v0_1_57.md`
- Implementation: `compiler/self_hosting_fixture_corpus.rb`
- Tool: `tools/self_hosting_fixture_corpus.rb`
- Test: `tests/test_self_hosting_fixture_corpus.rb`
- DKLab is retained as the internal workspace and lab name in homage to Demon Killer. Elderred Softworks LLC remains the official company identity.
## v0.1.58 Small Compiler Subset Runtime Smoke Rule

`spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_RUNTIME_SMOKE_v1.json`, `docs/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_RUNTIME_SMOKE_v0_1_58.md`, and `compiler/small_compiler_subset_runtime_smoke.rb` are protected self-hosting artifacts. The runtime smoke lane proves selected subset fixtures can enter the verifying runtime, run deterministic smoke events, snapshot, and save under Ruby referee control. It must not claim BASIC# is self-hosted, must not replace Ruby, must not add Profile 8, and must not change production runtime behaviour.

