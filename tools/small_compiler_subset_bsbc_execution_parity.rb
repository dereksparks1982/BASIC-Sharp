#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require_relative '../compiler/small_compiler_subset_bsbc_execution_parity'

ROOT = File.expand_path('..', __dir__)
SPEC_PATH = File.join(ROOT, 'spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_BSBC_EXECUTION_PARITY_v1.json')
spec = JSON.parse(File.read(SPEC_PATH, encoding: 'UTF-8'))

def assert_contract!(condition, message)
  raise "Small compiler subset BSBC execution parity failed: #{message}" unless condition
end

assert_contract!(spec.fetch('format') == 'bsharp.small_compiler_subset.bsbc_execution_parity.json', 'wrong spec identity')
assert_contract!(spec.fetch('format_version') == 1, 'wrong spec format version')
assert_contract!(spec.fetch('target_version') == BasicSharp::VERSION, 'spec target does not match BasicSharp::VERSION')
assert_contract!(spec.fetch('status') == 'bsbc_execution_parity_under_ruby_referee', 'wrong execution parity status')
assert_contract!(spec.fetch('source_corpus') == 'spec/self_hosting/BASIC_SHARP_SELF_HOSTING_FIXTURE_CORPUS_v1.json', 'source corpus path changed')
assert_contract!(spec.fetch('scope').fetch('forbidden').include?('claiming BASIC# is self-hosted'), 'self-hosting claim must remain forbidden')
assert_contract!(spec.fetch('scope').fetch('forbidden').include?('replacing Ruby bootstrap compiler'), 'Ruby replacement must remain forbidden')
assert_contract!(spec.fetch('scope').fetch('forbidden').include?('removing the DKLab compatibility bridge'), 'DKLab bridge removal must remain forbidden')
assert_contract!(spec.fetch('scope').fetch('forbidden').include?('changing production runtime behaviour'), 'runtime behaviour changes must remain forbidden')

record = BasicSharp::SmallCompilerSubsetBSBCExecutionParity.new(spec).to_h
assert_contract!(record.fetch(:format) == 'bsharp.small_compiler_subset.bsbc_execution_parity.record', 'wrong record identity')
assert_contract!(record.fetch(:version) == BasicSharp::VERSION, 'record version mismatch')
assert_contract!(record.fetch(:status) == 'bsbc_execution_parity_under_ruby_referee', 'wrong record status')
assert_contract!(record.fetch(:all_pass), 'at least one BSBC execution parity fixture drifted')
assert_contract!(record.fetch(:fixture_count) >= 7, 'not enough execution parity fixtures')

record.fetch(:fixtures).each do |fixture|
  assert_contract!(fixture.fetch(:passes), "#{fixture.fetch(:name)} did not pass")
  assert_contract!(fixture.fetch(:runtime).fetch(:matched_event_count) == fixture.fetch(:events).length, "unmatched VM event in #{fixture.fetch(:name)}")
  assert_contract!(fixture.fetch(:runtime).fetch(:event_count) == fixture.fetch(:events).length, "event count mismatch in #{fixture.fetch(:name)}")
  fixture.fetch(:checks).each do |name, passed|
    assert_contract!(passed == true, "#{fixture.fetch(:name)} failed #{name}")
  end
end

puts "BASIC# Small Compiler Subset BSBC Execution Parity v#{BasicSharp::VERSION}: PASS"
puts "Fixtures: #{record.fetch(:fixture_count)}"
puts 'Source -> BSIR -> BSBC -> BSharp VM execution: PASS'
puts 'BSharp VM execution matches Ruby referee runtime: PASS'
puts 'DKLab compatibility bridge remains protected: PASS'
