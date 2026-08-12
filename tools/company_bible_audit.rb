#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../compiler/ast_nodes'

ROOT = File.expand_path('..', __dir__)
CANONICAL_PATH = 'docs/company_bible/BASIC_SHARP_COMPANY_BIBLE.md'
CANONICAL_FULL_PATH = File.join(ROOT, CANONICAL_PATH)
REFERENCE_PATHS = [
  'README.md',
  'docs/roadmap/BASIC_SHARP_ROADMAP.md',
  'docs/hand_off/BASIC_SHARP_MASTER_THREAD_HANDOFF.md'
].freeze

RETIRED_SOURCES = [
  "docs/company_bible/BASIC_SHARP_COMPANY_BIBLE_CARRYOVER_v0_1_14.md",
  "docs/company_bible/COMPANY_BIBLE_ADDENDUM_v0.1.87_No_Loose_Files.md",
  "docs/company_bible/COMPANY_BIBLE_ADDENDUM_v0.1.88_NES_Overworld_Cell_Build_Safety.md",
  "docs/company_bible/COMPANY_BIBLE_DemonKiller.md",
  "docs/company_bible/COMPANY_BIBLE_DemonKiller.md.meta",
  "docs/company_bible/DK_Godot_Company_Bible_Carryover_Note.md",
  "docs/company_bible/DK_Godot_v0_1_13_Documentation_Record_Note.md",
  "docs/company_bible/DK_Godot_v0_1_16_Immediate_Patch_Inclusion_Rule.md",
  "docs/company_bible/DK_Godot_v0_1_17_Documentation_Discipline_Addendum.md",
  "docs/company_bible/DK_Godot_v0_1_18_Immediate_Request_Completion_Reinforcement.md",
  "docs/company_bible/DK_Godot_v0_1_18_No_Image_Unless_Explicit_Rule.md",
  "docs/company_bible/DK_Godot_v0_1_19_FailedPatchRetry_Documentation_Rule.md",
  "docs/company_bible/DK_Godot_v0_1_20_Failed_Visual_Patch_Retry_Rule.md",
  "docs/company_bible/DK_Godot_v0_1_82_RESTORE_OLD_CELLS_KEEP_NEWMAP_VISIBLE_NO_MAP_REPLACEMENT_RULE.md",
  "docs/company_bible/DK_Godot_v0_1_89_MAIN_INSURANCE_POLICY_ADDENDUM.md",
  "docs/company_bible/DK_Godot_v0_1_90_VERSIONING_AND_MAIN_SAFETY_ADDENDUM.md",
  "docs/company_bible/DK_Godot_v0_1_91_DOOR_NAMING_AND_MAIN_UID_SAFETY_ADDENDUM.md",
  "docs/company_bible/DK_Godot_v0_1_92_PROJECT_IDENTITY_RULE_ADDENDUM.md",
  "docs/company_bible/DK_Godot_v0_2_01_VERSION_DISPLAY_AND_BACKUP_TITLE_RULE_ADDENDUM.md",
  "docs/company_bible/DK_Godot_v0_2_02_ZERO_TWO_TERRITORY_AND_VERSION_HABIT_ADDENDUM.md",
  "docs/company_bible/DK_Godot_v0_2_04_DOOR_TEMPLATE_CREATE_FIX_ADDENDUM.md",
  "docs/company_bible/DK_Godot_v0_2_05_DOOR_TEMPLATE_COPY_AND_STALE_LINK_FIX_ADDENDUM.md",
  "docs/company_bible/DK_Godot_v0_2_06_DOOR_TEMPLATE_PASTE_NORMALIZER_ADDENDUM.md",
  "docs/company_bible/DK_Godot_v0_2_06_PRE_DRAW_ORDER_BACKUP_HANDSHAKE_COMPANY_BIBLE_NOTE.md",
  "docs/company_bible/DK_Godot_v0_2_07_CELL_DOOR_DRAW_ORDER_FIX_ADDENDUM.md",
  "docs/company_bible/DK_Godot_v0_2_08_DOOR_LINK_NO_DUPLICATE_FIX_ADDENDUM.md",
  "docs/company_bible/DK_Godot_v0_2_08_PACKAGE_STRUCTURE_AND_BACKUP_RULES_ADDENDUM.md",
  "docs/company_bible/DK_Godot_v0_2_09_PROJECT_VERSION_OPEN_SCREEN_FIX_ADDENDUM.md",
  "docs/company_bible/DK_Godot_v0_2_10_SPRITE_PLAYER_BODYRECT_HOTFIX_ADDENDUM.md",
  "docs/company_bible/DK_Godot_v0_2_11_DOOR_CLEANUP_HOTFIX_ADDENDUM.md",
  "docs/company_bible/DK_Godot_v0_2_12_DOOR_ORPHAN_CLEANUP_HOTFIX_ADDENDUM.md",
  "docs/company_bible/DK_Godot_v0_2_14_DOOR_COPY_PROMOTION_HOTFIX_ADDENDUM.md",
  "docs/company_bible/DK_Godot_v0_2_15_DOOR_COPY_UNDO_LINK_HOTFIX_ADDENDUM.md",
  "docs/company_bible/DK_Godot_v0_2_17_NO_IN_PROJECT_SCENE_BACKUPS_REPAIR_ADDENDUM.md",
  "docs/company_bible/DK_Godot_v0_2_33_BUILD_RESPONSE_BOILERPLATE_CLEANUP_ADDENDUM.md",
  "docs/company_bible/DK_Godot_v0_2_35_MAIN_CHANGE_APPROVAL_AND_VERSION_VISIBILITY_ADDENDUM.md",
  "docs/company_bible/DK_Godot_v0_2_38_SEPARATE_BACKUP_DISCRETION_AND_PACKAGE_SEPARATION_ADDENDUM.md",
  "docs/company_bible/DK_Godot_v0_2_44_ATTRIBUTION_BEYOND_LEGAL_MINIMUM_ADDENDUM.md",
  "docs/company_bible/DK_Godot_v0_2_81_CAMERA_ZOOM_CONTROL_ADDENDUM.md",
  "docs/company_bible/DK_Godot_v0_2_82_BIBLE_FIRST_THEN_ASK_DEREK_ADDENDUM.md",
  "docs/company_bible/DK_Godot_v0_2_85_NUMERIC_ONLY_VERSIONING_ADDENDUM.md",
  "docs/company_bible/DK_Godot_v0_2_88_VERSIONED_DELIVERABLE_ARCHIVE_NAME_ADDENDUM.md",
  "docs/company_bible/DK_Godot_v0_2_90_SEQUENTIAL_BUILD_EXECUTION_ADDENDUM.md",
  "docs/company_bible/DK_Godot_v0_2_96_NO_ORPHAN_TOOL_TEST_FILES_AND_ALWAYS_DOCUMENT_ADDENDUM.md",
  "docs/company_bible/DK_Godot_v0_2_97_DK_LIVE_BUILDER_EXACT_MENU_NAME_ADDENDUM.md",
  "docs/company_bible/DK_Godot_v0_2_98_APPROVED_MAIN_MENU_ART_LOCK_ADDENDUM.md",
  "docs/company_bible/DK_Godot_v0_3_02_FAITH_MAP_AND_BUILDING_LAYERING_ADDENDUM.md",
  "docs/company_bible/DK_Godot_v0_3_04_PRACTICAL_ARCHITECTURE_AND_TOOLCHAIN_ADDENDUM.md",
  "docs/company_bible/DK_Godot_v0_3_05_ORIGINAL_PERSISTENT_SERVER_ARCHITECTURE_ADDENDUM.md",
  "docs/company_bible/DK_Godot_v0_3_09_STREAMING_REGION_CELL_AND_HOUSE_SPELLING_ADDENDUM.md",
  "docs/company_bible/DK_Godot_v0_3_23_LIVE_BUILDER_LOCAL_VALIDATION_ADDENDUM.md",
  "docs/company_bible/DK_Godot_v0_3_31_CODE_FIRST_MIGRATION_AND_VISUAL_BOUNDARY_ADDENDUM.md",
  "docs/company_bible/DK_Godot_v0_3_32_COMPANY_BIBLE_PREBUILD_CHECKLIST_ENFORCEMENT_ADDENDUM.md",
  "docs/company_bible/DK_Godot_v0_3_34_LIVE_BUILDER_PROJECT_MODE_VALIDATION_ADDENDUM.md",
  "docs/company_bible/DK_Godot_v0_3_35_EXACT_ENGINE_VALIDATION_AND_CONSTANT_EXPRESSION_ADDENDUM.md",
  "docs/company_bible/DK_Godot_v0_3_36_BOUNDED_VALIDATION_SAFETY_ADDENDUM.md",
  "docs/company_bible/DK_Godot_v0_3_37_WINDOWS_SAFE_VALIDATION_TELEMETRY_ADDENDUM.md",
  "docs/company_bible/DK_Godot_v0_3_38_INVISIBLE_REGION_BOUNDARY_RULE_ADDENDUM.md",
  "docs/company_bible/DK_Godot_v0_3_45_AUTOMATED_PLAYTEST_PILOT_AND_REPORTING_ADDENDUM.md",
  "docs/company_bible/DK_Godot_v0_3_46_CUMULATIVE_THREAD_HANDOFF_AND_CONTINUITY_LOGGING_ADDENDUM.md",
  "docs/company_bible/DK_Godot_v0_3_47_DEMON_KILLER_VISUAL_STYLE_AND_COMPACT_PANEL_ADDENDUM.md",
  "docs/company_bible/DK_Godot_v0_3_48_OWNER_CONTRIBUTOR_AND_ATTRIBUTION_CLARITY_ADDENDUM.md",
  "docs/company_bible/DK_Godot_v0_3_57_BUILD_THE_GAME_WE_WANT_ADDENDUM.md",
  "docs/company_bible/DK_Godot_v0_3_69_MIT_INTEGRATION_AND_VISIBLE_UI_RULE_ADDENDUM.md",
  "docs/company_bible/DK_Godot_v0_3_73_CANONICAL_HANDOFF_COMPLETION_REPAIR_ADDENDUM.md",
  "docs/company_bible/DK_Godot_v0_3_77_BUILD_INTEGRATOR_BACKUP_AUTHORITY_ADDENDUM.md",
  "docs/company_bible/DK_Godot_v0_4_14_WARNING_HYGIENE_AND_SYSTEMS_FIRST_ADDENDUM.md",
  "docs/company_bible/DK_Godot_v0_4_20_PREBUILD_SCOPE_PREAPPROVAL_AND_STOP_RULE_ADDENDUM.md",
  "docs/company_bible/DK_Godot_v0_4_21_AUDIT_TRAIL_NO_SCRUB_RULE_ADDENDUM.md",
  "docs/company_bible/DK_Godot_v0_4_37_PATCH_MANIFEST_SCHEMA_AND_ENVIRONMENT_LIMITATION_ADDENDUM.md",
  "docs/company_bible/DK_Godot_v0_4_38_GAIA_STREAMING_CELL_AND_IMAGE_PERMISSION_ADDENDUM.md",
  "docs/company_bible/DK_Godot_v0_4_70_POST_BUILD_GIT_AND_NO_HARD_GATE_RULE_ADDENDUM.md",
  "docs/company_bible/PROJECT_BIBLE_DemonKiller.md",
  "docs/company_bible/PROJECT_BIBLE_DemonKiller.md.meta"
].freeze

MANDATORY_TEXT = [
  '# BASIC# Company Bible',
  'This file is the **one active Company Bible for BASIC#**.',
  'Derek is the owner and final authority',
  'Acknowledge Derek before beginning lengthy inspection or tool work.',
  'Implementation begins only after Derek explicitly approves',
  'When Derek says **stop**',
  'next unused numeric version',
  'changed-files-only ZIP',
  'BASIC_SHARP_CHANGED_FILES_PATCH',
  'Git and the validated installer are the primary recovery authorities.',
  'Warnings are treated as failures by default.',
  'docs/hand_off/BASIC_SHARP_MASTER_THREAD_HANDOFF.md',
  'Do not create new per-version `NEW_THREAD_HANDOFF` files.',
  'Do not create another Bible file.',
  'Language name: BASIC#',
  'The opening `(` in official words',
  'Only generate or edit an image when Derek gives a clear direct command',
  'Commercialization is intentionally shelved',
  'reasonably priced monthly option',
  'Adobe-style loss of local tool access',
  'v0.1.25 consolidation ledger',
  'Executable bytecode: BSharp Bytecode',
  'Short bytecode name: BSBC',
  'Bytecode extension: .bsbc',
  'Bytecode Profile 1: bsharp.bytecode.v1',
  'Bytecode Profile 2: bsharp.bytecode.v2',
  'Bytecode Profile 4: bsharp.bytecode.v4',
  'Bytecode Profile 7: bsharp.bytecode.v7',
  'Stable Meaning Profile 2: bsharp.meaning.v2',
  'Stable Meaning Profile 4: bsharp.meaning.v4',
  'Stable Meaning Profile 7: bsharp.meaning.v7',
  'Virtual machine: BSharp Virtual Machine',
  'must not reconstruct BSIR or call the reference Ruby runtime',
  'Protected BASIC# visual grammar',
  '`PLAYER` for the built-in player',
  '`CONTROLS`, `HOVER`, and `CONTEXT`',
  'BASIC# uses IF / OTHERWISE, never IF / ELSE.',
  'Self-hosting must be earned in stages.',
  'spec/self_hosting/BASIC_SHARP_SELF_HOSTING_SUBSET_v1.json',
  'spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_PARSER_v1.json',
  'spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_IR_EMITTER_v1.json',
  'spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_IR_PARITY_HARNESS_v1.json',
  'spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_ERROR_CONTRACT_v1.json',
  'Five Point Paradigm',
  'Turn human intent into real software behaviour.',
  'Huge Human Problem',
  'Radical Human Bridge',
  'Breakthrough Machine',
  'Proof Under Fire',
  'Creator Ownership',
  'docs/BASIC_SHARP_DOCUMENTATION_MAP.md',
  'spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_SCENE_BLOCK_EXPANSION_v1.json',
  'docs/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_SCENE_BLOCK_EXPANSION_v0_1_53.md',
  'compiler/small_compiler_subset_scene_block_expansion.rb',
  'spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_SYMBOL_TABLE_CONTRACT_v1.json',
  'docs/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_SYMBOL_TABLE_CONTRACT_v0_1_54.md',
  'compiler/small_compiler_subset_symbol_table_contract.rb',
  'ByteTide decision record',
  'spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_BSBC_EMITTER_v1.json',
  'docs/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_BSBC_EMITTER_v0_1_55.md',
  'compiler/small_compiler_subset_bsbc_emitter.rb',
  'spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_BSBC_PARITY_HARNESS_v1.json',
  'docs/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_BSBC_PARITY_HARNESS_v0_1_56.md',
  'compiler/small_compiler_subset_bsbc_parity_harness.rb',
  'spec/self_hosting/BASIC_SHARP_SELF_HOSTING_FIXTURE_CORPUS_v1.json',
  'docs/self_hosting/BASIC_SHARP_SELF_HOSTING_FIXTURE_CORPUS_v0_1_57.md',
  'compiler/self_hosting_fixture_corpus.rb',
  'Elderedd Softworks LLC',
  'Elderedd Laboratory',
  'BCS',
  'Never make the BASIC# GitHub repository public',
  'GitHub description update',
  'spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_RUNTIME_SMOKE_v1.json',
  'docs/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_RUNTIME_SMOKE_v0_1_58.md',
  'compiler/small_compiler_subset_runtime_smoke.rb',
  'Small Compiler Subset Runtime Smoke',
  'spec/self_hosting/BASIC_SHARP_BOOTSTRAP_BOUNDARY_AUDIT_v1.json',
  'docs/self_hosting/BASIC_SHARP_BOOTSTRAP_BOUNDARY_AUDIT_v0_1_59.md',
  'compiler/bootstrap_boundary_audit.rb',
  'Bootstrap Boundary Audit',
  'spec/self_hosting/BASIC_SHARP_README_CURRENT_RELEASE_TRUTH_v1.json',
  'compiler/readme_current_release_truth.rb',
  'README Current Release Truth Gate',
  'spec/self_hosting/BASIC_SHARP_SELF_HOSTING_MILESTONE_1_v1.json',
  'compiler/self_hosting_milestone_1.rb',
  'Self-Hosting Milestone 1',
  'not full self-hosting',
  'Ruby remains the bootstrap compiler'
].freeze

files = Dir.glob(File.join(ROOT, 'docs/company_bible/*'), File::FNM_DOTMATCH).reject do |path|
  [File.join(ROOT, 'docs/company_bible/.'), File.join(ROOT, 'docs/company_bible/..')].include?(path)
end
raise "Expected one Company Bible file, found #{files.length}" unless files == [CANONICAL_FULL_PATH]
puts "BASIC# Company Bible Audit v#{BasicSharp::VERSION}"
puts 'Canonical file count: PASS'

text = File.read(CANONICAL_FULL_PATH, encoding: 'UTF-8')
header_version = text[/\*\*Version:\*\* v([^\s]+)\s*$/, 1]
raise 'Canonical Company Bible header version is missing' unless header_version
raise "Canonical Company Bible header version #{header_version} does not match BASIC# #{BasicSharp::VERSION}" unless header_version == BasicSharp::VERSION
puts 'Canonical header version: PASS'
raise 'Canonical Company Bible identity is missing' unless text.start_with?("# BASIC# Company Bible
")
raise 'Canonical path declaration is missing' unless text.include?(CANONICAL_PATH)
puts 'Canonical identity: PASS'

missing_text = MANDATORY_TEXT.reject { |entry| text.include?(entry) }
raise "Mandatory Company Bible text missing: #{missing_text.join(', ')}" unless missing_text.empty?
puts 'Mandatory sections: PASS'

missing_sources = RETIRED_SOURCES.reject { |path| text.include?("`#{path}`") }
raise "Consolidation ledger is missing: #{missing_sources.join(', ')}" unless missing_sources.empty?
raise 'Consolidation ledger source count is not 74' unless RETIRED_SOURCES.length == 74
puts 'Consolidation ledger: PASS'

REFERENCE_PATHS.each do |path|
  reference = File.read(File.join(ROOT, path), encoding: 'UTF-8')
  raise "Current reference missing canonical Company Bible path: #{path}" unless reference.include?(CANONICAL_PATH)
end
puts 'Current references: PASS'

forbidden = files.select do |path|
  File.basename(path).match?(/addendum|carryover|project[_ -]?bible|\.meta\z/i)
end
raise "Forbidden active Company Bible fragments: #{forbidden.join(', ')}" unless forbidden.empty?
raise 'Standalone addendum prohibition is missing' unless text.include?('Do not create another standalone Company Bible addendum')
puts 'No standalone addendums: PASS'
puts
puts 'COMPANY BIBLE AUDIT: PASS'
