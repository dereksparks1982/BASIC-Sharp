#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require_relative '../compiler/ast_nodes'

ROOT = File.expand_path('..', __dir__)
SPEC_PATH = File.join(ROOT, 'spec/self_hosting/BASIC_SHARP_SELF_HOSTING_SUBSET_v1.json')
DOC_PATH = File.join(ROOT, 'docs/self_hosting/BASIC_SHARP_SELF_HOSTING_FOUNDATION_v0_1_44.md')
REFERENCE_PATHS = [
  'README.md',
  'docs/roadmap/BASIC_SHARP_ROADMAP.md',
  'docs/hand_off/BASIC_SHARP_MASTER_THREAD_HANDOFF.md',
  'docs/company_bible/BASIC_SHARP_COMPANY_BIBLE.md'
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
assert_contract!(spec.fetch('compiler_subset_status') == 'planning_contract', 'subset status changed')

profiles = spec.fetch('approved_profiles_available_to_creator_programs')
assert_contract!(profiles == (1..7).map { |n| "bsharp.meaning.v#{n}" }, 'approved profile list changed')

forbidden = spec.fetch('compiler_subset_forbids_until_later_approval')
%w[Profile\ 8 loops collections].each do |term|
  assert_contract!(forbidden.any? { |entry| entry.include?(term) }, "missing future-exclusion #{term}")
end
assert_contract!(forbidden.include?('replacing the Ruby bootstrap compiler'), 'Ruby replacement must stay forbidden')
assert_contract!(forbidden.include?('claiming BASIC# is self-hosted'), 'self-hosting claim must stay forbidden')
assert_contract!(forbidden.include?('BSharp native document application work'), 'document app must stay out of the current build')

rules = spec.fetch('acceptance_rules')
assert_contract!(rules.any? { |entry| entry.include?('Ruby remains the bootstrap') }, 'Ruby referee rule missing')
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

puts "BASIC# Self-Hosting Contract v#{BasicSharp::VERSION}"
puts "Compiler subset: #{spec.fetch('compiler_subset_name')}"
puts "Allowed creator profiles: #{profiles.length}"
puts "Forbidden future items: #{forbidden.length}"
puts 'Ruby bootstrap remains: PASS'
puts 'No self-hosting claim: PASS'
puts 'No Profile 8 or new syntax: PASS'
puts 'SELF-HOSTING CONTRACT: PASS'
