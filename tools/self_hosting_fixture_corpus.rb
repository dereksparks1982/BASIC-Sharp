#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require_relative '../compiler/self_hosting_fixture_corpus'

ROOT = File.expand_path('..', __dir__)
SPEC_PATH = File.join(ROOT, 'spec/self_hosting/BASIC_SHARP_SELF_HOSTING_FIXTURE_CORPUS_v1.json')
spec = JSON.parse(File.read(SPEC_PATH, encoding: 'UTF-8'))

def assert_contract!(condition, message)
  raise "Self-hosting fixture corpus failed: #{message}" unless condition
end

assert_contract!(spec.fetch('format') == 'bsharp.self_hosting.fixture_corpus.json', 'wrong spec identity')
assert_contract!(spec.fetch('format_version') == 1, 'wrong spec format version')
assert_contract!(spec.fetch('target_version') == BasicSharp::VERSION, 'spec target does not match BasicSharp::VERSION')
assert_contract!(spec.fetch('status') == 'self_hosting_fixture_corpus_under_ruby_referee', 'wrong corpus status')
assert_contract!(spec.fetch('company_identity') == 'Elderedd Softworks LLC', 'company identity changed')
assert_contract!(spec.fetch('workspace_identity') == 'Elderedd Laboratory', 'Elderedd laboratory identity changed')
assert_contract!(spec.fetch('workspace_meaning').include?('compatibility bridge'), 'DKLab compatibility bridge decision is missing')

fixture_names = spec.fetch('fixtures').map { |entry| entry.fetch('name') }
assert_contract!(fixture_names.uniq == fixture_names, 'fixture names must be unique')
assert_contract!(fixture_names.length >= spec.fetch('minimum_fixture_count'), 'not enough corpus fixtures')

record = BasicSharp::SelfHostingFixtureCorpus.new(spec).to_h
assert_contract!(record.fetch(:all_pass), 'at least one corpus fixture drifted')
profiles = record.fetch(:profile_counts).keys
spec.fetch('required_profiles').each do |profile|
  assert_contract!(profiles.include?(profile), "missing required profile #{profile}")
end
assert_contract!(!profiles.include?('bsharp.bytecode.v8'), 'Profile 8 must not appear in the fixture corpus')
assert_contract!(spec.fetch('scope').fetch('forbidden').include?('claiming BASIC# is self-hosted'), 'self-hosting claim must remain forbidden')
assert_contract!(spec.fetch('scope').fetch('forbidden').include?('removing the DKLab compatibility bridge before later accepted validation'), 'DKLab bridge removal must remain gated')

puts "BASIC# Self-Hosting Fixture Corpus v#{BasicSharp::VERSION}: PASS"
puts "Fixtures: #{record.fetch(:fixture_count)}"
puts "Profiles: #{profiles.join(', ')}"
puts 'Elderedd identity and DKLab compatibility bridge: PASS'
puts 'Ruby referee remains: PASS'
