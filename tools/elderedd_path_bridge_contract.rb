#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require_relative '../compiler/ast_nodes'

ROOT = File.expand_path('..', __dir__)
SPEC_PATH = File.join(ROOT, 'spec/governance/BASIC_SHARP_ELDEREDD_PATH_BRIDGE_CONTRACT_v1.json')
README_PATH = File.join(ROOT, 'README.md')
COMPANY_BIBLE_PATH = File.join(ROOT, 'docs/company_bible/BASIC_SHARP_COMPANY_BIBLE.md')
ROADMAP_PATH = File.join(ROOT, 'docs/roadmap/BASIC_SHARP_ROADMAP.md')
HANDOFF_PATH = File.join(ROOT, 'docs/hand_off/BASIC_SHARP_MASTER_THREAD_HANDOFF.md')
DOC_MAP_PATH = File.join(ROOT, 'docs/BASIC_SHARP_DOCUMENTATION_MAP.md')

def assert_contract!(condition, message)
  raise "Elderedd path bridge contract failed: #{message}" unless condition
end

spec = JSON.parse(File.read(SPEC_PATH, encoding: 'UTF-8'))
current_text = [README_PATH, COMPANY_BIBLE_PATH, ROADMAP_PATH, HANDOFF_PATH, DOC_MAP_PATH].map do |path|
  File.read(path, encoding: 'UTF-8')
end.join("\n")

assert_contract!(spec.fetch('format') == 'bsharp.elderedd_path_bridge_contract.json', 'wrong spec identity')
assert_contract!(spec.fetch('format_version') == 1, 'wrong spec format version')
assert_contract!(spec.fetch('target_version') == BasicSharp::VERSION, 'target version mismatch')
assert_contract!(spec.fetch('canonical_path') == '~/Elderedd/Projects/BASIC#', 'canonical path mismatch')
assert_contract!(spec.fetch('legacy_path') == '~/DKLab/Projects/BASIC#', 'legacy path mismatch')
assert_contract!(spec.fetch('bridge_status') == 'active_retirement_bridge', 'bridge status mismatch')
assert_contract!(spec.fetch('removal_status') == 'forbidden_in_v0.1.80', 'bridge removal status mismatch')
assert_contract!(spec.fetch('required_next_proof').include?('future build validates from Elderedd path'), 'future Elderedd proof missing')
assert_contract!(spec.fetch('forbidden').include?('removing the DKLab compatibility bridge in v0.1.80'), 'bridge removal must be forbidden')
assert_contract!(spec.fetch('forbidden').include?('deleting unrelated DKLab workspace contents'), 'unrelated workspace deletion must be forbidden')

['~/Elderedd/Projects/BASIC#', '~/DKLab/Projects/BASIC#', 'compatibility bridge', 'DKLab is retired'].each do |phrase|
  assert_contract!(current_text.include?(phrase), "missing path bridge phrase #{phrase}")
end

assert_contract!(!current_text.include?('DKLab is the active laboratory'), 'DKLab active laboratory wording remains')
assert_contract!(!current_text.include?('remove the DKLab compatibility bridge now'), 'bridge removal wording remains')

puts "BASIC# Elderedd Path Bridge Contract v#{BasicSharp::VERSION}: PASS"
puts 'Canonical Elderedd path recorded: PASS'
puts 'Legacy DKLab compatibility path preserved: PASS'
puts 'Bridge removal remains forbidden in this build: PASS'
