#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require_relative '../compiler/ast_nodes'

ROOT = File.expand_path('..', __dir__)
SPEC_PATH = File.join(ROOT, 'spec/governance/BASIC_SHARP_ELDEREDD_IDENTITY_CONTRACT_v1.json')
README_PATH = File.join(ROOT, 'README.md')
COMPANY_BIBLE_PATH = File.join(ROOT, 'docs/company_bible/BASIC_SHARP_COMPANY_BIBLE.md')
ROADMAP_PATH = File.join(ROOT, 'docs/roadmap/BASIC_SHARP_ROADMAP.md')
HANDOFF_PATH = File.join(ROOT, 'docs/hand_off/BASIC_SHARP_MASTER_THREAD_HANDOFF.md')
DOC_MAP_PATH = File.join(ROOT, 'docs/BASIC_SHARP_DOCUMENTATION_MAP.md')

def assert_contract!(condition, message)
  raise "Elderedd identity contract failed: #{message}" unless condition
end

spec = JSON.parse(File.read(SPEC_PATH, encoding: 'UTF-8'))
readme = File.read(README_PATH, encoding: 'UTF-8')
company_bible = File.read(COMPANY_BIBLE_PATH, encoding: 'UTF-8')
roadmap = File.read(ROADMAP_PATH, encoding: 'UTF-8')
handoff = File.read(HANDOFF_PATH, encoding: 'UTF-8')
doc_map = File.read(DOC_MAP_PATH, encoding: 'UTF-8')
all_current = [readme, company_bible, roadmap, handoff, doc_map].join("
")

assert_contract!(spec.fetch('format') == 'bsharp.elderedd_identity_contract.json', 'wrong spec identity')
assert_contract!(spec.fetch('format_version') == 1, 'wrong spec format version')
assert_contract!(spec.fetch('target_version') == BasicSharp::VERSION, 'target version mismatch')
assert_contract!(spec.fetch('parent_company') == 'Elderedd Softworks LLC', 'parent company mismatch')
assert_contract!(spec.fetch('laboratory') == 'Elderedd Laboratory', 'laboratory mismatch')
assert_contract!(spec.fetch('internal_shorthand') == 'ELDL', 'internal shorthand mismatch')
assert_contract!(spec.fetch('service_layer').fetch('name') == 'BSharp Creator Services', 'BCS name mismatch')
assert_contract!(spec.fetch('service_layer').fetch('short_name') == 'BCS', 'BCS short name mismatch')
assert_contract!(spec.fetch('canonical_future_path') == '~/Elderedd/Projects/BASIC#', 'canonical path mismatch')
assert_contract!(spec.fetch('legacy_compatibility_path') == '~/DKLab/Projects/BASIC#', 'legacy compatibility path mismatch')
assert_contract!(spec.fetch('retired_identity') == 'DKLab', 'retired identity mismatch')
assert_contract!(spec.fetch('private_github_rule').include?('Never make the BASIC# GitHub repository public'), 'private GitHub rule missing')
assert_contract!(spec.fetch('closeout_order') == ['accepted snapshot', 'local Git commit/tag verification', 'GitHub push and remote verification', 'GitHub description update', 'final status summary'], 'closeout order changed')

['Elderedd Softworks LLC', 'Elderedd Laboratory', 'ELDL', 'BCS'].each do |phrase|
  assert_contract!(all_current.include?(phrase), "missing current identity phrase #{phrase}")
end
assert_contract!(all_current.include?('BSharp Creator Services'), 'BSharp Creator Services definition missing')
assert_contract!(all_current.include?('DKLab is retired') || all_current.include?('DKLab / DK LAB is retired'), 'DKLab retirement text missing')
assert_contract!(all_current.include?('compatibility bridge'), 'DKLab compatibility bridge text missing')
assert_contract!(all_current.include?('Never make the BASIC# GitHub repository public'), 'private GitHub rule missing from current docs')
assert_contract!(all_current.include?('GitHub description update'), 'GitHub description closeout step missing')
assert_contract!(!all_current.include?('Elderred Softworks LLC'), 'old Elderred spelling remains in active docs')
assert_contract!(!all_current.include?('DKLab is retained as the internal workspace and lab name'), 'old DKLab active identity rule remains')

puts "BASIC# Elderedd Identity Contract v#{BasicSharp::VERSION}: PASS"
puts 'Elderedd Softworks LLC: PASS'
puts 'Elderedd Laboratory / ELDL: PASS'
puts 'BCS naming: PASS'
puts 'DKLab retired compatibility bridge: PASS'
puts 'Private GitHub and closeout order: PASS'
