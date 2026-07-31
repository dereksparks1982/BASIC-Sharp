#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require_relative '../compiler/meaning_profile'

root = File.expand_path('..', __dir__)
manifest_path = File.join(root, 'spec/meaning_v2/BASIC_SHARP_MEANING_PROFILE_v2.json')
manifest = JSON.parse(File.read(manifest_path, encoding: 'UTF-8'))
update = ARGV.delete('--update')

if update
  manifest.fetch('cases').each do |entry|
    observation = BasicSharp::MeaningProfile.observe_case(
      entry,
      root: root,
      profile: BasicSharp::MeaningProfile::PROFILE_2
    )
    text = BasicSharp::MeaningProfile.canonical_json(observation)
    File.write(File.join(root, entry.fetch('expected')), text)
    entry['expected_sha256'] = BasicSharp::MeaningProfile.sha256(text)
  end
  File.write(manifest_path, "#{JSON.pretty_generate(manifest)}\n")
end

BasicSharp::MeaningProfile.validate_manifest!(manifest, root: root)
manifest.fetch('cases').each do |entry|
  observed = BasicSharp::MeaningProfile.observe_case(
    entry,
    root: root,
    profile: BasicSharp::MeaningProfile::PROFILE_2
  )
  expected = JSON.parse(File.read(File.join(root, entry.fetch('expected')), encoding: 'UTF-8'))
  unless observed == expected
    raise BasicSharp::MeaningProfileError, "Meaning Profile 2 case #{entry.fetch('id')} does not match its expected result."
  end
end

puts "BASIC# Meaning Profile 2: PASS (#{manifest.fetch('cases').length} cases)"
