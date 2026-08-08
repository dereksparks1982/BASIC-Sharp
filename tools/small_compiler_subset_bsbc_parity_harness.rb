#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require_relative '../compiler/small_compiler_subset_bsbc_parity_harness'

ROOT = File.expand_path('..', __dir__)
SPEC_PATH = File.join(ROOT, 'spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_BSBC_PARITY_HARNESS_v1.json')

spec = JSON.parse(File.read(SPEC_PATH, encoding: 'UTF-8'))

def assert_contract!(condition, message)
  raise "Small compiler subset BSBC parity harness failed: #{message}" unless condition
end

assert_contract!(spec.fetch('format') == 'bsharp.small_compiler_subset.bsbc_golden_parity.contract.json', 'wrong spec identity')
assert_contract!(spec.fetch('format_version') == 1, 'wrong spec format version')
assert_contract!(spec.fetch('target_version') == BasicSharp::VERSION, 'spec target does not match BasicSharp::VERSION')
assert_contract!(spec.fetch('status') == 'bsbc_golden_parity_under_ruby_referee', 'wrong contract status')

harness = BasicSharp::SmallCompilerSubsetBSBCParityHarness.new(spec.fetch('fixtures'))
record = harness.to_h
assert_contract!(record.fetch(:format) == 'bsharp.small_compiler_subset.bsbc_golden_parity.record', 'wrong record identity')
assert_contract!(record.fetch(:version) == BasicSharp::VERSION, 'record version mismatch')
assert_contract!(record.fetch(:status) == 'bsbc_golden_parity_under_ruby_referee', 'wrong record status')
assert_contract!(record.fetch(:fixture_count) == spec.fetch('fixtures').length, 'fixture count mismatch')
assert_contract!(record.fetch(:all_pass) == true, 'one or more BSBC golden parity fixtures failed')

profiles = []
record.fetch(:fixtures).each do |fixture|
  profiles << fixture.fetch(:profile)
  assert_contract!(fixture.fetch(:passes), "#{fixture.fetch(:name)} did not pass")
  checks = fixture.fetch(:checks)
  checks.each do |name, passed|
    assert_contract!(passed == true, "#{fixture.fetch(:name)} failed #{name}")
  end
  assert_contract!(fixture.fetch(:binary_sha256) == fixture.fetch(:expected_binary_sha256), "#{fixture.fetch(:name)} binary digest drifted")
  assert_contract!(fixture.fetch(:loader_summary_sha256) == fixture.fetch(:expected_loader_summary_sha256), "#{fixture.fetch(:name)} loader summary digest drifted")
end

%w[bsharp.bytecode.v1 bsharp.bytecode.v2 bsharp.bytecode.v4].each do |profile|
  assert_contract!(profiles.include?(profile), "missing protected subset bytecode profile #{profile}")
end
assert_contract!(!profiles.include?('bsharp.bytecode.v8'), 'Profile 8 must not exist')

puts "BASIC# Small Compiler Subset BSBC Golden Parity Harness v#{BasicSharp::VERSION}: PASS"
