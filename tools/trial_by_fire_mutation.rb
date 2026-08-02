#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'trial_by_fire_support'

include BasicSharp

count = TrialByFire.env_count('BASIC_SHARP_TRIAL_MUTATIONS_PER_BOUNDARY', 2_048)
puts 'TRIAL BY FIRE — hostile artifact mutation campaign'
puts "Mutations per boundary: #{count}"
campaign = TrialByFire.run_mutation_campaign(
  count: count,
  progress: lambda do |done, total|
    puts "Mutation progress: #{done}/#{total} (#{done * 4} hostile artifacts)" if (done % 128).zero? || done == total
  end
)
puts "Hostile artifacts rejected: #{campaign.fetch('hostile_artifacts')}"
puts "Truncated BSBC prefixes rejected: #{campaign.fetch('truncated_prefixes')}"
puts "Rejections SHA-256: #{campaign.fetch('rejections_sha256')}"
puts 'TRIAL BY FIRE MUTATION CAMPAIGN: PASS'
