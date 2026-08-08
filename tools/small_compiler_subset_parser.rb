#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require_relative '../compiler/parser'
require_relative '../compiler/small_compiler_subset_parser'

ROOT = File.expand_path('..', __dir__)
SPEC_PATH = File.join(ROOT, 'spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_PARSER_v1.json')
DOC_PATH = File.join(ROOT, 'docs/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_PARSER_v0_1_49.md')
REFERENCE_PATHS = [
  'README.md',
  'docs/roadmap/BASIC_SHARP_ROADMAP.md',
  'docs/hand_off/BASIC_SHARP_MASTER_THREAD_HANDOFF.md',
  'docs/company_bible/BASIC_SHARP_COMPANY_BIBLE.md',
  'spec/self_hosting/BASIC_SHARP_SELF_HOSTING_SUBSET_v1.json'
].freeze

spec = JSON.parse(File.read(SPEC_PATH, encoding: 'UTF-8'))

def assert_contract!(condition, message)
  raise "Small compiler subset parser failed: #{message}" unless condition
end

assert_contract!(spec.fetch('format') == 'bsharp.small_compiler_subset.parser.contract.json', 'wrong spec identity')
assert_contract!(spec.fetch('format_version') == 1, 'wrong format version')
assert_contract!(spec.fetch('target_version') == BasicSharp::VERSION, 'target version does not match BasicSharp::VERSION')
assert_contract!(spec.fetch('status') == BasicSharp::SmallCompilerSubsetParser::STATUS, 'status changed')
assert_contract!(File.file?(DOC_PATH), 'implementation document is missing')
assert_contract!(BasicSharp::Parser::BLOCK_HEADS == spec.fetch('current_head_words'), 'Head list changed')

forbidden = spec.fetch('scope').fetch('forbidden_until_later_approval')
[
  'replacing compiler/parser.rb as the production parser authority',
  'routing normal BASIC# compilation through compiler/small_compiler_subset_parser.rb',
  'claiming BASIC# is self-hosted',
  'adding Profile 8',
  'adding new creator-facing syntax',
  'changing runtime meaning, BSharp IR, BSharp Bytecode, Save format, ASK output, input devices, graphics, engine bridge, browser work, web export, or Ruby retirement'
].each do |entry|
  assert_contract!(forbidden.include?(entry), "missing exclusion: #{entry}")
end

spec.fetch('fixtures').each do |fixture|
  parser = BasicSharp::SmallCompilerSubsetParser.new(fixture.fetch('source'))
  document = parser.to_h
  statements = document.fetch(:statements)

  assert_contract!(parser.parser_matches_ruby_referee?, "fixture #{fixture.fetch('name')} no longer matches Ruby Parser referee")
  assert_contract!(statements.length == fixture.fetch('expected_statement_count'), "fixture #{fixture.fetch('name')} statement count changed")
  assert_contract!(statements.map { |entry| entry.fetch(:starter) } == fixture.fetch('expected_starters'), "fixture #{fixture.fetch('name')} starters changed")
  actions = parser.statements.flat_map(&:children).map(&:action).compact
  assert_contract!(actions == fixture.fetch('expected_action_words'), "fixture #{fixture.fetch('name')} actions changed")
end

REFERENCE_PATHS.each do |relative|
  text = File.read(File.join(ROOT, relative), encoding: 'UTF-8')
  assert_contract!(text.include?('spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_PARSER_v1.json'), "#{relative} does not reference the subset parser spec")
end

doc = File.read(DOC_PATH, encoding: 'UTF-8')
['Ruby Parser referee', 'compiler/small_compiler_subset_parser.rb', 'not the production parser authority', 'No Profile 8'].each do |line|
  assert_contract!(doc.include?(line), "implementation document missing #{line}")
end

puts "BASIC# Small Compiler Subset Parser v#{BasicSharp::VERSION}"
puts "Fixtures: #{spec.fetch('fixtures').length}"
puts 'TokenizerReader input: PASS'
puts 'Ruby Parser referee comparison: PASS'
puts 'Production parser authority unchanged: PASS'
puts 'No Profile 8, syntax, runtime, web export, or browser work: PASS'
puts 'SMALL COMPILER SUBSET PARSER: PASS'
