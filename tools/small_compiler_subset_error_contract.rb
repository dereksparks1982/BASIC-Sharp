#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require_relative '../compiler/small_compiler_subset_error_contract'

ROOT = File.expand_path('..', __dir__)
SPEC_PATH = File.join(ROOT, 'spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_ERROR_CONTRACT_v1.json')
DOC_PATH = File.join(ROOT, 'docs/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_ERROR_CONTRACT_v0_1_52.md')
REFERENCE_PATHS = [
  'README.md',
  'docs/roadmap/BASIC_SHARP_ROADMAP.md',
  'docs/hand_off/BASIC_SHARP_MASTER_THREAD_HANDOFF.md',
  'docs/company_bible/BASIC_SHARP_COMPANY_BIBLE.md',
  'spec/self_hosting/BASIC_SHARP_SELF_HOSTING_SUBSET_v1.json',
  'docs/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_IR_PARITY_HARNESS_v0_1_51.md'
].freeze

def assert_contract!(condition, message)
  raise "Small compiler subset error contract failed: #{message}" unless condition
end

spec = JSON.parse(File.read(SPEC_PATH, encoding: 'UTF-8'))
assert_contract!(spec.fetch('format') == 'bsharp.small_compiler_subset.error_contract.json', 'wrong spec identity')
assert_contract!(spec.fetch('format_version') == 1, 'wrong format version')
assert_contract!(spec.fetch('target_version') == BasicSharp::VERSION, 'target version does not match BasicSharp::VERSION')
assert_contract!(spec.fetch('status') == BasicSharp::SmallCompilerSubsetErrorContract::STATUS, 'status changed')
assert_contract!(File.file?(DOC_PATH), 'error contract documentation is missing')

forbidden = spec.fetch('scope').fetch('forbidden_until_later_approval')
[
  'adding Profile 8',
  'adding new creator-facing syntax',
  'changing valid-program runtime meaning',
  'changing BSharp Bytecode output',
  'routing normal BASIC# compilation through the small compiler subset',
  'claiming BASIC# is self-hosted',
  'retiring Ruby as production compiler or referee'
].each do |entry|
  assert_contract!(forbidden.include?(entry), "missing exclusion: #{entry}")
end

record = BasicSharp::SmallCompilerSubsetErrorContract.new(spec.fetch('fixtures')).to_h
assert_contract!(record.fetch(:format) == BasicSharp::SmallCompilerSubsetErrorContract::FORMAT, 'record format changed')
assert_contract!(record.fetch(:version) == BasicSharp::VERSION, 'record version changed')
assert_contract!(record.fetch(:status) == BasicSharp::SmallCompilerSubsetErrorContract::STATUS, 'record status changed')
assert_contract!(record.fetch(:fixture_count) == spec.fetch('fixtures').length, 'fixture count changed')
assert_contract!(record.fetch(:all_pass) == true, 'not all error-contract fixtures pass')

record.fetch(:fixtures).each do |fixture|
  assert_contract!(fixture.fetch(:exact_errors_match), "fixture #{fixture.fetch(:name)} error records changed")
  assert_contract!(fixture.fetch(:digest_matches), "fixture #{fixture.fetch(:name)} digest changed")
  assert_contract!(fixture.fetch(:unknown_diagnostics).empty?, "fixture #{fixture.fetch(:name)} has unmapped diagnostics")
  fixture.fetch(:canonical_errors).each do |error|
    assert_contract!(error.fetch(:id).match?(/\ABSE\d{4}\z/), "fixture #{fixture.fetch(:name)} has unstable error id")
    assert_contract!(error.fetch(:plain_message).include?('Ruby') == false, "fixture #{fixture.fetch(:name)} leaks Ruby into creator message")
    assert_contract!(error.fetch(:plain_message).include?('node') == false, "fixture #{fixture.fetch(:name)} leaks parser jargon")
  end
end

REFERENCE_PATHS.each do |relative|
  text = File.read(File.join(ROOT, relative), encoding: 'UTF-8')
  assert_contract!(text.include?('spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_ERROR_CONTRACT_v1.json'), "#{relative} does not reference the small compiler subset error contract spec")
end

doc = File.read(DOC_PATH, encoding: 'UTF-8')
['plain-English error contract', 'stable error IDs', 'creator-facing', 'not the production compiler path', 'No Profile 8'].each do |phrase|
  assert_contract!(doc.include?(phrase), "error contract documentation missing #{phrase}")
end

puts "BASIC# Small Compiler Subset Error Contract v#{BasicSharp::VERSION}"
puts "Fixtures: #{record.fetch(:fixture_count)}"
puts 'Stable error IDs: PASS'
puts 'Plain-English creator-facing messages: PASS'
puts 'Ruby referee diagnostics preserved: PASS'
puts 'Production compiler path unchanged: PASS'
puts 'No Profile 8, syntax, runtime, bytecode, web export, or browser work: PASS'
puts 'SMALL COMPILER SUBSET ERROR CONTRACT: PASS'
