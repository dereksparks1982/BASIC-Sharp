#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require_relative '../compiler/readme_current_release_truth'

ROOT = File.expand_path('..', __dir__)
SPEC_PATH = File.join(ROOT, 'spec/self_hosting/BASIC_SHARP_README_CURRENT_RELEASE_TRUTH_v1.json')
README_PATH = File.join(ROOT, 'README.md')
HISTORY_PATH = File.join(ROOT, 'docs/history/BASIC_SHARP_TECHNICAL_HISTORY.md')

record = BasicSharp::ReadmeCurrentReleaseTruth.new(
  File.read(README_PATH, encoding: 'UTF-8'),
  JSON.parse(File.read(SPEC_PATH, encoding: 'UTF-8')),
  history_text: File.read(HISTORY_PATH, encoding: 'UTF-8')
).to_h

unless record.fetch(:all_pass)
  warn JSON.pretty_generate(record)
  raise 'README and archived technical history truth gate failed'
end

puts "BASIC# README and Technical History Truth Gate v#{BasicSharp::VERSION}: PASS"
puts 'Public README identifies BASIC# and the current accepted release: PASS'
puts 'Full numbered technical history is preserved in docs: PASS'
puts 'Ruby authority and not-full-self-hosting guardrails present: PASS'
