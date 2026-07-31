#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require_relative '../compiler/meaning_profile'

root = File.expand_path('..', __dir__)
manifest_path = File.join(root, 'spec/meaning_v1/BASIC_SHARP_MEANING_PROFILE_v1.json')
manifest = JSON.parse(File.read(manifest_path))
BasicSharp::MeaningProfile.validate_manifest!(manifest, root: root)

failures = []
manifest.fetch('cases').each do |entry|
  expected_path = File.join(root, entry.fetch('expected'))
  expected = JSON.parse(File.read(expected_path))
  actual = BasicSharp::MeaningProfile.observe_case(entry, root: root)
  failures << entry.fetch('id') unless actual == expected
end

puts 'BASIC# Meaning Conformance Profile 1'
puts "Cases: #{manifest.fetch('cases').length}"
puts
if failures.empty?
  puts 'Source meaning: PASS'
  puts 'BSharp IR meaning: PASS'
  puts 'Runtime meaning: PASS'
  puts 'BSharp Save meaning: PASS'
  puts 'BSharp ASK meaning: PASS'
  puts 'Deterministic replay: PASS'
  puts
  puts 'PROFILE 1: PASS'
  exit 0
end

warn "Conformance failures: #{failures.join(', ')}"
warn 'PROFILE 1: FAIL'
exit 1
