#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require_relative '../compiler/small_compiler_subset_ir_parity_harness'

ROOT = File.expand_path('..', __dir__)
SPEC_PATH = File.join(ROOT, 'spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_IR_PARITY_HARNESS_v1.json')
DOC_PATH = File.join(ROOT, 'docs/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_IR_PARITY_HARNESS_v0_1_51.md')
REFERENCE_PATHS = [
  'README.md',
  'docs/roadmap/BASIC_SHARP_ROADMAP.md',
  'docs/hand_off/BASIC_SHARP_MASTER_THREAD_HANDOFF.md',
  'docs/company_bible/BASIC_SHARP_COMPANY_BIBLE.md',
  'spec/self_hosting/BASIC_SHARP_SELF_HOSTING_SUBSET_v1.json',
  'docs/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_IR_EMITTER_v0_1_50.md'
].freeze

spec = JSON.parse(File.read(SPEC_PATH, encoding: 'UTF-8'))

def assert_contract!(condition, message)
  raise "Small compiler subset IR parity harness failed: #{message}" unless condition
end

assert_contract!(spec.fetch('format') == 'bsharp.small_compiler_subset.ir_golden_parity.contract.json', 'wrong spec identity')
assert_contract!(spec.fetch('format_version') == 1, 'wrong format version')
assert_contract!(spec.fetch('target_version') == BasicSharp::VERSION, 'target version does not match BasicSharp::VERSION')
assert_contract!(spec.fetch('status') == BasicSharp::SmallCompilerSubsetIRParityHarness::STATUS, 'status changed')
assert_contract!(File.file?(DOC_PATH), 'IR parity harness document is missing')
assert_contract!(File.file?(File.join(ROOT, 'compiler/small_compiler_subset_ir_parity_harness.rb')), 'IR parity harness implementation is missing')

forbidden = spec.fetch('scope').fetch('forbidden_until_later_approval')
[
  'replacing compiler/parser.rb as the production parser authority',
  'routing normal BASIC# compilation through compiler/small_compiler_subset_ir_parity_harness.rb',
  'claiming BASIC# is self-hosted',
  'adding Profile 8',
  'adding new creator-facing syntax',
  'changing runtime meaning, BSharp Bytecode, Save format, ASK output, input devices, graphics, engine bridge, browser work, web export, or Ruby retirement'
].each do |entry|
  assert_contract!(forbidden.include?(entry), "missing exclusion: #{entry}")
end

harness = BasicSharp::SmallCompilerSubsetIRParityHarness.new(spec.fetch('fixtures'))
record = harness.to_h
assert_contract!(record.fetch(:format) == BasicSharp::SmallCompilerSubsetIRParityHarness::FORMAT, 'record format changed')
assert_contract!(record.fetch(:status) == BasicSharp::SmallCompilerSubsetIRParityHarness::STATUS, 'record status changed')
assert_contract!(record.fetch(:fixture_count) == spec.fetch('fixtures').length, 'fixture count changed')
assert_contract!(record.fetch(:all_pass) == true, 'not all parity fixtures pass')

record.fetch(:fixtures).each do |fixture|
  assert_contract!(fixture.fetch(:parser_ruby_referee_matches), "fixture #{fixture.fetch(:name)} parser mismatch")
  assert_contract!(fixture.fetch(:ir_ruby_referee_matches), "fixture #{fixture.fetch(:name)} IR mismatch")
  assert_contract!(fixture.fetch(:golden_sha256_matches), "fixture #{fixture.fetch(:name)} golden digest mismatch")
  assert_contract!(fixture.fetch(:referee_digest_matches), "fixture #{fixture.fetch(:name)} referee digest mismatch")
  assert_contract!(fixture.fetch(:counts_match), "fixture #{fixture.fetch(:name)} count mismatch")
end

REFERENCE_PATHS.each do |relative|
  text = File.read(File.join(ROOT, relative), encoding: 'UTF-8')
  assert_contract!(text.include?('spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_IR_PARITY_HARNESS_v1.json'), "#{relative} does not reference the subset IR parity harness spec")
end

doc = File.read(DOC_PATH, encoding: 'UTF-8')
['golden BSharp IR parity', 'Ruby Parser plus SemanticResolver referee', 'compiler/small_compiler_subset_ir_parity_harness.rb', 'not the production compiler path', 'No Profile 8'].each do |line|
  assert_contract!(doc.include?(line), "IR parity harness document missing #{line}")
end

puts "BASIC# Small Compiler Subset IR Golden Parity Harness v#{BasicSharp::VERSION}"
puts "Fixtures: #{record.fetch(:fixture_count)}"
puts 'Golden BSharp IR digests: PASS'
puts 'Ruby Parser plus SemanticResolver referee digest comparison: PASS'
puts 'Production compiler path unchanged: PASS'
puts 'No Profile 8, syntax, runtime, bytecode, web export, or browser work: PASS'
puts 'SMALL COMPILER SUBSET IR GOLDEN PARITY HARNESS: PASS'
