#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require_relative '../compiler/ast_nodes'

ROOT = File.expand_path('..', __dir__)
SPEC_PATH = File.join(ROOT, 'spec/trial_by_fire/BASIC_SHARP_WHOLE_LANGUAGE_GAUNTLET_EXPANSION_v1.json')
INVENTORY_PATH = File.join(ROOT, 'spec/trial_by_fire/BASIC_SHARP_TRIAL_BY_FIRE_VALIDATION_INVENTORY_v1.json')
GAUNTLET_PATH = File.join(ROOT, 'tools/trial_by_fire_gauntlet.rb')

spec = JSON.parse(File.read(SPEC_PATH, encoding: 'UTF-8'))
inventory = JSON.parse(File.read(INVENTORY_PATH, encoding: 'UTF-8'))
gauntlet = File.read(GAUNTLET_PATH, encoding: 'UTF-8')

failures = []
check = lambda { |condition, message| failures << message unless condition }

check.call(spec.fetch('format') == 'bsharp.whole_language_gauntlet_expansion.json', 'wrong spec identity')
check.call(spec.fetch('format_version') == 1, 'wrong spec format version')
check.call(spec.fetch('target_version') == BasicSharp::VERSION, 'spec target version mismatch')
check.call(spec.fetch('required_target_version') == "v#{BasicSharp::VERSION}", 'required target mismatch')
check.call(spec.fetch('status') == 'active_trial_by_fire_gate', 'wrong status')
check.call(inventory.fetch('target_version') == BasicSharp::VERSION, 'inventory target version mismatch')
check.call(inventory.fetch('gauntlet_defaults') == spec.fetch('default_counts'), 'inventory gauntlet defaults do not match whole-language spec')
check.call(inventory.fetch('required_tools').map { |entry| entry.fetch('path') }.include?('tools/whole_language_gauntlet_contract.rb'), 'whole-language contract is not in installer-order tools')
check.call(gauntlet.include?("TrialByFire.env_count('BASIC_SHARP_TRIAL_INPUT_MOVEMENT_FRAMES', 64_000)"), 'combined input/movement default is missing from gauntlet')
check.call(gauntlet.include?("verify_combined_input_movement!(INPUT_FRAMES)"), 'combined input/movement phase is not executed')
check.call(gauntlet.include?("BASIC_SHARP_TRIAL_PROGRAMS cannot exceed 512"), 'generated-program ceiling was not expanded')
check.call(spec.fetch('forbidden').include?('returning to object interaction before the v0.1.78 gauntlet is accepted'), 'object-interaction pause rule missing')

unless failures.empty?
  warn 'BASIC# Whole-Language Gauntlet Contract: FAIL'
  failures.each_with_index { |failure, index| warn "#{index + 1}. #{failure}" }
  raise "Whole-language gauntlet contract failed with #{failures.length} issue(s)."
end

puts "BASIC# Whole-Language Gauntlet Contract v#{BasicSharp::VERSION}: PASS"
puts 'Expanded default counts are sealed in the validation inventory: PASS'
puts 'Combined movement plus input-action phase is active: PASS'
puts 'Generated-program ceiling expanded to 512: PASS'
