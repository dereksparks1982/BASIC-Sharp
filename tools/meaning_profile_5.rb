#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require_relative '../compiler/meaning_profile'

root = File.expand_path('..', __dir__)
path = File.join(root, 'spec/meaning_v5/BASIC_SHARP_MEANING_PROFILE_v5.json')
manifest = JSON.parse(File.read(path, encoding: 'UTF-8'))
BasicSharp::MeaningProfile.validate_manifest!(manifest, root: root)
manifest.fetch('cases').each do |entry|
  actual = BasicSharp::MeaningProfile.observe_case(entry, root: root, profile: BasicSharp::MeaningProfile::PROFILE_5)
  expected = JSON.parse(File.read(File.join(root, entry.fetch('expected')), encoding: 'UTF-8'))
  raise "Meaning Profile 5 case #{entry.fetch('id')} failed" unless actual == expected
end
puts "BASIC# Meaning Profile 5: PASS (#{manifest.fetch('cases').length} cases)"
