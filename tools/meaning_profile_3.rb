#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require_relative '../compiler/meaning_profile'

root = File.expand_path('..', __dir__)
path = File.join(root, 'spec/meaning_v3/BASIC_SHARP_MEANING_PROFILE_v3.json')
manifest = JSON.parse(File.read(path, encoding: 'UTF-8'))
BasicSharp::MeaningProfile.validate_manifest!(manifest, root: root)
manifest.fetch('cases').each do |entry|
  actual = BasicSharp::MeaningProfile.observe_case(entry, root: root, profile: BasicSharp::MeaningProfile::PROFILE_3)
  expected = JSON.parse(File.read(File.join(root, entry.fetch('expected')), encoding: 'UTF-8'))
  raise "Meaning Profile 3 case #{entry.fetch('id')} failed" unless actual == expected
end
puts "BASIC# Meaning Profile 3: PASS (#{manifest.fetch('cases').length} cases)"
