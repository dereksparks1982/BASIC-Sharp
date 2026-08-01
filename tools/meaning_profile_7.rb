#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require_relative '../compiler/meaning_profile'

root = File.expand_path('..', __dir__)
path = File.join(root, 'spec/meaning_v7/BASIC_SHARP_MEANING_PROFILE_v7.json')
manifest = JSON.parse(File.read(path))
BasicSharp::MeaningProfile.validate_manifest!(manifest, root: root)
manifest.fetch('cases').each do |entry|
  actual = BasicSharp::MeaningProfile.observe_case(entry, root: root, profile: BasicSharp::MeaningProfile::PROFILE_7)
  expected_text = File.read(File.join(root, entry.fetch('expected')))
  expected = JSON.parse(expected_text)
  raise "#{entry.fetch('id')} observation changed" unless actual == expected
  raise "#{entry.fetch('id')} expected hash changed" unless BasicSharp::MeaningProfile.sha256(expected_text) == entry.fetch('expected_sha256')
end

puts "BASIC# Meaning Profile 7 v#{BasicSharp::VERSION}"
puts "Cases: #{manifest.fetch('cases').length}"
puts 'Source and saved BSIR parity: PASS'
puts 'IF and OTHERWISE conformance: PASS'
