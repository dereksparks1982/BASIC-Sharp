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
REFERENCE_PATHS = [
  'README.md',
  'docs/roadmap/BASIC_SHARP_ROADMAP.md',
  'docs/hand_off/BASIC_SHARP_MASTER_THREAD_HANDOFF.md',
  'docs/company_bible/BASIC_SHARP_COMPANY_BIBLE.md',
  'docs/self_hosting/BASIC_SHARP_TOKENIZER_READER_CONTRACT_v0_1_47.md',
  'docs/self_hosting/BASIC_SHARP_TOKENIZER_READER_IMPLEMENTATION_v0_1_48.md',
  'docs/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_PARSER_v0_1_49.md',
  'docs/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_IR_EMITTER_v0_1_50.md'
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
assert_contract!(spec.fetch('compiler_subset_status') == 'ir_emitter_under_ruby_referee', 'subset status changed')

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

rules = spec.fetch('acceptance_rules')
assert_contract!(rules.any? { |entry| entry.include?('Ruby remains the bootstrap') }, 'Ruby referee rule missing')
assert_contract!(rules.any? { |entry| entry.include?('small compiler subset parser') }, 'subset parser rule missing')
assert_contract!(rules.any? { |entry| entry.include?('small compiler subset IR emitter') }, 'subset IR emitter rule missing')
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
assert_contract!(tokenizer_doc.include?('contract only'), 'tokenizer/reader contract history must remain contract only')
assert_contract!(implementation_doc.include?('Ruby referee'), 'tokenizer/reader implementation must keep Ruby referee')
assert_contract!(implementation_doc.include?('not the production parser authority'), 'tokenizer/reader implementation must not become parser authority')
assert_contract!(parser_doc.include?('Ruby Parser referee'), 'small compiler subset parser must keep Ruby Parser referee')
assert_contract!(parser_doc.include?('not the production parser authority'), 'small compiler subset parser must not become parser authority')
assert_contract!(ir_emitter_doc.include?('Ruby Parser plus SemanticResolver referee'), 'small compiler subset IR emitter must keep Ruby referee')
assert_contract!(ir_emitter_doc.include?('not the production compiler path'), 'small compiler subset IR emitter must not become compiler path')

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
puts 'SELF-HOSTING CONTRACT: PASS'
