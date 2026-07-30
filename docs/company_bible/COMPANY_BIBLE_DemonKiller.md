# DEMON KILLER COMPANY BIBLE

**Version:** v0.6.99  
**Godot terminology update:** v0.2.72 Tapestry naming rule  
**Status:** Mandatory project policy  
**Scope:** All DK / Demon Killer Stable and Test Center builds  

This is not a suggestion document. This is the Company Bible.

Every build, patch, repair, helper, AI assistant, programmer, tester, and future contributor must follow these company/workflow rules unless the project owner explicitly overrides them.

---

## 0A. Build the Game We Want to Play

Demon Killer is not designed by committee for the broadest possible audience. Build the game Derek and the team genuinely want to play. Preserve deliberate old-school depth, difficulty, atmosphere, practical systems, and unusual ideas instead of sanding them away for hypothetical mass appeal. Accessibility may remove needless barriers, but it must not hollow out the game. If other players connect with Demon Killer, they are welcome; universal approval is not the authority.

## 1. Do Not Replace Working ST Maps

**Never replace the Stable/ST map unless explicitly ordered.**

ST is the playable main-game path. It must preserve the current working map, player movement, hut, village layout, and known test flow.

Bad:

- replacing the ST scene with a blank emergency scene
- adding fake placeholder buildings over the old map
- wiping the village layout to solve a script problem
- rebuilding ST from scratch without permission

Correct:

- repair scripts
- preserve the existing map
- patch only the broken system
- keep the player’s current tested route intact

---

## 2. ST Is Stable, TS Is Crazy

**ST = stable main game path.**  
**TS = test kitchen.**

Crazy features go into TS first.

Examples for TS:

- giant water strider mounts
- lightning strike lottery death
- punishing bird enemies
- weird book rooms
- dangerous debug experiments
- prototype combat systems

Features only migrate to ST after testing.

---

## 3. Changed Files Only by Default

Default package:

**Changed-files-only ZIP.**

Do not provide a full project ZIP unless explicitly requested. When the owner says “full build,” make a full project ZIP for that build only.

Do not offer multiple competing downloads unless there is a clear emergency reason. One main link is preferred.

---

## 4. Document Everything

Every patch/build needs:

- version number
- changelog
- session/development log
- Company Bible update when a mandatory workflow/company rule changes
- Tapestry update only when world lore, mythology, history, people, places, beliefs, symbols, dreams, or story truth is affected
- dedicated design/system documentation when gameplay mechanics or technical systems change
- updated hotkey/control list when controls change
- clear reason for the change
- what files changed
- what should be tested

The Company Bible is the authority for mandatory company/workflow rules. The Tapestry holds DK world lore and story truth. Dedicated design/system documents hold gameplay mechanics and technical system rules. Neither the Tapestry nor design documents replace the Company Bible.

No mystery patches.

---

## 4B. Build On The First Ask And Batch The Whole Confirmed Set

When the owner asks for a patch or build, make it on the first ask. Do not wait for the second or third request.

If the owner reports several bugs, feature corrections, or rule updates while a build is pending, include the whole accumulated confirmed batch unless he explicitly says to stop, split it, or hold one item.

Preferred process:

```text
Read the current request and the recent locked project rules
Use the Company Bible, Tapestry, and relevant design/system documents before asking the owner to repeat himself
Collect the confirmed bugs/features/rule updates
Patch them together in one clean version
Document the complete set
Test/verify as much as possible
```

Ask the owner to repeat himself only when absolutely necessary to avoid damaging the project.

One-issue patches are allowed only when necessary to unblock the project, fix a red compile error, repair a dangerous build break, or when explicitly ordered.

---

## 4C. Working, Stable Code Beats Conventional Purity

DK code does not need to impress outside critics or follow fashionable architecture if that makes the project weaker.

The priority order is:

```text
1. It works.
2. It does not break existing systems.
3. It is understandable enough for us to repair later.
4. It is documented in the build notes when it changes project rules.
5. Conventional elegance comes last.
```

Unconventional code is acceptable when it is practical, stable, and contained.

Bad:

- rewriting a working system just to make it look prettier
- removing compatibility shims because they offend code style
- breaking menus, controls, maps, or saves in the name of elegance

Correct:

- keep the working bridge if it protects the project
- add compatibility shims when old builders still need old names
- document the odd-looking parts so future work knows why they exist
- prefer reliable repairs over theoretical purity

Simple rule: if it works and does not break other things, it is allowed. If it is pretty but breaks DK, it is garbage.

## 4C-1. Systems First, Graphics Later

Demon Killer is a systems-first project. The foundation must work before the surface is made pretty. A rough fishing system that actually lets the player fish is better than a beautiful fishing scene with no working fishing logic. A square, triangle, placeholder sprite, or ugly debug panel is acceptable when it proves the real mechanic.

Priority order for foundation work:

```text
1. Player/world state survives save and Continue.
2. Core mechanics actually function.
3. Validation proves the mechanic.
4. The system is documented and repairable.
5. Visual polish, final art, and presentation come later.
```

Do not spend build budget making a scene look finished while the underlying mechanic is fake, missing, or untested. DK is allowed to look rough during foundation work. It is not allowed to pretend a system exists when it does not.

## 4C-2. Warning Goblins Are Not Cosmetic

Compiler and GDScript warnings reported by Derek are project Goblins. They must be logged, repaired when safe, and blocked from quietly becoming normal debt.

The v0.4.14 warning-hygiene intake specifically records these reported warnings as mandatory repair examples:

```text
DKDirectionalPlayerVisual.gd: _frame_index_for_action_phase(kind, phase) had an unused kind parameter.
DKSaveManager.gd: local DKSaveContinueReadinessContract preload constant shadowed the global class_name.
```

If a warning is intentionally left in place, the reason must be documented in the session log and validation notes. Silent warning piles are not allowed.

---

## 4D. Company Bible Is Not The Tapestry Or Gameplay Design Archive

The Company Bible is for how the project is run. It is not the storage place for detailed gameplay/lore systems.

Belongs here:

- build/patch workflow
- packaging rules
- coding philosophy
- menu/documentation discipline
- ST/TS governance
- assistant/contributor behaviour
- hotkey documentation requirements

Does not belong here except as short references:

- ghost realm rules
- well willow lore
- torch gameplay tuning
- aura/living/spirit realm systems
- blight causes/symptoms
- region/object/person/place lore

World-lore details belong in the Tapestry. Gameplay and technical behaviour belong in dedicated design/system documents.

### Tapestry Naming Rule

The world-lore archive formerly called the CODEX is now called the **Tapestry**.

The Tapestry is for:

- world lore
- mythology and spiritual truths
- history
- people and places
- beliefs and symbols
- dreams that become canonical DK material
- story facts and narrative continuity

Routine asset credits, licences, manifests, changelogs, session records, and technical implementation notes do not belong in the Tapestry. Put those in their proper project records. Existing historical CODEX files remain preserved as archive history.

---

## 4E. ChatGPT / Unity Editor Reality Rule

ChatGPT cannot directly edit inside the Unity Editor. Do not make the owner hear this repeated every patch like a busted tavern bard.

What ChatGPT can do:

- inspect uploaded project files
- patch scripts, scenes, settings, docs, and metadata files
- produce changed-files-only ZIP packages
- attempt command-line validation/build steps only when the local environment actually has the needed Unity tooling

What ChatGPT cannot do from this environment:

- click around inside Derek's Unity Editor
- visually inspect Derek's live Hierarchy/Inspector unless screenshots/files are provided
- guarantee an Editor build if Unity is not installed in the execution environment

Say the limitation once when it matters, then move on and patch the files.

---

## 4F. Goblins Means Project Problems

For Demon Killer project work, call bugs, smell trails, weird inconsistencies, duplicate-scene junk, stale labels, or suspicious tool behavior **Goblins**.

This is workflow language, not automatic gameplay lore. Actual goblin lore belongs in the Tapestry; enemy mechanics belong in dedicated design notes.

Good:

- "Found the label Goblin."
- "This rebuild Goblin is coming from duplicate generated roots."
- "The input Goblin is left mouse still feeding attack."

Bad:

- calling them smell trails when the owner asked for Company Bible terminology
- inventing new goblin lore because the workflow word exists

---

## 4G. One Canonical Cumulative Thread Handoff Is Mandatory

Every numbered DK build, update, patch, hotfix, repair, tool release, validation package, and equivalent deliverable must update the single canonical cumulative thread handoff:

```text
docs/hand_off/DK_MASTER_THREAD_HANDOFF.md
```

Do not create a new stand-alone handoff file for each future version. Existing historical handoff files remain preserved as read-only project history, but v0.3.46 establishes the master document as the only active handoff authority.

The master handoff must always contain two layers:

1. **Current Transfer State at the top.** Rewrite this section for the current build so a fresh thread can immediately identify the exact version, completed work, unfinished work, known Goblins, validation status, changed files, protected boundaries, owner decisions, and next action.
2. **Cumulative History below.** Append a dated and versioned entry for every deliverable. Never erase or silently rewrite older history.

A numbered deliverable is incomplete until the master handoff has been updated and included in the package. This requirement exists because a platform thread may reach its maximum length without enough warning to reconstruct active work safely. DK fights continuity loss with records, not memory.

The master handoff supplements rather than replaces the changelog, patch notes, session log, changed-files record, validation report, system records, or manifests. Each record keeps its own job.

The assistant must not claim to control thread cutoffs or know an exact number of replies remaining when the platform does not expose that information. When a transition warning appears, the latest master handoff is the recovery authority.

## 4H. All Concept Art Must Use the Defined Demon Killer Visual Style

Every new Demon Killer concept-art image must use the **Demon Killer Iron-and-Ember visual style**. The words “in the DK style” are not enough by themselves because they can be interpreted too broadly. Every art request, brief, prompt, review, and approval must use the concrete definition below.

### Demon Killer Iron-and-Ember style definition

Demon Killer concept art is **grounded late-medieval dark fantasy rendered with hand-painted, rough-edged realism**. It combines a practical frontier world with severe biblical and spiritual horror. The image should feel old, weathered, dangerous, solemn, and physically believable rather than glossy, fashionable, or theatrical for its own sake.

Required visual language:

- strong readable silhouettes and human-scale physical weight;
- battered iron, tarnished bronze, worn leather, rough timber, cracked stone, mud, linen, bone, ash, smoke, rain, and age;
- a restrained earth-and-iron palette built from soot black, umber, moss, bone, rust, dried-blood red, and dirty neutral colors;
- controlled supernatural accents, especially amber fire, lightning-white flashes, and cold ghost-blue or moonlit shadows;
- dramatic chiaroscuro with believable light sources, fog, embers, dust, weather, and deep atmosphere;
- practical medieval clothing, tools, armor, buildings, and weapons that look used rather than manufactured for a showroom;
- demons that feel ancient, predatory, corrupted, and spiritually wrong rather than cute, glamorous, or cartoonish;
- angels and Light-aligned beings that feel severe, awe-inspiring, morally weighty, and dangerous rather than soft decorative figures;
- compositions clear enough to guide the game’s top-down pixel-art production assets, animation silhouettes, maps, props, and lighting.

Forbidden drift unless Derek explicitly approves an exception:

- anime, chibi, cel-shaded, superhero, or comic-book styling;
- glossy modern-MMO armor, excessive ornamental clutter, or giant impractical weapons with no lore reason;
- neon cyberpunk colors, clean plastic surfaces, modern clothing, or science-fiction machinery presented as ordinary DK material;
- generic smooth “AI fantasy” polish with waxy faces, meaningless detail, or perfect showroom symmetry;
- direct copying of another game, film, artist, character, or copyrighted design;
- empty shock art, sexualized demons, or gore that exists only to substitute for atmosphere and story.

High-resolution concept art may be painterly, but the final in-game translation must retain the same silhouettes, materials, palette, lighting logic, and atmosphere in deliberate hand-authored pixel art. The current full guide is:

```text
res://docs/art_direction/DK_DEMON_KILLER_VISUAL_STYLE_GUIDE_v0_3_47.md
```

Art that does not visibly match this definition is not approved Demon Killer concept art merely because it carries the DK name.
## 4I. Canonical Owner Name, Contributor Roles, and Attribution Clarity

All new Demon Killer records must use **Derek** as the canonical name for the owner and primary developer.

Historical records may refer to Derek as **Dick**. Those references are not evidence of a second owner or developer and must not be described as false merely because the preferred current record name is Derek. Preserve historical records as written. Use Derek consistently in new Company Bible entries, handoffs, changelogs, session logs, reports, credits, manifests, and build records so outside auditors do not miscount contributors.

The active project roster is:

- **Derek:** owner and primary developer;
- **Andy:** human consultant and bug tester;
- **Cooper Scheer:** human consultant and bug tester;
- **ChatGPT:** current AI contributor, coding/integration/documentation lane;
- **Grok:** original AI contributor used to begin the project and a current outside contributor/advisor;
- **Claude:** current AI contributor and outside analytical/audit advisor;
- **GitHub Copilot:** past AI contributor, credited historically rather than listed as active.

**Idyl / IdylOnTV** is a major external design inspiration, especially for examining what should and should not be brought into a game. Inspiration credit is not the same as project contributor credit. Do not list Idyl as a DK contributor unless Derek explicitly changes that relationship.


Contributor and acknowledgement details belong in the dedicated credits record. This Company Bible section governs naming and role clarity only.

## 4J. Every Outside Analysis Must Be Logged and Evaluated

Every outside analysis, audit, critique, consultant report, AI review, bug-test summary, or advisory recommendation must be logged after it is read. No outside report may be silently consumed and discarded.

The permanent record must identify:

- source and contributor;
- date received;
- project version examined;
- original report or a faithful preserved copy when practical;
- major claims and recommendations;
- verified findings;
- unverified, speculative, or inaccurate claims;
- decisions accepted, modified, rejected, or deferred;
- build action or explicit no-action result.

Outside confidence is not project truth. A script name, addon folder, prototype, or design intention does not prove that a feature is active in production gameplay. The Company Bible, actual project files, runtime evidence, validation reports, owner decisions, and accepted build records remain the authority.

External AI analyses belong under:

```text
res://docs/maintenance/external_ai/
```

Human consultant and bug-test records belong in the appropriate maintenance or testing folder. Every meaningful step, stumble, correction, and triumph stays in the flight recorder.

## 4K. One Canonical Global Project Roadmap Is Mandatory

The single project-wide roadmap is:

```text
res://docs/roadmap/DK_PROJECT_ROADMAP.md
```

Every numbered build, patch, hotfix, repair, tool release, and validation package must review and update this roadmap. The master thread handoff must link to it.

The roadmap must show at minimum:

- last locally accepted version;
- current candidate or failed version;
- active build and immediate next action;
- ordered near-term work;
- long-term system lanes;
- dependencies and blockers;
- acceptance gates;
- owner-approved status labels.

Approved status labels are:

```text
Proposed
Approved
Planned
In Development
Implemented
Tested
Accepted
Deferred
Retired
```

The roadmap is the project compass. `DK_MASTER_THREAD_HANDOFF.md` is the current flight recorder. Existing migration plans and system plans remain authoritative for their own subsystems, but none of them replaces the global roadmap.

This rule exists partly because platform threads can end without enough warning. A fresh thread must be able to read the handoff for the exact stopping point and the roadmap for the larger direction without relying on conversational memory.

## 4L. Working Sandbox Before Fancy Graphics

Demon Killer is being built toward a complete old-school MUD/sandbox RPG. The near-term production target is **old-school RuneScape-style functional clarity mixed with Ultima Online-style systemic freedom, persistence, and player-driven interaction**.

The order of priority is:

1. working systems;
2. persistence and recoverable state;
3. player freedom and sandbox interaction;
4. world simulation and NPC behaviour;
5. combat, skills, economy, crafting, and content breadth;
6. usability and readable menus;
7. polish;
8. final high-end art, animation, effects, and presentation.

Temporary sprites, plain menus, rough effects, and placeholder animations are acceptable while systems are being proven. Ugly is not a blocker. Broken, unclear, unreliable, destructive, or untestable behaviour is a blocker. Final graphics come after the house stands upright.

The complete-game roadmap may include skills, stats, menus, equipment, gathering, crafting, vendors, banking, trade, economy, dialogue, quests, factions, housing, persistence, world simulation, combat, magic, social systems, multiplayer foundations, administration tools, and future content expansion. These must be built incrementally. No big-bang implementation is authorised.

## 4M. Python Is the Default Studio Language for Standalone Tools

Python is Elderred Interactive's default language for standalone utilities, companion applications, content tools, file processors, and prototypes unless Derek explicitly approves another stack.

Do not choose JavaScript, a browser app, Electron, or another framework merely because it is quick to prototype. A future standalone DK Tapestry reader should use Python and a suitable desktop GUI framework unless Derek orders otherwise.

A separate application must not be started because its concept was discussed. It requires explicit build authorisation. The mistaken JavaScript DK Tapestry prototype created before authorisation is a logged scope error and is not an official project baseline.

## 4N. DK Tapestry Scope and Canon Authority

The immediate DK Tapestry task is the **world Bible and history inside the Demon Killer project documentation**, not a standalone app. Canon belongs under the existing `docs/` tree and must be carried through the roadmap, handoff, changelog, and session log.

Reader-facing Tapestry material contains no developer notes, code commentary, bug reports, build metadata, cut-content explanations, or production planning. Internal records remain separate.

The active foundational canon is:

- Darkness is the elder and native rule of Tenebrae.
- Mankind can exist in the realm only because Light entered it and made refuge possible.
- The Great Tapestry preserves Tenebrae's collective memory, faith, history, medicine, magic, geography, dead, contradictions, and forbidden truths.
- Many missing leaves were lost, stolen, hidden, or scattered.
- The most dangerous leaves were deliberately torn into fragments and sent to distant reaches, echoing the quartering of a condemned traitor so no one ruler, temple, scholar, or region could possess the whole truth.
- Each fragment may become a relic, weapon, proof, lie, shrine, political claim, or dangerous ritual object.
- Reuniting a quartered page must be rare, dangerous, politically consequential, and capable of changing what the world believes or what systems become possible.

The canonical lore record is:

```text
res://docs/tapestry/DK_TAPESTRY_CANON_FOUNDATION_v0_3_51.md
```

## 4O. DKPlayer Replacement Requires a Behavioural Contract

The protected donor `scripts/player/DKPlayer.gd` must not be replaced from memory, a design wish list, or a simplified rewrite. Its actual behaviour is the source specification until each subsystem is inventoried, covered, replaced behind a bridge, compared, tested, and accepted.

The current inventory and replacement contract is:

```text
res://docs/player/DKPLAYER_BEHAVIOURAL_INVENTORY_AND_REPLACEMENT_CONTRACT_v0_3_51.md
```

The donor remains unchanged and available until the complete replacement passes all automated and owner-required manual gates. Replacement proceeds subsystem by subsystem. No big-bang rewrite.

## 4P. Regional Access, Pursuit, and Fixed-Threat Doctrine

Open world does not mean consequence-free sprinting through intended progression. A player may attempt dangerous territory early, but must not be able to outrun one sleepy defender, empty a high-tier chest, and jog home without meaningful risk.

Demon Killer combines:

- GTA-style phased access where bridges, ferries, border gates, passes, faction standing, rituals, story state, cleared routes, or world events legitimately open regions;
- Witcher-style fixed high-level threats that remain physically reachable but are effectively unbeatable until the player gains real skill, equipment, knowledge, allies, or tactics;
- Ultima Online-style sandbox freedom, allowing selected early trespass and sequence breaking when the player accepts real danger and consequences.

Enemies do not all receive artificial speed. Intelligent territorial defence may use long pursuit, relay pursuit between patrols, ranged pressure, traps, mounts, scent, road interception, reinforcements, closed gates, bounties, and protection of valuable resources. High-tier rewards may also require tools, knowledge, rituals, extraction time, carrying capacity, or faction consequences.

Fixed enemies should not automatically scale to the player. Returning later and defeating the same once-terrifying threat is part of earned progression.

## 4Q. Curated Variable Quest Worlds

Demon Killer uses large numbers of handcrafted quests selected semi-randomly from curated pools for each new world or playthrough. Fixed main-story anchors may remain, while regional, faction, NPC, rare, and world-state quests vary.

A quest may exist in one world and never have occurred in another. In one playthrough an old woman may own a cat and need it rescued. In another, she never owned a cat. The second world must contain no dialogue, records, relationships, or later quests that falsely imply that cat ever existed.

The world seed and save state must preserve the rolled quest history. This is authored variation, not procedural filler. Hundreds of written quests should produce many coherent combinations that remain internally consistent for the life of that world.

## 4R. Purpose-Driven NPC Lives and Economic Routines

NPC simulation is layered and must create gameplay. Most NPCs need believable schedules, professions, simple needs, faction ties, and memory. Important recurring NPCs may receive deeper relationships, family, grudges, ambition, life events, and long-term consequences. Full life simulation is used only where it feeds the sandbox.

Example: Mark is a city baker. About once a week he takes a wagon to a nearby mill and returns with several large sacks of flour. The trip is short but persistent and interruptible. If Mark is delayed, robbed, killed, indebted, or the road is blocked, bread supply, prices, hunger, crime, quests, and competing businesses may react.

NPCs must not teleport through economically meaningful routines merely because a schedule says they arrived. Visible travel, cargo, danger, and disruption create the world simulation.

## 4S. Maker Marks, Provenance, and Emergent Legendary Items

Every player-crafted item receives a permanent maker's mark automatically. Maker and current owner are separate fields. High crafting skill may improve the prestige or appearance of the mark, but provenance exists from the first crude item onward.

Right-clicking an eligible item must eventually expose an append-only ownership and event ledger recording, when known:

- maker and original commission recipient;
- sale, gift, inheritance, guild issue, auction, confiscation, theft, looting, player-kill loss, recovery, and return to a previous owner;
- notable repairs, battles, kills, quests, ceremonies, political events, and faction possession;
- current owner without erasing earlier owners.

Circular history is preserved. An owner may lose a weapon to a player killer, see it sold through the market, and later buy the same weapon back. The complete chain remains visible.

Legendary status may emerge from actual history rather than only from predefined rarity. A mundane sword, tool, staff, armour piece, or relic can become renowned through famous owners, survival, battles, theft, recovery, political consequences, and generations of use. The world may recognise, covet, counterfeit, sing about, litigate over, or attempt to reclaim such an item.

An emergent legendary item is a story with statistics attached, not statistics wearing a coloured name.



## 4T. Registry-Driven Skills and Functional Menu Doctrine

Player-facing menus are gameplay infrastructure. Build them for truth, readability, keyboard and mouse operation, deterministic testing, and reuse before final art.

The Skills and Stats interface must read live values from a central registry/snapshot contract rather than duplicate progression numbers inside UI code. Active systems and future roadmap systems must be visibly distinguished so a planned skill is never mistaken for implemented gameplay.

Core menu shells should be reusable for later inventory, equipment, spell, quest, faction, housing, economy, and administration interfaces. Opening a normal ledger may stop player locomotion, but must not silently pause the entire living world unless a specific menu contract requires a pause.

Plain functional presentation is acceptable. Final Iron-and-Ember art comes after the interface contracts are stable.


---


## 4U. Ultima Online Control Continuity Rule

Ultima Online-style mouse controls are the protected default control identity for Demon Killer. Hold right mouse to move toward the pointer and release to stop. Single left click selects or inspects. Double left click performs the primary contextual action. Tab controls War Mode, Ctrl+L deliberately clears target lock, and right-click closes supported windows.

Keyboard shortcuts may supplement menus and accessibility, but may not silently replace the mouse-driven movement and interaction model. Any proposed change requires an exact owner-facing explanation, compatibility risk, migration plan, and approval.

## 4V. Persistent Calendar, Seasonal Scarcity, and Lunar Window Rule

Day/night, moon phases, seasons, festivals, crops, vendors, quests, creatures, migrations, and event goods must derive from one persistent in-world calendar. The moon may not cycle arbitrarily several times during ordinary play.

Lunar encounters use readable multi-night windows. Players may advance time through inns, camps, shrines, travel, ships, wagons, or waiting, but the world must advance with them. Missing a lunar event may delay the player, not impose an unreasonable real-world lockout. Discovered encounters may gain costly lore-consistent invocation routes.

Seasonal scarcity is an approved sandbox and economy tool. Availability must come from the world calendar, production, weather, travel, and event history rather than deceptive real-money pressure.

## 4W. Rare Event Mount, Anti-Duplication, and Taming-Before-Breeding Rule

Special mounts and creatures may appear only during defined seasonal, lunar, festival, or world-event cycles. Later natural appearance may become exceptionally rare so surviving examples gain real scarcity and provenance.

Rare mounts and goods require persistent identity, ownership history, event history, and anti-duplication protection. Animal taming must be implemented and stabilised before animal breeding. Breeding remains Deferred until ownership, persistence, transfer, rarity, inheritance, population, economy, death, release, and anti-duplication consequences are understood.

## 4X. DK Dev Companion Build Integrator Is the Default Backup Authority

The DK Dev Companion Build Integrator is the normal backup, rollback, and patch-install authority for Demon Killer builds.

Do not create a separate safety-backup ZIP for every numbered patch by default. The standard delivery remains one changed-files-only ZIP. A separate backup archive is allowed only when Derek explicitly requests it, when the Build Integrator is unavailable or damaged, or when a clearly explained exceptional recovery risk requires one.

This rule does not weaken rollback discipline. It removes redundant downloads while keeping the Build Integrator's recorded baseline and rollback path as the project authority.

## 5. Do Not Break One Thing to Fix Another

A fix is not acceptable if it secretly breaks:

- movement
- player spawn
- map layout
- build menu
- debug menu
- touch controls
- ST/TS split
- existing documented behavior

Fixes should be narrow.


---

## 5A. Player Render Layer Is Sacred

The player must not render behind map/world props in editor preview or Play Mode. This applies to:

- ghost player
- living/human player
- Stable preview before pressing Play
- Play Mode after ghost/living state changes

The DK player visual authority must keep hero renderers in front of gameplay/world layers. Map props, trees, huts, Test Center leftovers, or generated objects must never bury the player silhouette. Held items that visually belong in the player hand, especially the torch, must render with/above the player rather than behind the body.

If the player appears behind layers, fix the player visual authority and preview/play sync. Do not make a decorative workaround.

---

## 6. Build Menu Must Stay Clean

Current usable editor menus should use only the clean top-level lanes:

```text
Stable Branch
Test Center
```

The active ST tools belong under **Stable Branch/**. Do not split current tools between `Stable/` and `Stable Branch/`. If a Stable tool is active and usable, move it to `Stable Branch/` so the menu is not a two-headed Goblin.

Do not clutter the top menu with old labels like Demon Killer, Demon Killer Test Center, COTABS, or COTABO for active work. Old file/class names may remain only where changing them would break Unity references.

Old experimental builders should not clutter the top menu.

Every active build should have:

```text
Clear
Rebuild
```

Active Current and Build helper menu labels must be re-versioned with each patch. Do not leave a visible current menu saying an old number such as v0.6.67 after a newer build has shipped. Historical docs and legacy menus may keep their old numbers when they are clearly archived/legacy, but the usable active menu must tell the truth.

Clear must actually clear the intended build objects or scene state.

Map-cell labels must have one visible source of truth. Do not stack physical TextMesh labels, editor gizmo name labels, and protection labels so the same cell name appears twice. If a scene already has a readable physical cell-name label, editor gizmos may draw boundaries and protection status, but not a duplicate cell-name label.

Protection controls must be reversible from the same editing lane. If Stable Branch/Map Editing can mark selected objects protected, it must also expose a matching selected-object unprotect command. Unprotecting a selected child inside a map cell should also clear protection from the containing cell root when that root was promoted by the protect tool.


Newly created map cells must include visible and usable edge markers named **North**, **East**, **South**, and **West**. These are connection handles, not decoration. The owner must be able to connect the East side of one cell to the West side of the next cell, or North to South, to continue the map cleanly. New cell builders and "mark selected as cell" tools should create missing N/E/S/W ports automatically.

---

## 7. No Emergency Scene Replacement Without Permission

Emergency recovery patches may fix compile errors, restore missing classes, or unblock Unity.

They must not:

- replace the ST world
- remove the map
- spawn fake test villages
- change the player’s starting layout
- create a new game world unless explicitly requested

---

## 8. Preserve Player Control Rules

Do not casually remap controls.

Current important rules:

- DK is hybrid input: controller, mouse, keyboard, and touch can all cooperate unless there is a true conflict.
- Do not remove controller support. Basic gameplay should remain possible on controller.
- Mouse/keyboard support the more complex Ultima Online-style interactions.
- Left mouse click is UO-style click-to-move, not punch/attack.
- WASD is reserved for typing/chat. Keyboard movement uses arrow keys for now until the final text-entry/control remapper is built.
- Enter opens/submits overhead player speech; submitted messages display above the player.
- Touch controls remain supported for simple tasks and portable Surface Pro play.
- Touch controls are optional and should use Auto / On / Off behaviour. Auto wakes on real touch, not merely because a touchscreen exists.
- No plain single-letter or number global hotkeys for player-facing UI. DK needs typing/chat/commands without accidentally opening menus. Use Ctrl combinations or F-keys.
- Ctrl+I = inventory/backpack.
- Ctrl+B = bank box only near bank/banker/bank counter. Typing `bank` near a banker/bank counter can also open bank box.
- Ctrl+M = mini map window.
- Up Arrow = zoom the active game camera in during Play Mode.
- Down Arrow = zoom the active game camera out during Play Mode.
- Mouse wheel no longer controls camera zoom.
- E = interact.
- R1/RB = attack, R2/RT = secondary, L1/LB = block, L2/LT = parry.
- Xbox X / PlayStation Square = interact.
- Xbox A / PlayStation Cross = jump.
- Xbox B / PlayStation Circle = drop held secondary.
- Xbox Y / PlayStation Triangle = mount/dismount.
- Start/Menu/Options handles pause/menu. Select/View/Create/Share opens inventory.
- L3/R3 are unassigned placeholders unless explicitly mapped later.
- Maintain an updated hotkey/control list in every build log package.

---

## 8A. Menus Must Lock The World

The title/start menu, pause menu, inventory, and map are not decoration. They pause/lock the world.

When any of these are open:

- player movement is blocked
- attacks/arrows/block/interact do not leak through the menu
- world simulation is paused
- menu navigation still works

Keyboard 9 is the exception: it is a debug/test world-freeze. It freezes world simulation without opening a menu so the owner can inspect and interact with the paused world.

---

## 8B. New Quest Starting Placement

A new ST game starts inside the hut on a corner sacrifice altar.

The player starts dead/ghost black, not alive blue. The restore crystal must be smaller than the player and must require intentional E / Surface A / controller A interaction.

---

## 9. Crystal Rescue Must Actually Restore the Player

The hut crystal is not just a prompt or message.

It must:

- be inside the hut
- require intentional E / Surface A / controller A interaction instead of auto-restoring from spawn proximity
- restore ghost player to human when the player chooses to use it
- not be blocked by the altar interaction

The hut exit must not force crystal pickup. The player may leave the hut as a ghost, avoid the crystal, and keep playing in ghost-state until choosing otherwise. Do not recreate a ghost-lock hut barrier in Stable builders or runtime repair code.

---

## 10. Interaction Prompts Are Contextual Only

Do not keep permanent “Hit E” text on screen.

Interaction prompts appear only when the player is close enough to a usable object.

Examples:

```text
Hit E - Touch Crystal
Hit E - Touch Altar
Hit E - Read Book
Hit E - Open Chest
```

The closest/highest-priority valid object wins.

---

## 11. Do Not Assume Lore

Do not invent major lore changes without approval.

Current locked lore:

- The game starts in **Tenebrae**, a Doggerland-inspired realm on **Gaia**.
- Doggerland is an outside design/history reference, not an in-world label.
- Atlantis still exists during the main playable era.
- Tenebrae's lowland/flood-catastrophe inspiration and Atlantis are destroyed later by the global wave/impact disaster.
- The asteroid/impact threat is visible in the sky. Its current locked horizon is 120 DK years from persistent-world start, equal to thirty real years at four DK days per real day.
- The impact is future doom, not past backstory.
- Green Hall became Grenfal.
- The hero was sacrificed to lift the blight.
- Grenfal starts in autumn.
- Everred Pines stay red/orange.
- Grass is brown and crops grow poorly.
- Grenfal depends on grain from better villages.

---

## 12. Calendar Rules

Starting world date:

```text
Autumn, 09.06.9600
```

Time system:

```text
1 real-world day = 4 in-game/world days
365 world days = 1 world year
```

Moon phases use the in-game calendar, not the real moon.

Impact countdown:

```text
120 DK years from persistent-world start
30 real years at four DK days per real day
```

The clock UI must use the current thirty-real-year horizon. Older 369-year, 3,310-year, and 13,000-year distances remain historical records only and must not appear as the active countdown.

---

## 13. No Real Marijuana System

Do not add marijuana farming.

Botany and alchemy are important, but plants should be fictional ancient-world plants with useful purposes.

Allowed:

- medicine plants
- poison plants
- candle oil plants
- ritual plants
- purification herbs
- beast lure plants
- potion barrel brewing
- mysterious plants with hidden uses

---

## 14. Protect the Historical Record

Do not delete old ideas without documenting why.

Scrapped ideas should go into archive, Tapestry, design, or log notes as appropriate.

The project history matters because it lets us revert, repair, and understand why decisions were made.

---

## 15. PC First

Demon Killer is PC-first for now.

Nintendo/Switch approval or porting may happen later, but it must not block prototype development.

Build the game first. Prove it works. Worry about console gates later.

---

## 16. Test Before Declaring Victory

A patch is not “good” just because it compiles.

Test:

- Unity compiles with no red errors
- correct build menu appears
- Clear works
- Rebuild works
- Play mode starts
- player can move
- map is intact
- crystal works
- HUD works
- controls still work
- no old builds are stacking on top

---

## 17. Do Not Overbuild ST

ST should stay focused.

Add only what supports the current playable main path.

Bigger experiments go to TS.

---

## 18. When Things Break, Patch Forward Cleanly

No panic rewrites.

Process:

```text
Identify the broken script or system
Make the smallest repair
Document the mistake
Keep the map intact
Release changed-files-only patch
Test again
```

---

## 19. Respect the Vision

The project is not generic fantasy.

Demon Killer is:

- ancient Gaia dark fantasy
- Tenebrae as the Doggerland-inspired starting realm
- Atlantis-era world
- doomed sky / asteroid prophecy
- Zelda-style top-down foundation
- Ultima Online-style depth
- ST/TS split for controlled chaos
- heavy documentation
- player discovery
- old-world mystery
- brutal but fair systems, except rare mythic events that are meant to feel terrifying

---

## 20. The Big Rule

Do not “helpfully” replace the user’s working game.

**Fix the problem. Preserve the world.**

---

## v0.6.79 Protected Cell Family Rule

When a new protected manual map cell is created, the whole cell family starts protected: root, ground, North/South/East/West boundaries, North/South/East/West exits, and North/East/South/West edge markers/ports. A protected cell root without protected children is a Goblin.

## v0.6.79 Map Expansion Port Rule

Map expansion handles are directional edge markers: North, East, South, and West. East connects to West, and North connects to South. New manual protected cells must create all four directional edge markers and all four directional exits so Derek can continue the map without eyeballing seams.


## v0.6.79 Stable Branch Menu Rule

Stable Branch is the active root menu for the stable project tools. Do not split current tools between `Stable/` and `Stable Branch/`. Current, Build, Map Editing, Art Prototype, Touch UI, and Company Bible tools belong under `Stable Branch/` unless Derek explicitly says otherwise.


## v0.6.80 Cell Family Protection Cascade Rule

When Derek selects a map cell root such as `First Village Cell`, or any object inside that cell such as ground, border, boundary, exit, edge marker, label, or child art, `Stable Branch/Map Editing/02 Mark Selected Objects Protected` must protect the entire cell family. That means every descendant receives both supported protection markers where applicable: `DemonKillerMapEditMarker` preserve flags and `DKProtectionMarker`. Protecting only the clicked/root object while ground, borders, exits, or markers remain unprotected is a Goblin.

The matching unprotect command must resolve the same cell family and clear protection across the same descendants. Protect and unprotect must be symmetrical.


## v0.6.81 Manual Prop Protection Rule

Trees, bushes, rocks, and similar manual map-edit props must not be half-protected. When a prop is dropped through Stable Branch/Map Editing, the prop root and every visible child part must immediately receive both protection systems where possible: `DemonKillerMapEditMarker` preserve flags and `DKProtectionMarker`. If an older prop exists with unprotected child pieces, the repair/protect prop hierarchy tools must bring the whole decoration bundle up to the current rule. This is a Goblin-prevention rule: visible pieces should not vanish or become editable just because the invisible prop root was protected.

---

## v0.1.16 Godot Immediate Patch Inclusion Rule

When Derek explicitly asks for a patch, feature, fix, or build task, the requested work belongs in the next patch/build immediately. Do not defer requested changes to a later patch unless Derek explicitly says to wait, hold, or leave it for later.

Every requested build/patch must keep the full DK paper trail:

- patch notes
- changelog
- session/development log
- Tapestry update when world lore or story truth changes
- dedicated design/system entry when gameplay, controls, world mechanics, or systems change
- Company Bible update when workflow/company rules change

Skipping documentation, silently postponing requested work, or releasing a partial pack while known requested items are missing is a Goblin.



---

## 4E. Image Generation Requires Explicit Picture Orders

Do not generate images for DK unless Derek explicitly and unmistakably asks for an image, picture, drawing, visual, or says words such as “make a picture of.”

Metaphorical design language is not an image request. Mentions of a ghost cursor, Navi-like helper, art direction, pointer design, game objects, or visual behaviour must be handled as text/design/code only unless Derek clearly orders image generation.

This rule applies to all future assistants, build helpers, documentation passes, and project tooling.

---

## 9C. DK Godot Cursor Spirit Rule

The mouse pointer in the Godot rebuild should be treated as part of the world. Runtime should hide the default operating-system cursor and use a small white ghost-ball helper cursor instead.

The helper cursor is a gameplay/control element, not an image-generation request. It should support hover information, selection, interaction, and UO-style mouse control while feeling like a small guiding spirit attached to the player journey.


## Failed Patch Retry Rule v0.1.19
If Derek reports that a patch did not take, the next patch must re-carry the missed changes, add a verification marker when reasonable, preserve working systems, and fully document the retry.

---

## v0.1.73 Godot Build Command And Logging Rule

When Derek says to make a build, map, patch, hotfix, or edit in DK Godot, treat that as a Godot project/build request, not an image-generation request. Do not generate pictures unless Derek explicitly says to make a picture/image/drawing/visual.

Everything done in the DK project must be logged every time, with no exceptions. Every build, patch, redo, inspection result, documentation change, map edit, tool change, scene change, settings change, or package must include the proper paper trail inside the project folders. Do not omit logs because a change looks small.

Changed-files-only ZIP remains the default package. Only make a full project ZIP when Derek explicitly asks for a full project ZIP.

---

## v0.2.02 Godot Version Habit And 0.2 Territory Rule

DK has entered the v0.2 line. This is a major project progress marker.

Every numbered Godot patch/build must update the visible project version when the project opens. Project-facing version surfaces include `project.godot`, exported/runtime build-version strings, scene-level build-version overrides, changelog/session/patch-note titles, manifests, package names, and any active labels used to identify the current build.

Leaving stale version strings such as `88`, `v0.1.88`, or any old patch title in active identity fields is a Goblin. Version display updates are mandatory build hygiene, not optional cleanup.

Every backup name/title must include the version number. Vague backup names such as `main_copy.tscn` are forbidden. Main backups should stay outside the active Godot `res://` tree unless UID-safe and deliberately imported.

Next target after the v0.2 progress-log patch is **WAR MODE**. Gameplay design belongs in dedicated design/system documentation; implementation belongs in the next explicit War Mode patch.

## v0.2.03 WAR MODE FOUNDATION Build Record

Version display must continue to advance with every numbered patch/build. v0.2.03 updates the active project identity to `DK Godot v0.2.03 WAR MODE FOUNDATION` and the runtime build string to `DK Godot v0.2.03 - WAR MODE FOUNDATION`.

This build implements the first gameplay foundation for Ultima Online-style War Mode. Gameplay specifics belong in dedicated design/system documentation, but the build discipline is Company Bible territory: numbered patch, visible version update, changed-files-only package, changelog, patch notes, session log, manifest, and no stale v0.2.02 identity strings left in active project files.

`scenes/Main.tscn` was not touched in this patch, so no Main insurance backup was required. If a future War Mode patch touches `scenes/Main.tscn`, the Main backup name must include that future version number.


## v0.2.04 Door Template Creation And Copy/Paste Guard Rule

Door creation must use the DK door-template workflow instead of raw Ctrl+C/Ctrl+V copies of existing placed doors. Raw Godot paste can place a door inside another door, such as `Door19/Door28`, which confuses Godot's undo stack when a guard script tries to reparent the child during the same paste action.

The correct workflow is: select one `DoorTemplate*` from `DKDoorTemplates`, select the target `Cell*` root, then use `DK: Create Door From Selected Template`. The new placed door must be created directly under the chosen cell, prepared as a runtime DK door, protected/user-placed, visible, unlinked by default, and named with the next higher global door number.

New door numbering is max-plus-one, not first-gap reuse. If the highest existing door is `Door28`, the next created door is `Door29` even if an older lower number is missing.

The copy guard must not auto-promote nested pasted doors during Godot's paste/undo transaction. It may warn the user, but automatic reparenting during raw paste is forbidden because it can create editor undo parent errors. Use the DK template command for clean door creation.

`scenes/Main.tscn` was not touched in v0.2.04, so no Main insurance backup was required.


## v0.2.05 Door Template Copy And Stale Link Repair Rule

Door templates are the only correct source for creating new placed doors. The four palette templates stay as templates, and any new placed door made from a template must become the next higher global `Door#` under the chosen target cell. A copied `DoorTemplate*` must not remain nested under the original template.

If a raw Godot paste places a `DoorTemplate*` inside another template, use `DK: Create Door From Selected Template` with that copied template and the target `Cell*`. The DK tool converts it into a proper numbered door under the cell, removes the disposable nested template copy, and keeps numbering max-plus-one.

Placed `Door#` nodes must not carry `dk_placeable_door_template=true`. Only the original four `DoorTemplate*` palette nodes should be treated as placeable templates.

Door link repair guards may repair stale manual link paths, such as old `@Node2D@...` copied-door paths, by finding the reciprocal linked door and rewriting the link to the current stable `Door#` path. This is allowed editor hygiene and should mark the scene unsaved so the repaired path can be saved cleanly.

Cell linking must be idempotent: if two selected cells are already linked on the correct side, `DK: Link Selected Cells` should confirm the existing connection instead of rewriting or dirtying the scene.

## v0.2.06 Door Template Paste Normalizer Rule

Raw Godot Ctrl+C/Ctrl+V on the original door templates must not leave a copied template nested under the original template. If `DoorTemplateNorth` is copied and Godot temporarily pastes the copy as a child of `DoorTemplateNorth`, the DK editor guard must normalize it into a sibling template copy under the same template/palette parent.

The original four template names remain unnumbered:

```text
DoorTemplateNorth
DoorTemplateSouth
DoorTemplateWest
DoorTemplateEast
```

Copied template nodes must use side-specific numbered names such as:

```text
DoorTemplateNorth1
DoorTemplateNorth2
DoorTemplateSouth1
DoorTemplateEast1
DoorTemplateWest1
```

Template copies must not remain children of the original template, must keep `dk_placeable_door_template=true`, and must remain available for the DK door-template workflow. This rule fixes the v0.2.05 behaviour where the editor only warned about nested template copies instead of cleaning the hierarchy.

`scenes/Main.tscn` was not touched in v0.2.06, so no Main insurance backup was required.

## v0.2.07 Cell/Door Draw Order Rule

All map cell roots must remain on the same shared draw level by default. Doors and door templates must draw one level above cell contents so they remain visible when moved, pasted, converted from templates, or placed onto NES/edge-test cells.

The standard draw stack is:

- Cell roots: `z_index = 0`, `z_as_relative = false`, `y_sort_enabled = false`.
- Door roots and door templates: `z_index = 10`, `z_as_relative = true`, `y_sort_enabled = false`.

This rule exists because Derek found a door could be moved onto `CellNES/Edge Test` style cells and appear underneath the cell layer. Door visibility must be automatic and consistent. New numbered patches/builds must continue updating the project-facing version when opened. No SHA/checksum file is included unless Derek explicitly asks for one.

`scenes/Main.tscn` was not overwritten in v0.2.07. The draw-order repair is script/tool-side so Derek's active map edits remain safe.

## v0.2.08 Door Link No Duplicate Rule

`DK: Link Selected Doors` is link-only. It must never create, materialize, convert, adopt, clone, or duplicate doors during a door-link operation.

Door templates and numbered door-template copies are not real placed doors. If the selected nodes are `DoorTemplate*`, including copies such as `DoorTemplateNorth1` or `DoorTemplateSouth1`, the door linker must stop with a warning and tell Derek to use `DK: Create Door From Selected Template` first.

Correct workflow:

1. Copy a palette template if desired, such as `DoorTemplateNorth` to `DoorTemplateNorth1`.
2. Select the template/copy and the target `Cell*` root.
3. Run `DK: Create Door From Selected Template` to create the next real global `Door#` under that cell.
4. Select two real `Door#` nodes.
5. Run `DK: Link Selected Doors`.

Existing real door links should be idempotent. If the two real selected doors are already linked to each other, the linker should confirm the existing link and not dirty the scene or create duplicates.

This rule exists because Derek confirmed that linking `DoorTemplateNorth1` with `DoorTemplateSouth1` created new real doors `Door28` and `Door29` as soon as he used right-click link. That behaviour is forbidden going forward.

No SHA/checksum file is included by default unless Derek explicitly asks for one. Backups and backup handshakes must stay outside the active Godot project folder and include a reminder to archive them outside the project.

`scenes/Main.tscn` was not touched in v0.2.08, so no Main insurance backup was required.


## v0.2.09 Project Version Open Screen Enforcement Rule

Every numbered patch/build must update the Godot project-manager/open-screen identity every time. The active `project.godot` `[application] config/name` field is the main visible project name Godot shows when opening/selecting the project. It must match the current package version and patch title, not an older version.

For v0.2.09 the active identity is:

```text
config/name="DK Godot v0.2.09 PROJECT VERSION OPEN SCREEN FIX"
application/config/name="DK Godot v0.2.09"
application/config/version="0.2.09"
```

The runtime/exported build string and scene-level `build_version` override must also match:

```text
DK Godot v0.2.09 - PROJECT VERSION OPEN SCREEN FIX
```

This rule is mandatory with no exceptions. If a patch/build advances the version but Godot still opens showing an older DK version, that package failed build hygiene and must be redone before continuing.

Logs, backup notes, manifests, and reminders belong under `docs/` only. No loose backup notes, patch notes, archive reminders, or checksum files belong at the ZIP root. ZIPs must not contain a duplicate wrapper folder.

## v0.2.19 Coding Style Doctrine And Outside AI Review Rule

A human team can write clean, messy, clever, plain, old-school, weird, or beautiful code. The law is not style. The law is: follow the Company Bible, protect working systems, document everything, and do not break the game.

Working code is respected. Stable systems are protected. No developer may force a rewrite, refactor, rename, or style cleanup merely because existing code looks ugly or unconventional. Practical results, traceable changes, and project safety outrank fashion.

Outside AI analysis is allowed as scouting material only. Codex App, Grok, or any other outside analysis can point out risks, praise strengths, or suggest ideas, but outside analysis does not outrank Derek, the Company Bible, working DK systems, backups, logs, Tapestry lore, or explicit project rules.

Accepted outside-analysis themes from the v0.2.19 review pass:

- DK is battle-hardened and heavily documented by design.
- DK is partly a game project and partly a developer journal in executable form.
- Continuity, safety, traceability, and preservation are strengths, not clutter.
- Stability over flash, documentation over speed, and preservation over rewrite remain valid DK doctrine.

Rejected or deferred outside-analysis actions unless Derek explicitly orders them later:

- Do not refactor, split, simplify, or clean the door system for style reasons.
- Do not rename cells, doors, nodes, or files merely because names look ugly.
- Do not shorten, retire, or delete Company Bible rules without explicit permission.
- Do not retire, delete, flatten, or reduce Tapestry lore without explicit permission.
- Historical `docs/codex/` files remain preserved as archive records; do not mass-rename or delete them.
- Do not remove automatic repair/protection systems just because an outside review calls them messy.

Existing ugly braces may be load-bearing. Do not pull a nail out of DK just because it offends clean-code fashion.


## v0.3.49 Failed Automated Runs Are Permanent Evidence

A failed DK validation or Test Pilot run must be preserved in the next corrective build's records. Do not erase, minimise, or replace the failed result with only the later passing result.

The corrective build must record:

- the failed project version;
- the exact failed steps or resources;
- warning, error, timeout, and exit-code state;
- the diagnosed cause;
- the files changed to repair it;
- the local rerun still required;
- the later passing result when Derek supplies it.

This rule exists because logs are DK's defence against sudden thread cutoffs, forgotten assumptions, and false claims that a feature was always working. Failure reports are evidence, not embarrassment. The cumulative master handoff must summarise the incident and the corrective status.

## Build / Patch Communication Rules

### Build Response Boilerplate Rule

Do not repeat generic build-response boilerplate such as “I could not run Godot validation here, so test this in-editor” in every DK patch/build response. Derek already understands the tool limitation. Mention validation/tooling limitations only when newly relevant, specifically asked, or when a concrete validation failure/limitation affects the patch.

## v0.2.35 Main Change Explanation And Approval Rule

Before editing `scenes/Main.tscn`, the proposed Main-specific change must be explained to Derek before the edit begins.

The explanation must state:

- why `Main.tscn` must be touched;
- exactly which nodes, properties, resources, or metadata will change;
- which existing systems could be affected;
- what external pre-edit backup will be created;
- whether the result could be achieved safely without touching Main.

Derek must approve that described Main change before `Main.tscn` is edited. Approval is limited to the explained scope. If the Main change grows beyond that scope, stop and obtain approval for the expanded Main work.

No approval means no Main edit.

## v0.2.35 Rule Exception Approval And Documentation Procedure

Company Bible rules are mandatory. No assistant, developer, tool, or contributor may silently ignore, bend, or reinterpret a rule because it is inconvenient.

If a mandatory rule genuinely blocks safe or necessary work, stop before violating it and explain:

- the exact rule creating the conflict;
- why the requested work cannot be completed safely while following it;
- the smallest exception needed;
- the risks and alternatives;
- the files and systems the exception would affect.

Only Derek may approve the exception. An approved exception must be documented in the Company Bible or a versioned Company Bible addendum, the changelog, and the session log for that build. Unapproved or undocumented exceptions are forbidden.

## v0.2.38 Separate Backup Discretion And Package Separation Rule

Derek authorizes the assistant to decide when an additional safety backup is warranted for a DK build, patch, repair, or risky documentation/project operation. A new permission request is not required for each separate backup.

When this discretion is used:

- explain what is being backed up and why the extra insurance is warranted;
- create the backup outside the active Godot project folder;
- provide the backup as a separate download from the changed-files patch/build;
- never place a `Main.tscn` backup, full-project backup, backup handshake, or other insurance copy inside the changed-files package;
- never place backup files anywhere under the active `res://` tree;
- keep the changed-files package limited to active changed project files and its required documentation, logs, notes, and manifest.

A request for one patch download means one clean changed-files package. It does not forbid a separately presented safety-backup download when the assistant judges one necessary. The backup must remain clearly labelled, versioned, and separate.

This discretion does not permit unrelated backups, duplicate clutter, or hidden archives. It exists to protect working DK state while keeping installation packages clean.

## v0.2.35 Visible Version Everywhere Rule

Every numbered DK patch/build must update all active version surfaces before packaging:

- `project.godot` `config/name`, so the Godot Project Manager shows the current DK version immediately;
- `project.godot` application name and application version;
- the default runtime `build_version` in `scripts/world/DKWorld.gd`;
- active scene-level `build_version` overrides in `scenes/Main.tscn` and `scenes/NewMap.tscn`;
- the visible version label at the top of the running game scenes;
- the package filename and all versioned build documentation.

If any active surface shows an older version, the package has failed version hygiene and must be repaired before moving on.

## v0.2.44 Attribution Beyond Legal Minimum Rule

DK credits creators even when a licence does not legally require attribution.

For every externally sourced asset used by DK, preserve and document when available:

- creator or artist name;
- original asset title and filename;
- source page;
- licence and licence version;
- acquisition date;
- any edits, excerpts, cue points, conversions, or loops made for DK.

CC0, public-domain, or otherwise attribution-optional work must still receive a good-faith creator credit. A missing legal attribution requirement is not permission to erase the person who made the work.

Development assistance from ChatGPT/OpenAI must also be credited honestly in the final project credits. The standard wording is:

```text
Development assistance provided with ChatGPT by OpenAI.
```

Credits are factual records, not vanity awards. Do not claim a creator, musician, performer, company, or tool contributed work that was not actually included. If a desired asset could not be imported, document it as a candidate or replacement target rather than falsely crediting it as active content.


## v0.2.81 Camera Zoom Control Rule

The active game camera zoom control is now:

```text
Up Arrow = zoom in
Down Arrow = zoom out
```

Mouse-wheel camera zoom is retired. These arrow-key presses are consumed by the camera zoom control during gameplay. This is an explicit owner-directed control change and replaces the older mouse-wheel zoom rule.


## v0.2.82 Company Bible First, Then Ask Derek Rule

Whenever an assistant, developer, tester, or contributor has a DK question, is uncertain about a required action, or encounters ambiguous instructions, the required order is:

```text
1. Read the active Company Bible.
2. Read the relevant current Tapestry, design, system, control, changelog, and session records.
3. Use the documented answer when one exists.
4. Ask Derek only when the project records do not answer the question or a specific owner decision is still required.
```

Do not ask Derek to repeat information already preserved in the project records. Do not guess around uncertainty before checking the Company Bible. The Main approval rule and other owner-only approvals remain in force; checking the Bible does not grant permission the Bible reserves for Derek.

## Sequential Numeric Version Rule — Added in v0.2.85

- DK build and hotfix versions must always advance to the next unused numeric version.
- Never append letters to a version number. Forms such as `v0.2.84a`, `v0.2.84b`, or `v0.2.84c` are forbidden.
- A hotfix after `v0.2.84` must become `v0.2.85`, followed by `v0.2.86`, and so on.
- Rejected packages do not become valid baselines. Their version labels must not be reused as accepted project state.
- Before packaging, inspect every version surface and package filename for accidental suffixes or malformed repeated letters.

## Versioned Deliverable Archive Name Rule — Added in v0.2.88

- Every user-facing DK deliverable archive must include its numeric version in the filename. This includes builds, patches, hotfixes, handshakes, transfer bundles, backups, and development utilities.
- A date-only archive name is not sufficient for a current deliverable. Names such as `DK_GOBLIN_TRAP_SHAMAN_HANDSHAKE_TRANSFER_2026-07-06.zip` are forbidden as current handoff/build downloads because they do not identify the project version.
- Rejected or stale transfer archives must never be presented as the current installable build. The current build link must point only to the properly versioned changed-files package.
- Package filenames, internal version records, active Godot identity surfaces, and backup names must agree before delivery.

## Sequential One-Build-at-a-Time Rule — Added in v0.2.90

All DK work must be executed strictly one build at a time.

- Never build, package, process, validate, or run two or more builds simultaneously.
- When Derek labels work as `Build 1`, `Build 2`, `Build 3`, and so on, those labels define the required order within the session. They are not permission to execute the builds in parallel.
- Finish, validate, package, and hand off Build 1 before starting Build 2. Finish Build 2 before starting Build 3.
- This applies equally to game builds, hotfixes, utilities, asset-processing jobs, documentation packages, transfer bundles, and other project deliverables.
- Do not begin the next queued build until the current build is complete, or Derek explicitly cancels or reorders the queue.

Parallel build work risks system instability, version confusion, mixed packages, and lost project state. One complete package leaves the forge before the next enters it.



## v0.3.09 Streaming Region Cell Terminology, Scale, And House Spelling Rule

The large seamless-world units are **streaming region cells**, shortened in ordinary DK discussion and documentation to **region cells**. Do not call the active seamless-world units “map cells”. “Map cell” remains valid only when referring to the preserved legacy Zelda-style world or its historical records.

A region cell represents a substantial stretch of country. A village, sanctuary, road, woodland, marsh, field, or other settlement feature may exist inside a region cell, but the feature does not define the full region boundary. Region cells must not be treated as village-sised rooms.

The v0.3.09 foundation expands each active region cell from `4096 x 2560` world units to `16384 x 10240` world units. This is four times wider and four times taller, producing sixteen times the land area per region cell. Future changes must preserve this regional scale unless Dick explicitly orders another scale change.

Historical class names, file names, inherited `dk_cell_*` properties, and compatibility metadata may remain when renaming them would risk working systems. All new visible labels, diagnostics, design records, and current terminology must use **streaming region cell** or **region cell**.

### DK House Spelling

> DK documentation will use Dick’s preferred British/French-style spellings, including forms such as “sised,” “realised,” and “analyses,” rather than defaulting to Webster-style American spellings.

Apply this house spelling consistently in new DK documentation, changelogs, handoffs, internal records, and suitable UI text. Historical records remain preserved as written. Do not rewrite archived documents merely to modernise their spelling.


---

## v0.3.55 Mandatory Additions: Readable UI, Persistent Objects, and Logged World Doctrine

**Effective:** 2026-07-11

### Event Log and world-camera input

- Player-facing Event Log messages must stay readable and must not carry routine camera coordinates or zoom telemetry.
- Mouse-wheel input over a scrollable or interactive UI control belongs to that control and must not zoom the world camera.
- World camera zoom is permitted only while the pointer is over open world space and no UI control consumes the wheel event.
- The existing fairy pointer is a protected control and visual identity. Future menus, camera routing, DKPlayer extraction, and cursor work must preserve it unless Derek explicitly orders a change.

### Universal world-object age and information

- Every persistent item, creature, structure, ruin, sanctuary, plant, corpse, mount, and world object stores an origin timestamp or equivalent lineage record and derives its age from the persistent world calendar.
- Age belongs in a right-click or pull-away Object Information panel, not the HUD or Event Log.
- The player inspector may show identity, age, maker, owner, origin, quality, condition, material, legality, rarity, decay, magical traits, and provenance according to object type.
- A deeper privileged admin inspector may expose internal IDs, scripts, persistence state, timestamps, and technical fields.

### Random events and automation resistance

- Random events must be legitimate sandbox content first. Their unpredictability may also make unattended scripting unreliable, but normal players must not be unfairly killed by opaque anti-cheat traps.
- Event pools may include travellers, officials, weather, spirits, ambushes, road accidents, lost animals, market opportunities, mine failures, and faction incidents.

### Bread and inherited yeast

- Breadmaking is a named crafting priority, not a one-click filler recipe. The practical chain is grain or flour, water, salt, yeast culture, kneading, shaping, oven, and bread, without tedious real-time proofing waits.
- Yeast cultures are persistent named living lineages. They may be inherited, traded, divided, stolen, contaminated, lost, revived, and preserved for hundreds or thousands of in-world years.
- Culture age, caretaker history, provenance, strength, flavour, and adaptation may affect bread, reputation, quests, and economy.

### Seasonal rarity, taming, and breeding

- Special mounts, creatures, foods, resources, and goods may appear during specific seasonal, lunar, festival, or world-event cycles.
- After a cycle closes, later natural availability may become extraordinarily rare, provided identity and anti-duplication rules are enforced.
- Taming must be designed, persisted, and accepted before animal breeding. Breeding remains deferred until ownership, inheritance, population, rarity, provenance, and economy effects are safe.

### Soul and spirit visuals

- The ordinary dead-player ghost uses an original prismatic translucent soul-cube: faceted glass planes, restrained rainbow edge refraction, soft internal light, and readable transparency. In the isometric view it reads as a diamond or rhombus around the soul.
- Darkness-devoted dead may become predatory red-aura spirits that seek living bodies and attempt possession. They are not ordinary player ghosts.
- The currently visible editor-preview diamond is preserved until its node and future role are deliberately replaced.

### Angel-human people

- The half-angel, half-human people remain living in Tenebrae during the game era and are morally varied. “Nephilim” is inspiration language only, not the final primary in-world name.
- “Veilborn” is an approved common working term and “Vaelori” is a candidate people-name; final canonical naming remains open until Derek selects it.


## v0.3.56 Mandatory Rejection Repair: Event Log Wheel Means Scroll Only

**Effective:** 2026-07-11

- v0.3.55 is rejected because it added an unrequested Ctrl+wheel Event Log text-size feature and did not reliably isolate Event Log scrolling from world-camera zoom.
- Mouse wheel over the Event Log means scroll the Event Log only, regardless of Ctrl or other modifiers.
- Event Log text size must not change from wheel input. Any future text-size setting requires explicit owner approval and belongs in a deliberate settings control, not a hidden modifier gesture.
- Mouse-wheel camera zoom must run from the unhandled-input stage after GUI controls receive first refusal.
- World-camera zoom is allowed only over open world space. Event Log, menus, inventory, Skills Ledger, inspectors, and other interactive UI block it.
- The fairy pointer remains protected and unchanged.
- Rejected builds and their reasons remain in the permanent logs. Rejection is evidence, not a record to erase.

## v0.4.19 Addendum: Complete Version Identity Every Time

Every numbered build, patch, and hotfix must advance every active version identity in the same package. This includes, where applicable:

- project version and visible project title;
- DK Live Builder panel and report header;
- validation runner identity;
- Test Pilot runner, patrol script, contract, and report identity;
- package name, changelog, session log, patch notes, handoff, validation record, changed-files record, and manifest.

A stale tool, validator, or test version is a failed version-hygiene gate even when its underlying scan passes.


---

## Godot environment limitation handling

If an assistant cannot run Godot locally, that limitation must be recorded once in the Company Bible or active build documentation and then handled silently. Do not repeat boilerplate such as “Godot 4.7 is not installed in this environment” in every handoff or final delivery unless it materially affects the specific result.

Owner-side Live Builder, Test Pilot, and smoke-test reports are the authority for runtime acceptance when local Godot execution is unavailable.


---

## v0.4.37 Addendum: Installable Patch Manifest Schema Verification Rule

Every installable DK changed-files package must use the accepted top-level `DK_PATCH_MANIFEST.json` schema. The required manifest identity is:

```text
format = DK_CHANGED_FILES_PATCH
format_version = 1
package_name = exact archive filename
required_base_version = exact accepted install baseline
target_version = exact new numeric version
package_type = changed-files-only
changed_files_only = true
install_root = Godot project root containing project.godot
payload_root = .
delete = an array, empty when nothing is removed
```

The manifest must be generated from the accepted template, parsed, type-checked, and compared against the package filename and direct-root archive layout before delivery. Do not invent a simplified manifest from memory. A legacy object containing only keys such as `package`, `version`, `changed_files`, and `deletions` is not an installable DK patch manifest.

When a package has a malformed manifest, repair the package. Do not alter DK Build Integrator or weaken its inspection gate to accommodate the malformed archive.

The rejected v0.4.36 package failed this rule and is not an accepted baseline. v0.4.37 supersedes it from required base v0.4.35.

---

## v0.4.38 Gaia Streaming Cell and Image-Permission Addendum

Use **Gaia Streaming Cell** for the large parent world-cell layer above the existing detailed seamless streaming cells. The current foundation contract is:

```text
1 Gaia Streaming Cell = 5 x 8 child streaming cells = 40 child streaming cells.
```

The existing seamless cells are child streaming cells. Gaia parent cells load broad world state first; detailed props, NPCs, enemies, pickups, and interiors load through child cells by proximity.

Planning, questions, corrections, and map discussion are not permission to generate images. Only generate or edit an image when Derek gives a clear direct command to make/create/edit the picture.

Do not invent or simplify `DK_PATCH_MANIFEST.json`. Use the accepted `DK_CHANGED_FILES_PATCH` format version 1 unless Derek intentionally changes the installed Companion/Build Integrator.

---

## v0.4.39 Addendum: Parse-Repair Preflight and Gaia Scale Clarification

v0.4.38 is a failed candidate until repaired because it installed but produced GDScript parse failures in active scripts. A patch that opens with parse errors is not accepted even when the top-level patch manifest is installable.

Before delivering a changed-files patch that edits `.gd`, `.tscn`, `.tres`, `.cfg`, `.json`, `.md`, or `.txt` files, perform a static preflight for UTF-8 readability and obvious bracket/string-balance problems. This does not replace DK Live Builder, DK Test Pilot, or owner-side Godot validation, but it must catch simple broken literal strings and missing variables before packaging.

The Gaia Streaming Cell terminology remains:

```text
Gaia Streaming Cell = parent world cell.
Child streaming cell = existing detailed seamless streaming cell layer.
```

The current Tenebrae planning scale is not "one Tenebrae equals one Gaia cell." Tenebrae is a large realm that will be broken into multiple playable sections. A first working section may use about forty child streaming cells, and the full Tenebrae route may use several such sections.

Do not touch DK Build Integrator to work around patch-content failures. Repair the broken package contents instead.

## v0.4.40 Addendum: Validator Token Quote-Escape Preflight

Any DK validator or Test Pilot token string that searches for source text containing quote characters must be escaped and inspected in its final GDScript file before packaging.

A token like this is invalid inside a double-quoted GDScript string:

```gdscript
"func example(path: String = "") -> Dictionary:"
```

The embedded quotes must be escaped or represented safely. A package that fails to parse because a validator token was not quote-escaped is a failed package and must be repaired forward under a new version number.

This rule does not authorise changes to DK Build Integrator. Build Integrator remains owner-controlled.

## v0.4.41 Addendum: Test Pilot Step Count And Version Hygiene

DK Test Pilot step count and version identity are a single unit of work.

When a patrol step is added, removed, or reclassified, the same patch must update and verify:

```text
- `tests/dk_test_pilot/test_dk_main_patrol.gd` `TOTAL_STEPS`
- `addons/dk_live_builder/dk_live_builder_validation_runner.gd` Test Pilot required-token list
- `tests/dk_test_pilot/test_dk_main_patrol.gd` `PILOT_VERSION`
- `addons/dk_test_pilot/dk_test_pilot_project_run.gd` `PILOT_VERSION`
- active project version identity surfaces
```

A patch that lets Live Builder or Test Pilot fail because the validator expects an old step count or old pilot version is not accepted.

This rule does not authorise changes to DK Build Integrator.



## v0.4.42 Gaia Streaming Cell LOD Authority Rule

Demon Killer must scale Gaia with parent/child/detail streaming rather than one giant loaded scene.

- A Gaia Streaming Cell is a world-atlas parent and state authority, not a full live Godot scene.
- Each Gaia Streaming Cell keeps 40 child streaming cells as the travel-scale layout.
- Each child streaming cell may split into 16 detail cells for proximity spawning.
- Full Godot nodes belong only in the active bubble near the player.
- Warm neighbour cells may prepare terrain, major collision, simplified actor summaries, spawn queues, and ledgers before a seam crossing.
- Cold Gaia state remains data-only: durable records, timestamps, mutation ledgers, corpses, resources, NPC schedule summaries, and offline catch-up.
- This rule is the DK answer to acceptable MMO-style server-line stitching: prewarm the next area and hand off authority before the line, instead of loading every object at the border.
- No modern map-label, image-generation, or DK Build Integrator changes were part of v0.4.42.


## v0.4.43 Gaia Scale Flexibility And Modding Roadmap Rule

Gaia cell sizes, child streaming cell sizes, and detail-cell splits must be treated as scale-profile data. The current accepted profile is the active plan, not a prison. Future builds may adjust cell sizes or section sizes if the world map demands it, but they must do so through named profiles and documented migration paths.

Current planning profile:

```text
1 Gaia Streaming Cell = 5 x 8 child streaming cells = 40 child streaming cells.
1 child streaming cell = 4 x 4 detail cells = 16 detail cells.
1 major Tenebrae section = 4 x 4 Gaia cells = 640 child streaming cells.
Four-section Tenebrae core = 64 Gaia cells = 2,560 child streaming cells.
```

Persistent world records should prefer stable cell addresses over raw pixel assumptions wherever possible.

Modding support is now a high-priority future roadmap item, not an immediate implementation demand. It must eventually support longevity and player-created content without weakening core validation, save authority, or Build Integrator ownership.

Wilds Ambient Ambush Story Generator is recorded as low priority. It uses subtle, one-shot sensory clues and emergent outcomes, not guaranteed death or marker spam.


## v0.4.44 Cell Hierarchy Naming Rule

Each cell-system level must have one clear name:

```text
Gaia Cell -> Realm Section -> Streaming Map Cell -> Detail Cell
```

Do not use several public names for the same layer. The actual player-streamed gameplay unit is **Streaming Map Cell**. Older conversational terms such as child cell or Gaia child cell should be treated as informal scratch language unless explicitly preserved in legacy notes.

Before future Gaia streaming builds, check Live Builder static contract tokens against the current version and step count. A package that leaves Live Builder expecting stale version tokens is failed packaging.


## v0.4.45 Version Surface Static-Token Preflight Rule

Live Builder static contracts must be checked for every active visible version surface before delivery. This includes title-scene labels, title-screen script display constants, event-log configure version strings, scene metadata, project identity, Test Pilot versions, and runner versions.

A patch that advances the project version but leaves the validation runner expecting an older visible token such as `v0.4.42` is failed packaging and must be repaired forward under a new version.

Warnings reported by Derek remain project Goblins. Local variables must not shadow Godot base-class signals when the warning is known and safe to repair.


## v0.4.46 Developer Map Foundation Addendum

- The accepted public cell hierarchy names are: Gaia Cell -> Realm Section -> Streaming Map Cell -> Detail Cell.
- The developer map is a planning/documentation contract, not map art.
- No map image should be generated for developer-map planning unless Derek explicitly asks.
- Cell sizes must remain profile-driven so future scale changes can migrate stable addresses instead of discarding built content.
- Tenebrae's first-pass core is four Realm Sections: Sanctuary Reach, Northern Spires, Eastern March, and Southern Return, returning toward Sanctuary Reach for Rowena.


## v0.4.47 Monastery Replacement Scope Rule

When Derek asks to replace the Sanctuary monastery/church with the selected building-kit footprint and place the lake north of it, treat that as a Godot project/layout patch, not an image-generation request.

The replacement scope is:

```text
- Preserve the existing resurrection, Save Shrine, ghost-start, and Gaia/developer-map systems.
- Use the selected compact church / village-room-cluster footprint direction.
- Place the lake north of the monastery.
- Do not touch DK Build Integrator.
- Do not generate new images unless Derek explicitly asks for a picture/image.
```

A future final-art pass may replace the rough modular scene rectangles, but the gameplay anchors and north-lake intent must remain protected unless Derek changes the layout.


## v0.4.48 Repair Authorisation Clarification

When Derek lists bugs or says what must be fixed after installing a patch, treat those words as repair notes until he explicitly authorises a package with words such as `patch` or `build`.

For v0.4.48, Derek explicitly authorised the repair package with `patch` after the v0.4.47 monastery defects were listed. This preserves the rule that defect notes alone are not build permission.


## v0.4.49 Pond Border And Camera Zoom Rule

The lake/pond selected border, water interaction boundary, and water-footstep boundary must share the same underlying water polygon or a single authoritative equivalent. Do not let a yellow editor/debug border drift away from actual water logic. If the player is on dry land, water footstep audio must not trigger.

Camera zoom complaints from Derek are gameplay Goblins, not cosmetics. Startup zoom and zoom-out limits must be test-covered when changed.


## v0.4.50 Camera Zoom Protected Value Rule

Camera zoom is owner-sensitive and off limits after the explicitly requested v0.4.50 repair. Do not alter default zoom, zoom limits, startup camera snap, saved zoom handling, or camera feel in unrelated work. If Derek explicitly orders a zoom/camera change, all active script and scene-exported zoom sources must be inspected and aligned together before packaging.


## v0.4.51 2D Editor Startup Guard Rule

Demon Killer is a 2D Godot project and should open into the Godot 2D workspace by default. The editor-only `addons/dk_editor_startup_2d` guard exists to correct Godot layout/session restore when it opens the project in 3D view. Do not remove, disable, or replace this guard unless Derek explicitly approves another verified 2D startup solution. The guard must not alter runtime camera zoom, player camera feel, Build Integrator behaviour, map art, or gameplay state.
