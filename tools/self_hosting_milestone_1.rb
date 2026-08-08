#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require_relative '../compiler/self_hosting_milestone_1'

ROOT = File.expand_path('..', __dir__)
SPEC_PATH = File.join(ROOT, 'spec/self_hosting/BASIC_SHARP_SELF_HOSTING_MILESTONE_1_v1.json')
record = BasicSharp::SelfHostingMilestone1.new(JSON.parse(File.read(SPEC_PATH, encoding: 'UTF-8')), root: ROOT).to_h

unless record.fetch(:all_pass)
  warn JSON.pretty_generate(record)
  raise 'Self-Hosting Milestone 1 gate failed'
end

puts "BASIC# v#{BasicSharp::VERSION} Self-Hosting Milestone 1: PASS"
puts 'BSharp Compiler Subset 0 lane evidence present: PASS'
puts 'Runtime smoke remains under Ruby referee: PASS'
puts 'Bootstrap boundary audit remains sealed: PASS'
puts 'README current release truth gate passed: PASS'
puts 'No full self-hosting, Ruby retirement, Profile 8, or runtime behaviour claim: PASS'
puts "Milestone evidence digest: #{record.fetch(:evidence_digest_sha256)}"
