#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require_relative '../compiler/ast_nodes'

ROOT = File.expand_path('..', __dir__)
SPEC_PATH = File.join(ROOT, 'spec/release/BASIC_SHARP_DETERMINISTIC_FIXTURE_HASH_SWEEP_v1.json')
INVENTORY_PATH = File.join(ROOT, 'spec/trial_by_fire/BASIC_SHARP_TRIAL_BY_FIRE_VALIDATION_INVENTORY_v1.json')
spec = JSON.parse(File.read(SPEC_PATH, encoding: 'UTF-8'))
inventory = JSON.parse(File.read(INVENTORY_PATH, encoding: 'UTF-8'))

def assert_sweep!(condition, message)
  raise "Deterministic fixture hash sweep failed: #{message}" unless condition
end

assert_sweep!(spec.fetch('format') == 'bsharp.deterministic_fixture_hash_sweep.json', 'wrong spec identity')
assert_sweep!(spec.fetch('format_version') == 1, 'wrong spec format version')
assert_sweep!(spec.fetch('target_version') == BasicSharp::VERSION, 'target version mismatch')
assert_sweep!(spec.fetch('status') == 'active_release_gate', 'wrong status')
assert_sweep!(spec.fetch('forbidden').include?('single-goblin repair'), 'single-goblin repair must stay forbidden')

inventory_tools = inventory.fetch('required_tools').map { |entry| entry.fetch('path') }
spec.fetch('required_tools').each do |relative|
  path = File.join(ROOT, relative)
  assert_sweep!(File.file?(path), "missing deterministic tool #{relative}")
  assert_sweep!(inventory_tools.include?(relative), "validation inventory does not run #{relative}")
end

spec.fetch('required_fixture_specs').each do |relative|
  path = File.join(ROOT, relative)
  assert_sweep!(File.file?(path), "missing fixture spec #{relative}")
  fixture_spec = JSON.parse(File.read(path, encoding: 'UTF-8'))
  if fixture_spec.key?('target_version')
    assert_sweep!(fixture_spec.fetch('target_version') == BasicSharp::VERSION, "fixture spec target mismatch #{relative}")
  end
end

puts "BASIC# Deterministic Fixture Hash Sweep v#{BasicSharp::VERSION}: PASS"
spec.fetch('required_tools').each { |relative| puts "#{relative}: included in installer-order deterministic family" }
spec.fetch('required_fixture_specs').each { |relative| puts "#{relative}: parsed and current" }
puts 'Complete deterministic fixture family is swept by installer-order validation: PASS'
