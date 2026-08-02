#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'trial_by_fire_support'

include BasicSharp

count = TrialByFire.env_count('BASIC_SHARP_TRIAL_PROGRAMS', 256)
seed = Integer(ENV.fetch('BASIC_SHARP_TRIAL_SEED', TrialByFire::DEFAULT_SEED.to_s), 10)
raise ArgumentError, 'BASIC_SHARP_TRIAL_PROGRAMS cannot exceed the sealed 256-program inventory' if count > 256

puts "TRIAL BY FIRE — deterministic valid-program generator"
puts "Seed: #{seed}"
puts "Programs: #{count}"
campaign = TrialByFire.run_generator_campaign(
  count: count,
  seed: seed,
  progress: lambda do |done, total|
    puts "Generator progress: #{done}/#{total}" if (done % 16).zero? || done == total
  end
)

if count == 256 && seed == TrialByFire::DEFAULT_SEED && File.file?(TrialByFire::COVERAGE_MATRIX)
  expected = JSON.parse(File.read(TrialByFire::COVERAGE_MATRIX, encoding: Encoding::UTF_8))
  actual_coverage = campaign.fetch('results').map { |entry| entry.fetch('coverage') }
  TrialByFire.assert!(expected.fetch('seed') == seed, 'coverage matrix seed changed')
  TrialByFire.assert!(expected.fetch('programs') == actual_coverage, 'coverage matrix no longer matches generated programs')
end

puts "Profile counts: #{campaign.fetch('profile_counts').sort.to_h}"
puts "Results SHA-256: #{campaign.fetch('results_sha256')}"
puts 'TRIAL BY FIRE GENERATOR: PASS'
