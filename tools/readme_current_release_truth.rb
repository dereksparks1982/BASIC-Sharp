#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require_relative '../compiler/readme_current_release_truth'

ROOT = File.expand_path('..', __dir__)
SPEC_PATH = File.join(ROOT, 'spec/self_hosting/BASIC_SHARP_README_CURRENT_RELEASE_TRUTH_v1.json')
README_PATH = File.join(ROOT, 'README.md')
record = BasicSharp::ReadmeCurrentReleaseTruth.new(
  File.read(README_PATH, encoding: 'UTF-8'),
  JSON.parse(File.read(SPEC_PATH, encoding: 'UTF-8'))
).to_h

unless record.fetch(:all_pass)
  warn JSON.pretty_generate(record)
  raise 'README current release truth gate failed'
end

puts "BASIC# README Current Release Truth Gate v#{BasicSharp::VERSION}: PASS"
puts 'README heading matches active version: PASS'
puts 'README current section describes Self-Hosting Milestone 2 Slice 9: PASS'
puts 'Canonical current milestone/build lines match across full README: PASS'
puts 'Stale carried-forward current-release lane text absent: PASS'
puts 'Ruby authority and not-full-self-hosting guardrails present: PASS'
