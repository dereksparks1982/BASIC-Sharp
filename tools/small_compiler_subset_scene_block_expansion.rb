#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require_relative '../compiler/small_compiler_subset_scene_block_expansion'

ROOT = File.expand_path('..', __dir__)
SPEC_PATH = File.join(ROOT, 'spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_SCENE_BLOCK_EXPANSION_v1.json')
DOC_PATH = File.join(ROOT, 'docs/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_SCENE_BLOCK_EXPANSION_v0_1_53.md')
REFERENCE_PATHS = [
  'README.md',
  'docs/roadmap/BASIC_SHARP_ROADMAP.md',
  'docs/hand_off/BASIC_SHARP_MASTER_THREAD_HANDOFF.md',
  'docs/company_bible/BASIC_SHARP_COMPANY_BIBLE.md',
  'docs/BASIC_SHARP_DOCUMENTATION_MAP.md',
  'spec/self_hosting/BASIC_SHARP_SELF_HOSTING_SUBSET_v1.json'
].freeze

spec = JSON.parse(File.read(SPEC_PATH, encoding: 'UTF-8'))

def assert_contract!(condition, message)
  raise "Small compiler subset scene/block expansion failed: #{message}" unless condition
end

assert_contract!(spec.fetch('format') == 'bsharp.small_compiler_subset.scene_block_expansion.contract.json', 'wrong spec identity')
assert_contract!(spec.fetch('format_version') == 1, 'wrong format version')
assert_contract!(spec.fetch('target_version') == BasicSharp::VERSION, 'target version does not match BasicSharp::VERSION')
assert_contract!(spec.fetch('status') == BasicSharp::SmallCompilerSubsetSceneBlockExpansion::STATUS, 'status changed')
assert_contract!(File.file?(DOC_PATH), 'scene/block expansion documentation is missing')
assert_contract!(File.file?(File.join(ROOT, 'compiler/small_compiler_subset_scene_block_expansion.rb')), 'scene/block expansion implementation is missing')

forbidden = spec.fetch('scope').fetch('forbidden_until_later_approval')
[
  'replacing compiler/parser.rb as the production parser authority',
  'routing normal BASIC# compilation through compiler/small_compiler_subset_scene_block_expansion.rb',
  'claiming BASIC# is self-hosted',
  'adding Profile 8',
  'adding new creator-facing syntax',
  'changing runtime meaning, BSharp Bytecode, Save format, ASK output, input devices, graphics, engine bridge, browser work, web export, or Ruby retirement'
].each do |entry|
  assert_contract!(forbidden.include?(entry), "missing exclusion: #{entry}")
end

record = BasicSharp::SmallCompilerSubsetSceneBlockExpansion.new(spec).to_h
assert_contract!(record.fetch(:format) == BasicSharp::SmallCompilerSubsetSceneBlockExpansion::FORMAT, 'record format changed')
assert_contract!(record.fetch(:version) == BasicSharp::VERSION, 'record version changed')
assert_contract!(record.fetch(:status) == BasicSharp::SmallCompilerSubsetSceneBlockExpansion::STATUS, 'record status changed')
assert_contract!(record.fetch(:valid_fixture_count) == spec.fetch('valid_fixtures').length, 'valid fixture count changed')
assert_contract!(record.fetch(:invalid_fixture_count) == spec.fetch('invalid_fixtures').length, 'invalid fixture count changed')
assert_contract!(record.fetch(:all_pass), 'not all scene/block expansion fixtures pass')

record.fetch(:valid_fixtures).each do |fixture|
  assert_contract!(fixture.fetch(:parser_ruby_referee_matches), "fixture #{fixture.fetch(:name)} parser mismatch")
  assert_contract!(fixture.fetch(:ir_ruby_referee_matches), "fixture #{fixture.fetch(:name)} IR mismatch")
  assert_contract!(fixture.fetch(:golden_sha256_matches), "fixture #{fixture.fetch(:name)} golden digest mismatch")
  assert_contract!(fixture.fetch(:referee_digest_matches), "fixture #{fixture.fetch(:name)} referee digest mismatch")
  assert_contract!(fixture.fetch(:starters_match), "fixture #{fixture.fetch(:name)} starter order changed")
  assert_contract!(fixture.fetch(:actions_match), "fixture #{fixture.fetch(:name)} action order changed")
  assert_contract!(fixture.fetch(:counts_match), "fixture #{fixture.fetch(:name)} count mismatch")
end

record.fetch(:invalid_fixtures).each do |fixture|
  assert_contract!(fixture.fetch(:exact_errors_match), "fixture #{fixture.fetch(:name)} error records changed")
  assert_contract!(fixture.fetch(:digest_matches), "fixture #{fixture.fetch(:name)} error digest changed")
  assert_contract!(fixture.fetch(:unknown_diagnostics).empty?, "fixture #{fixture.fetch(:name)} has unmapped diagnostics")
end

REFERENCE_PATHS.each do |relative|
  text = File.read(File.join(ROOT, relative), encoding: 'UTF-8')
  assert_contract!(text.include?('spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_SCENE_BLOCK_EXPANSION_v1.json'), "#{relative} does not reference the scene/block expansion spec")
end

doc = File.read(DOC_PATH, encoding: 'UTF-8')
['scene/block expansion', 'Ruby Parser plus SemanticResolver referee', 'compiler/small_compiler_subset_scene_block_expansion.rb', 'not the production compiler path', 'No Profile 8'].each do |phrase|
  assert_contract!(doc.include?(phrase), "scene/block expansion documentation missing #{phrase}")
end

puts "BASIC# Small Compiler Subset Scene/Block Expansion v#{BasicSharp::VERSION}"
puts "Valid fixtures: #{record.fetch(:valid_fixture_count)}"
puts "Invalid fixtures: #{record.fetch(:invalid_fixture_count)}"
puts 'Expanded ordered scene/block parsing: PASS'
puts 'Ruby Parser plus SemanticResolver referee comparison: PASS'
puts 'Plain-English expanded block errors: PASS'
puts 'Production compiler path unchanged: PASS'
puts 'No Profile 8, syntax, runtime, bytecode, web export, or browser work: PASS'
puts 'SMALL COMPILER SUBSET SCENE/BLOCK EXPANSION: PASS'
