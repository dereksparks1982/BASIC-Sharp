#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require_relative '../compiler/small_compiler_subset_runtime_smoke'

ROOT = File.expand_path('..', __dir__)
SPEC_PATH = File.join(ROOT, 'spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_RUNTIME_SMOKE_v1.json')
spec = JSON.parse(File.read(SPEC_PATH, encoding: 'UTF-8'))

def assert_contract!(condition, message)
  raise "Small compiler subset runtime smoke failed: #{message}" unless condition
end

assert_contract!(spec.fetch('format') == 'bsharp.small_compiler_subset.runtime_smoke.json', 'wrong spec identity')
assert_contract!(spec.fetch('format_version') == 1, 'wrong spec format version')
assert_contract!(spec.fetch('target_version') == BasicSharp::VERSION, 'spec target does not match BasicSharp::VERSION')
assert_contract!(spec.fetch('status') == 'runtime_smoke_under_ruby_referee', 'wrong smoke status')
assert_contract!(spec.fetch('source_corpus') == 'spec/self_hosting/BASIC_SHARP_SELF_HOSTING_FIXTURE_CORPUS_v1.json', 'source corpus path changed')
assert_contract!(spec.fetch('scope').fetch('forbidden').include?('claiming BASIC# is self-hosted'), 'self-hosting claim must remain forbidden')
assert_contract!(spec.fetch('scope').fetch('forbidden').include?('replacing Ruby bootstrap compiler'), 'Ruby replacement must remain forbidden')
assert_contract!(spec.fetch('scope').fetch('forbidden').include?('renaming bytecode or BSBC'), 'bytecode names must remain stable')
assert_contract!(spec.fetch('scope').fetch('forbidden').include?('changing production runtime behaviour'), 'runtime behaviour changes must remain forbidden')

record = BasicSharp::SmallCompilerSubsetRuntimeSmoke.new(spec).to_h
assert_contract!(record.fetch(:all_pass), 'at least one runtime smoke fixture drifted')
assert_contract!(record.fetch(:fixture_count) >= 7, 'not enough smoke fixtures')
record.fetch(:fixtures).each do |fixture|
  assert_contract!(fixture.fetch(:runtime).fetch(:matched_event_count) == fixture.fetch(:events).length, "unmatched runtime event in #{fixture.fetch(:name)}")
  assert_contract!(fixture.fetch(:runtime).fetch(:event_count) == fixture.fetch(:events).length, "event count mismatch in #{fixture.fetch(:name)}")
end

puts "BASIC# Small Compiler Subset Runtime Smoke v#{BasicSharp::VERSION}: PASS"
puts "Fixtures: #{record.fetch(:fixture_count)}"
puts 'Parser to IR to BSBC to verifying runtime: PASS'
puts 'Runtime snapshots and saves deterministic: PASS'
puts 'Ruby referee remains: PASS'
