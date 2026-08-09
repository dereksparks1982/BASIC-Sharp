#!/usr/bin/env ruby
# frozen_string_literal: true

require 'digest'
require 'json'
require_relative 'trial_by_fire_support'

include BasicSharp

inventory = JSON.parse(File.read(TrialByFire::VALIDATION_INVENTORY, encoding: Encoding::UTF_8))
TrialByFire.assert!(inventory.fetch('format') == 'bsharp.trial_by_fire.validation_inventory.json', 'validation inventory identity changed')
TrialByFire.assert!(inventory.fetch('target_version') == BasicSharp::VERSION, 'validation inventory target version changed')

verify_records = lambda do |label, records|
  records.each do |entry|
    path = entry.fetch('path')
    absolute = File.join(TrialByFire::ROOT, path)
    TrialByFire.assert!(File.file?(absolute), "#{label} is missing #{path}")
    TrialByFire.assert!(File.size(absolute) == entry.fetch('bytes'), "#{label} byte count changed for #{path}")
    TrialByFire.assert!(Digest::SHA256.file(absolute).hexdigest == entry.fetch('sha256'), "#{label} hash changed for #{path}")
  end
end

tests = Dir[File.join(TrialByFire::ROOT, 'tests/test_*.rb')].sort.map { |path| path.delete_prefix("#{TrialByFire::ROOT}/") }
expected_tests = inventory.fetch('test_files').map { |entry| entry.fetch('path') }
TrialByFire.assert!(tests == expected_tests, 'discovered test-file inventory changed')
verify_records.call('test file', inventory.fetch('test_files'))
verify_records.call('required tool', inventory.fetch('required_tools'))
verify_records.call('sealed artifact', inventory.fetch('sealed_artifacts'))
TrialByFire.verify_profile_artifacts!(inventory.fetch('protected_artifacts'))

counts = inventory.fetch('gauntlet_defaults')
TrialByFire.assert!(counts == {
  'events_per_path' => 128_000,
  'platform_frames' => 128_000,
  'input_movement_frames' => 64_000,
  'ask_questions' => 32_000,
  'save_checkpoints' => 1_250,
  'isolated_worlds' => 320,
  'generated_programs' => 384,
  'mutations_per_boundary' => 3_072,
  'hostile_artifacts' => 12_288,
  'follow_up_boundaries' => [1_023, 1_024, 1_025]
}, 'gauntlet default counts changed')

puts "Validation inventory test files: #{tests.length}"
puts "Validation inventory required tools: #{inventory.fetch('required_tools').length}"
puts "Validation inventory protected artifacts: #{inventory.fetch('protected_artifacts').length}"
puts 'TRIAL BY FIRE VALIDATION INVENTORY: PASS'
