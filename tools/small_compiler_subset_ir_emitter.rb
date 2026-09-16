#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require_relative '../compiler/small_compiler_subset_ir_emitter'

ROOT = File.expand_path('..', __dir__)
SPEC_PATH = File.join(ROOT, 'spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_IR_EMITTER_v1.json')
DOC_PATH = File.join(ROOT, 'docs/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_IR_EMITTER_v0_0_50.md')
REFERENCE_PATHS = [
  'README.md',
  'docs/roadmap/BASIC_SHARP_ROADMAP.md',
  'docs/hand_off/BASIC_SHARP_MASTER_THREAD_HANDOFF.md',
  'docs/company_bible/BASIC_SHARP_COMPANY_BIBLE.md',
  'spec/self_hosting/BASIC_SHARP_SELF_HOSTING_SUBSET_v1.json',
  'docs/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_PARSER_v0_0_49.md'
].freeze

spec = JSON.parse(File.read(SPEC_PATH, encoding: 'UTF-8'))

def assert_contract!(condition, message)
  raise "Small compiler subset IR emitter failed: #{message}" unless condition
end

assert_contract!(spec.fetch('format') == 'bsharp.small_compiler_subset.ir_emitter.contract.json', 'wrong spec identity')
assert_contract!(spec.fetch('format_version') == 1, 'wrong format version')
assert_contract!(spec.fetch('target_version') == BasicSharp::VERSION, 'target version does not match BasicSharp::VERSION')
assert_contract!(spec.fetch('status') == BasicSharp::SmallCompilerSubsetIREmitter::STATUS, 'status changed')
assert_contract!(File.file?(DOC_PATH), 'IR emitter document is missing')
assert_contract!(File.file?(File.join(ROOT, 'compiler/small_compiler_subset_ir_emitter.rb')), 'IR emitter implementation is missing')

forbidden = spec.fetch('scope').fetch('forbidden_until_later_approval')
[
  'replacing compiler/parser.rb as the production parser authority',
  'routing normal BASIC# compilation through compiler/small_compiler_subset_ir_emitter.rb',
  'claiming BASIC# is self-hosted',
  'adding Profile 8',
  'adding new creator-facing syntax',
  'changing runtime meaning, BSharp Bytecode, Save format, ASK output, input devices, graphics, engine bridge, browser work, web export, or Ruby retirement'
].each do |entry|
  assert_contract!(forbidden.include?(entry), "missing exclusion: #{entry}")
end

spec.fetch('fixtures').each do |fixture|
  emitter = BasicSharp::SmallCompilerSubsetIREmitter.new(fixture.fetch('source'))
  record = emitter.to_h
  ir = record.fetch(:bsharp_ir)
  expected = fixture.fetch('expected_counts')

  assert_contract!(emitter.parser_matches_ruby_referee?, "fixture #{fixture.fetch('name')} parser no longer matches Ruby Parser referee")
  assert_contract!(emitter.ir_matches_ruby_referee?, "fixture #{fixture.fetch('name')} BSharp IR no longer matches Ruby Resolver referee")
  assert_contract!(record.fetch(:format) == BasicSharp::SmallCompilerSubsetIREmitter::FORMAT, 'record format changed')
  assert_contract!(record.fetch(:status) == BasicSharp::SmallCompilerSubsetIREmitter::STATUS, 'record status changed')
  %w[kinds objects facts events if_rules controls hover_declarations context_declarations diagnostics].each do |key|
    assert_contract!(ir.fetch(key.to_sym).length == expected.fetch(key), "fixture #{fixture.fetch('name')} #{key} count changed")
  end
  meaning = ir.fetch(:meaning_profile, 'bsharp.meaning.v1')
  assert_contract!(meaning == expected.fetch('meaning_profile'), "fixture #{fixture.fetch('name')} meaning profile changed")
end

REFERENCE_PATHS.each do |relative|
  text = File.read(File.join(ROOT, relative), encoding: 'UTF-8')
  assert_contract!(text.include?('spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_IR_EMITTER_v1.json'), "#{relative} does not reference the subset IR emitter spec")
end

doc = File.read(DOC_PATH, encoding: 'UTF-8')
['Ruby Parser plus SemanticResolver referee', 'compiler/small_compiler_subset_ir_emitter.rb', 'not the production compiler path', 'No Profile 8'].each do |line|
  assert_contract!(doc.include?(line), "IR emitter document missing #{line}")
end

puts "BASIC# Small Compiler Subset IR Emitter v#{BasicSharp::VERSION}"
puts "Fixtures: #{spec.fetch('fixtures').length}"
puts 'SmallCompilerSubsetParser input: PASS'
puts 'BSharp IR emission: PASS'
puts 'Ruby Parser plus SemanticResolver referee comparison: PASS'
puts 'Production compiler path unchanged: PASS'
puts 'No Profile 8, syntax, runtime, bytecode, web export, or browser work: PASS'
puts 'SMALL COMPILER SUBSET IR EMITTER: PASS'
