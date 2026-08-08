#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require_relative '../compiler/ast_nodes'

ROOT = File.expand_path('..', __dir__)
SPEC_PATH = File.join(ROOT, 'spec/self_hosting/BASIC_SHARP_SELF_HOSTING_SUBSET_v1.json')
DOC_PATH = File.join(ROOT, 'docs/self_hosting/BASIC_SHARP_SELF_HOSTING_FOUNDATION_v0_1_44.md')
TOKENIZER_READER_SPEC_PATH = File.join(ROOT, 'spec/self_hosting/BASIC_SHARP_TOKENIZER_READER_CONTRACT_v1.json')
TOKENIZER_READER_DOC_PATH = File.join(ROOT, 'docs/self_hosting/BASIC_SHARP_TOKENIZER_READER_CONTRACT_v0_1_47.md')
TOKENIZER_READER_IMPLEMENTATION_DOC_PATH = File.join(ROOT, 'docs/self_hosting/BASIC_SHARP_TOKENIZER_READER_IMPLEMENTATION_v0_1_48.md')
SMALL_COMPILER_SUBSET_PARSER_SPEC_PATH = File.join(ROOT, 'spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_PARSER_v1.json')
SMALL_COMPILER_SUBSET_PARSER_DOC_PATH = File.join(ROOT, 'docs/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_PARSER_v0_1_49.md')
SMALL_COMPILER_SUBSET_IR_EMITTER_SPEC_PATH = File.join(ROOT, 'spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_IR_EMITTER_v1.json')
SMALL_COMPILER_SUBSET_IR_EMITTER_DOC_PATH = File.join(ROOT, 'docs/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_IR_EMITTER_v0_1_50.md')
SMALL_COMPILER_SUBSET_IR_PARITY_HARNESS_SPEC_PATH = File.join(ROOT, 'spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_IR_PARITY_HARNESS_v1.json')
SMALL_COMPILER_SUBSET_IR_PARITY_HARNESS_DOC_PATH = File.join(ROOT, 'docs/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_IR_PARITY_HARNESS_v0_1_51.md')
SMALL_COMPILER_SUBSET_ERROR_CONTRACT_SPEC_PATH = File.join(ROOT, 'spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_ERROR_CONTRACT_v1.json')
SMALL_COMPILER_SUBSET_ERROR_CONTRACT_DOC_PATH = File.join(ROOT, 'docs/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_ERROR_CONTRACT_v0_1_52.md')
SMALL_COMPILER_SUBSET_SCENE_BLOCK_EXPANSION_SPEC_PATH = File.join(ROOT, 'spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_SCENE_BLOCK_EXPANSION_v1.json')
SMALL_COMPILER_SUBSET_SCENE_BLOCK_EXPANSION_DOC_PATH = File.join(ROOT, 'docs/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_SCENE_BLOCK_EXPANSION_v0_1_53.md')
SMALL_COMPILER_SUBSET_SYMBOL_TABLE_CONTRACT_SPEC_PATH = File.join(ROOT, 'spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_SYMBOL_TABLE_CONTRACT_v1.json')
SMALL_COMPILER_SUBSET_SYMBOL_TABLE_CONTRACT_DOC_PATH = File.join(ROOT, 'docs/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_SYMBOL_TABLE_CONTRACT_v0_1_54.md')
SMALL_COMPILER_SUBSET_BSBC_EMITTER_SPEC_PATH = File.join(ROOT, 'spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_BSBC_EMITTER_v1.json')
SMALL_COMPILER_SUBSET_BSBC_EMITTER_DOC_PATH = File.join(ROOT, 'docs/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_BSBC_EMITTER_v0_1_55.md')
SMALL_COMPILER_SUBSET_BSBC_PARITY_HARNESS_SPEC_PATH = File.join(ROOT, 'spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_BSBC_PARITY_HARNESS_v1.json')
SMALL_COMPILER_SUBSET_BSBC_PARITY_HARNESS_DOC_PATH = File.join(ROOT, 'docs/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_BSBC_PARITY_HARNESS_v0_1_56.md')
SELF_HOSTING_FIXTURE_CORPUS_SPEC_PATH = File.join(ROOT, 'spec/self_hosting/BASIC_SHARP_SELF_HOSTING_FIXTURE_CORPUS_v1.json')
SELF_HOSTING_FIXTURE_CORPUS_DOC_PATH = File.join(ROOT, 'docs/self_hosting/BASIC_SHARP_SELF_HOSTING_FIXTURE_CORPUS_v0_1_57.md')
SMALL_COMPILER_SUBSET_RUNTIME_SMOKE_SPEC_PATH = File.join(ROOT, 'spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_RUNTIME_SMOKE_v1.json')
SMALL_COMPILER_SUBSET_RUNTIME_SMOKE_DOC_PATH = File.join(ROOT, 'docs/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_RUNTIME_SMOKE_v0_1_58.md')
BOOTSTRAP_BOUNDARY_AUDIT_SPEC_PATH = File.join(ROOT, 'spec/self_hosting/BASIC_SHARP_BOOTSTRAP_BOUNDARY_AUDIT_v1.json')
BOOTSTRAP_BOUNDARY_AUDIT_DOC_PATH = File.join(ROOT, 'docs/self_hosting/BASIC_SHARP_BOOTSTRAP_BOUNDARY_AUDIT_v0_1_59.md')
README_CURRENT_RELEASE_TRUTH_SPEC_PATH = File.join(ROOT, 'spec/self_hosting/BASIC_SHARP_README_CURRENT_RELEASE_TRUTH_v1.json')
README_CURRENT_RELEASE_TRUTH_DOC_PATH = File.join(ROOT, 'docs/self_hosting/BASIC_SHARP_README_CURRENT_RELEASE_TRUTH_v0_1_61.md')
SELF_HOSTING_MILESTONE_1_SPEC_PATH = File.join(ROOT, 'spec/self_hosting/BASIC_SHARP_SELF_HOSTING_MILESTONE_1_v1.json')
SELF_HOSTING_MILESTONE_1_DOC_PATH = File.join(ROOT, 'docs/self_hosting/BASIC_SHARP_SELF_HOSTING_MILESTONE_1_v0_1_61.md')
REFERENCE_PATHS = [
  'README.md',
  'docs/roadmap/BASIC_SHARP_ROADMAP.md',
  'docs/hand_off/BASIC_SHARP_MASTER_THREAD_HANDOFF.md',
  'docs/company_bible/BASIC_SHARP_COMPANY_BIBLE.md',
  'docs/self_hosting/BASIC_SHARP_TOKENIZER_READER_CONTRACT_v0_1_47.md',
  'docs/self_hosting/BASIC_SHARP_TOKENIZER_READER_IMPLEMENTATION_v0_1_48.md',
  'docs/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_PARSER_v0_1_49.md',
  'docs/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_IR_EMITTER_v0_1_50.md',
  'docs/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_IR_PARITY_HARNESS_v0_1_51.md',
  'docs/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_ERROR_CONTRACT_v0_1_52.md',
  'spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_SCENE_BLOCK_EXPANSION_v1.json',
  'docs/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_SCENE_BLOCK_EXPANSION_v0_1_53.md',
  'spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_SYMBOL_TABLE_CONTRACT_v1.json',
  'docs/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_SYMBOL_TABLE_CONTRACT_v0_1_54.md',
  'spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_BSBC_EMITTER_v1.json',
  'docs/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_BSBC_EMITTER_v0_1_55.md',
  'spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_BSBC_PARITY_HARNESS_v1.json',
  'docs/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_BSBC_PARITY_HARNESS_v0_1_56.md',
  'spec/self_hosting/BASIC_SHARP_SELF_HOSTING_FIXTURE_CORPUS_v1.json',
  'docs/self_hosting/BASIC_SHARP_SELF_HOSTING_FIXTURE_CORPUS_v0_1_57.md',
  'spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_RUNTIME_SMOKE_v1.json',
  'docs/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_RUNTIME_SMOKE_v0_1_58.md',
  'spec/self_hosting/BASIC_SHARP_BOOTSTRAP_BOUNDARY_AUDIT_v1.json',
  'docs/self_hosting/BASIC_SHARP_BOOTSTRAP_BOUNDARY_AUDIT_v0_1_59.md',
  'spec/self_hosting/BASIC_SHARP_README_CURRENT_RELEASE_TRUTH_v1.json',
  'docs/self_hosting/BASIC_SHARP_README_CURRENT_RELEASE_TRUTH_v0_1_61.md',
  'spec/self_hosting/BASIC_SHARP_SELF_HOSTING_MILESTONE_1_v1.json',
  'docs/self_hosting/BASIC_SHARP_SELF_HOSTING_MILESTONE_1_v0_1_61.md'
].freeze

spec = JSON.parse(File.read(SPEC_PATH, encoding: 'UTF-8'))

def assert_contract!(condition, message)
  raise "Self-hosting contract failed: #{message}" unless condition
end

assert_contract!(spec.fetch('format') == 'bsharp.self_hosting.subset.json', 'wrong spec identity')
assert_contract!(spec.fetch('format_version') == 1, 'wrong spec format version')
assert_contract!(spec.fetch('target_version') == BasicSharp::VERSION, 'spec target does not match BasicSharp::VERSION')
assert_contract!(spec.fetch('status') == 'foundation_contract_only', 'a carried self-hosting foundation must remain a foundation contract')
assert_contract!(spec.fetch('compiler_subset_name') == 'BSharp Compiler Subset 0', 'subset name changed')
assert_contract!(spec.fetch('compiler_subset_status') == 'self_hosting_milestone_1_under_ruby_referee', 'subset status changed')

profiles = spec.fetch('approved_profiles_available_to_creator_programs')
assert_contract!(profiles == (1..7).map { |n| "bsharp.meaning.v#{n}" }, 'approved profile list changed')

forbidden = spec.fetch('compiler_subset_forbids_until_later_approval')
%w[Profile\ 8 loops collections].each do |term|
  assert_contract!(forbidden.any? { |entry| entry.include?(term) }, "missing future-exclusion #{term}")
end
assert_contract!(forbidden.include?('replacing the Ruby bootstrap compiler'), 'Ruby replacement must stay forbidden')
assert_contract!(forbidden.include?('claiming BASIC# is self-hosted'), 'self-hosting claim must stay forbidden')
assert_contract!(forbidden.include?('BSharp native document application work'), 'document app must stay out of the current build')

documents = spec.fetch('documents')
assert_contract!(documents.fetch('tokenizer_reader_spec') == 'spec/self_hosting/BASIC_SHARP_TOKENIZER_READER_CONTRACT_v1.json', 'tokenizer/reader spec path missing')
assert_contract!(File.file?(TOKENIZER_READER_SPEC_PATH), 'tokenizer/reader spec is missing')
assert_contract!(File.file?(TOKENIZER_READER_DOC_PATH), 'tokenizer/reader contract document is missing')
assert_contract!(File.file?(TOKENIZER_READER_IMPLEMENTATION_DOC_PATH), 'tokenizer/reader implementation document is missing')
assert_contract!(File.file?(SMALL_COMPILER_SUBSET_PARSER_SPEC_PATH), 'small compiler subset parser spec is missing')
assert_contract!(File.file?(SMALL_COMPILER_SUBSET_PARSER_DOC_PATH), 'small compiler subset parser document is missing')
assert_contract!(File.file?(SMALL_COMPILER_SUBSET_IR_EMITTER_SPEC_PATH), 'small compiler subset IR emitter spec is missing')
assert_contract!(File.file?(SMALL_COMPILER_SUBSET_IR_EMITTER_DOC_PATH), 'small compiler subset IR emitter document is missing')
assert_contract!(File.file?(SMALL_COMPILER_SUBSET_IR_PARITY_HARNESS_SPEC_PATH), 'small compiler subset IR parity harness spec is missing')
assert_contract!(File.file?(SMALL_COMPILER_SUBSET_IR_PARITY_HARNESS_DOC_PATH), 'small compiler subset IR parity harness document is missing')
assert_contract!(File.file?(SMALL_COMPILER_SUBSET_ERROR_CONTRACT_SPEC_PATH), 'small compiler subset error contract spec is missing')
assert_contract!(File.file?(SMALL_COMPILER_SUBSET_ERROR_CONTRACT_DOC_PATH), 'small compiler subset error contract document is missing')
assert_contract!(File.file?(SMALL_COMPILER_SUBSET_SCENE_BLOCK_EXPANSION_SPEC_PATH), 'small compiler subset scene/block expansion spec is missing')
assert_contract!(File.file?(SMALL_COMPILER_SUBSET_SCENE_BLOCK_EXPANSION_DOC_PATH), 'small compiler subset scene/block expansion document is missing')
assert_contract!(File.file?(SMALL_COMPILER_SUBSET_SYMBOL_TABLE_CONTRACT_SPEC_PATH), 'small compiler subset symbol table contract spec is missing')
assert_contract!(File.file?(SMALL_COMPILER_SUBSET_SYMBOL_TABLE_CONTRACT_DOC_PATH), 'small compiler subset symbol table contract document is missing')
assert_contract!(File.file?(SMALL_COMPILER_SUBSET_BSBC_EMITTER_SPEC_PATH), 'small compiler subset BSBC emitter spec is missing')
assert_contract!(File.file?(SMALL_COMPILER_SUBSET_BSBC_EMITTER_DOC_PATH), 'small compiler subset BSBC emitter document is missing')
assert_contract!(File.file?(SMALL_COMPILER_SUBSET_BSBC_PARITY_HARNESS_SPEC_PATH), 'small compiler subset BSBC parity harness spec is missing')
assert_contract!(File.file?(SMALL_COMPILER_SUBSET_BSBC_PARITY_HARNESS_DOC_PATH), 'small compiler subset BSBC parity harness document is missing')
assert_contract!(File.file?(SELF_HOSTING_FIXTURE_CORPUS_SPEC_PATH), 'self-hosting fixture corpus spec is missing')
assert_contract!(File.file?(SELF_HOSTING_FIXTURE_CORPUS_DOC_PATH), 'self-hosting fixture corpus document is missing')
assert_contract!(File.file?(SMALL_COMPILER_SUBSET_RUNTIME_SMOKE_SPEC_PATH), 'small compiler subset runtime smoke spec is missing')
assert_contract!(File.file?(SMALL_COMPILER_SUBSET_RUNTIME_SMOKE_DOC_PATH), 'small compiler subset runtime smoke document is missing')
assert_contract!(documents.fetch('bootstrap_boundary_audit_spec') == 'spec/self_hosting/BASIC_SHARP_BOOTSTRAP_BOUNDARY_AUDIT_v1.json', 'bootstrap boundary audit spec path missing')
assert_contract!(File.file?(BOOTSTRAP_BOUNDARY_AUDIT_SPEC_PATH), 'bootstrap boundary audit spec is missing')
assert_contract!(File.file?(BOOTSTRAP_BOUNDARY_AUDIT_DOC_PATH), 'bootstrap boundary audit document is missing')
assert_contract!(File.file?(File.join(ROOT, documents.fetch('bootstrap_boundary_audit_file'))), 'bootstrap boundary audit implementation is missing')
assert_contract!(File.file?(File.join(ROOT, documents.fetch('bootstrap_boundary_audit_tool'))), 'bootstrap boundary audit tool is missing')
assert_contract!(File.file?(File.join(ROOT, documents.fetch('bootstrap_boundary_audit_test'))), 'bootstrap boundary audit test is missing')
assert_contract!(documents.fetch('readme_current_release_truth_spec') == 'spec/self_hosting/BASIC_SHARP_README_CURRENT_RELEASE_TRUTH_v1.json', 'README truth spec path missing')
assert_contract!(File.file?(README_CURRENT_RELEASE_TRUTH_SPEC_PATH), 'README current release truth spec is missing')
assert_contract!(File.file?(README_CURRENT_RELEASE_TRUTH_DOC_PATH), 'README current release truth document is missing')
assert_contract!(File.file?(File.join(ROOT, documents.fetch('readme_current_release_truth_tool'))), 'README current release truth tool is missing')
assert_contract!(documents.fetch('self_hosting_milestone_1_spec') == 'spec/self_hosting/BASIC_SHARP_SELF_HOSTING_MILESTONE_1_v1.json', 'Self-Hosting Milestone 1 spec path missing')
assert_contract!(File.file?(SELF_HOSTING_MILESTONE_1_SPEC_PATH), 'Self-Hosting Milestone 1 spec is missing')
assert_contract!(File.file?(SELF_HOSTING_MILESTONE_1_DOC_PATH), 'Self-Hosting Milestone 1 document is missing')
assert_contract!(File.file?(File.join(ROOT, documents.fetch('self_hosting_milestone_1_tool'))), 'Self-Hosting Milestone 1 tool is missing')

rules = spec.fetch('acceptance_rules')
assert_contract!(rules.any? { |entry| entry.include?('Ruby remains the bootstrap') }, 'Ruby referee rule missing')
assert_contract!(rules.any? { |entry| entry.include?('small compiler subset parser') }, 'subset parser rule missing')
assert_contract!(rules.any? { |entry| entry.include?('small compiler subset IR emitter') }, 'subset IR emitter rule missing')
assert_contract!(rules.any? { |entry| entry.include?('IR golden parity harness') }, 'subset IR parity harness rule missing')
assert_contract!(rules.any? { |entry| entry.include?('plain-English error contract') }, 'subset error contract rule missing')
assert_contract!(rules.any? { |entry| entry.include?('scene/block expansion') }, 'subset scene/block expansion rule missing')
assert_contract!(rules.any? { |entry| entry.include?('symbol table contract') }, 'subset symbol table rule missing')
assert_contract!(rules.any? { |entry| entry.include?('BSBC emitter') }, 'subset BSBC emitter rule missing')
assert_contract!(rules.any? { |entry| entry.include?('BSBC golden parity') }, 'subset BSBC golden parity rule missing')
assert_contract!(rules.any? { |entry| entry.include?('fixture corpus') }, 'self-hosting fixture corpus rule missing')
assert_contract!(rules.any? { |entry| entry.include?('runtime smoke') }, 'small compiler subset runtime smoke rule missing')
assert_contract!(rules.any? { |entry| entry.include?('Profiles 1-7 validation') }, 'Profiles 1-7 validation rule missing')

unless File.file?(DOC_PATH)
  raise "Self-hosting contract document is missing: #{DOC_PATH}"
end
text = File.read(DOC_PATH, encoding: 'UTF-8')
%w[foundation_contract_only Ruby Profile\ 8 BSharp\ Compiler\ Subset\ 0].each do |term|
  assert_contract!(text.include?(term), "contract document missing #{term}")
end
REFERENCE_PATHS.each do |relative|
  reference = File.read(File.join(ROOT, relative), encoding: 'UTF-8')
  assert_contract!(reference.include?('spec/self_hosting/BASIC_SHARP_SELF_HOSTING_SUBSET_v1.json'), "#{relative} does not reference the self-hosting spec")
end

tokenizer_doc = File.read(TOKENIZER_READER_DOC_PATH, encoding: 'UTF-8')
implementation_doc = File.read(TOKENIZER_READER_IMPLEMENTATION_DOC_PATH, encoding: 'UTF-8')
parser_doc = File.read(SMALL_COMPILER_SUBSET_PARSER_DOC_PATH, encoding: 'UTF-8')
ir_emitter_doc = File.read(SMALL_COMPILER_SUBSET_IR_EMITTER_DOC_PATH, encoding: 'UTF-8')
ir_parity_doc = File.read(SMALL_COMPILER_SUBSET_IR_PARITY_HARNESS_DOC_PATH, encoding: 'UTF-8')
error_contract_doc = File.read(SMALL_COMPILER_SUBSET_ERROR_CONTRACT_DOC_PATH, encoding: 'UTF-8')
scene_block_doc = File.read(SMALL_COMPILER_SUBSET_SCENE_BLOCK_EXPANSION_DOC_PATH, encoding: 'UTF-8')
symbol_table_doc = File.read(SMALL_COMPILER_SUBSET_SYMBOL_TABLE_CONTRACT_DOC_PATH, encoding: 'UTF-8')
bsbc_emitter_doc = File.read(SMALL_COMPILER_SUBSET_BSBC_EMITTER_DOC_PATH, encoding: 'UTF-8')
bsbc_parity_doc = File.read(SMALL_COMPILER_SUBSET_BSBC_PARITY_HARNESS_DOC_PATH, encoding: 'UTF-8')
fixture_corpus_doc = File.read(SELF_HOSTING_FIXTURE_CORPUS_DOC_PATH, encoding: 'UTF-8')
runtime_smoke_doc = File.read(SMALL_COMPILER_SUBSET_RUNTIME_SMOKE_DOC_PATH, encoding: 'UTF-8')
bootstrap_boundary_doc = File.read(BOOTSTRAP_BOUNDARY_AUDIT_DOC_PATH, encoding: 'UTF-8')
readme_truth_doc = File.read(README_CURRENT_RELEASE_TRUTH_DOC_PATH, encoding: 'UTF-8')
milestone_doc = File.read(SELF_HOSTING_MILESTONE_1_DOC_PATH, encoding: 'UTF-8')
assert_contract!(tokenizer_doc.include?('contract only'), 'tokenizer/reader contract history must remain contract only')
assert_contract!(implementation_doc.include?('Ruby referee'), 'tokenizer/reader implementation must keep Ruby referee')
assert_contract!(implementation_doc.include?('not the production parser authority'), 'tokenizer/reader implementation must not become parser authority')
assert_contract!(parser_doc.include?('Ruby Parser referee'), 'small compiler subset parser must keep Ruby Parser referee')
assert_contract!(parser_doc.include?('not the production parser authority'), 'small compiler subset parser must not become parser authority')
assert_contract!(ir_emitter_doc.include?('Ruby Parser plus SemanticResolver referee'), 'small compiler subset IR emitter must keep Ruby referee')
assert_contract!(ir_emitter_doc.include?('not the production compiler path'), 'small compiler subset IR emitter must not become compiler path')
assert_contract!(ir_parity_doc.include?('golden BSharp IR parity'), 'small compiler subset IR parity harness must name golden parity')
assert_contract!(ir_parity_doc.include?('not the production compiler path'), 'small compiler subset IR parity harness must not become compiler path')
assert_contract!(error_contract_doc.include?('plain-English error contract'), 'small compiler subset error contract must name plain-English contract')
assert_contract!(error_contract_doc.include?('not the production compiler path'), 'small compiler subset error contract must not become compiler path')
assert_contract!(scene_block_doc.include?('scene/block expansion'), 'small compiler subset scene/block expansion must name scene/block expansion')
assert_contract!(scene_block_doc.include?('not the production compiler path'), 'small compiler subset scene/block expansion must not become compiler path')
assert_contract!(symbol_table_doc.include?('symbol-table contract'), 'small compiler subset symbol table document must name symbol-table contract')
assert_contract!(symbol_table_doc.include?('do not rename the system'), 'ByteTide decision record must preserve system names')
assert_contract!(bsbc_emitter_doc.include?('BSBC bytecode'), 'small compiler subset BSBC emitter must name BSBC bytecode')
assert_contract!(bsbc_emitter_doc.include?('Not the production compiler path') || bsbc_emitter_doc.include?('not the production compiler path'), 'small compiler subset BSBC emitter must not become compiler path')
assert_contract!(bsbc_parity_doc.include?('BSBC Golden Parity Harness'), 'small compiler subset BSBC parity document must name BSBC Golden Parity Harness')
assert_contract!(bsbc_parity_doc.include?('No bytecode or BSBC rename'), 'small compiler subset BSBC parity document must preserve bytecode names')
assert_contract!(fixture_corpus_doc.include?('Self-Hosting Fixture Corpus'), 'fixture corpus document must name Self-Hosting Fixture Corpus')
assert_contract!(fixture_corpus_doc.include?('not the production compiler path'), 'fixture corpus must not become compiler path')
assert_contract!(fixture_corpus_doc.include?('DKLab is retained'), 'DKLab identity decision must be recorded')
assert_contract!(runtime_smoke_doc.include?('Small Compiler Subset Runtime Smoke'), 'runtime smoke document must name runtime smoke')
assert_contract!(runtime_smoke_doc.include?('not the production compiler path'), 'runtime smoke must not become compiler path')
assert_contract!(runtime_smoke_doc.include?('does not claim BASIC# is self-hosted'), 'runtime smoke must not claim self-hosting')
assert_contract!(bootstrap_boundary_doc.include?('Bootstrap Boundary Audit'), 'bootstrap boundary audit document must name the audit')
assert_contract!(bootstrap_boundary_doc.include?('Ruby remains the bootstrap compiler and referee'), 'bootstrap boundary audit must preserve Ruby authority')
assert_contract!(bootstrap_boundary_doc.include?('Claiming BASIC# is self-hosted'), 'bootstrap boundary audit must forbid self-hosting claim')
assert_contract!(readme_truth_doc.include?('README Current Release Truth Gate'), 'README truth document must name the gate')
assert_contract!(milestone_doc.include?('Self-Hosting Milestone 1'), 'milestone document must name the milestone')
assert_contract!(milestone_doc.include?('Ruby remains the bootstrap compiler and referee'), 'milestone document must preserve Ruby authority')

puts "BASIC# Self-Hosting Contract v#{BasicSharp::VERSION}"
puts "Compiler subset: #{spec.fetch('compiler_subset_name')}"
puts "Allowed creator profiles: #{profiles.length}"
puts "Forbidden future items: #{forbidden.length}"
puts 'Ruby bootstrap remains: PASS'
puts 'No self-hosting claim: PASS'
puts 'No Profile 8 or new syntax: PASS'
puts 'Tokenizer/reader contract linked: PASS'
puts 'Tokenizer/reader implementation linked: PASS'
puts 'Small compiler subset parser linked: PASS'
puts 'Small compiler subset IR emitter linked: PASS'
puts 'Small compiler subset IR parity harness linked: PASS'
puts 'Small compiler subset error contract linked: PASS'
puts 'Small compiler subset scene/block expansion linked: PASS'
puts 'Small compiler subset symbol table contract linked: PASS'
puts 'Small compiler subset BSBC emitter linked: PASS'
puts 'Small compiler subset BSBC golden parity harness linked: PASS'
puts 'Self-hosting fixture corpus linked: PASS'
puts 'Small compiler subset runtime smoke linked: PASS'
puts 'Bootstrap boundary audit linked: PASS'
puts 'README current release truth gate linked: PASS'
puts 'Self-Hosting Milestone 1 linked: PASS'
puts 'SELF-HOSTING CONTRACT: PASS'
