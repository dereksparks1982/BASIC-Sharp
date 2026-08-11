#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require_relative '../compiler/bootstrap_boundary_audit'

ROOT = File.expand_path('..', __dir__)
SPEC_PATH = File.join(ROOT, 'spec/self_hosting/BASIC_SHARP_BOOTSTRAP_BOUNDARY_AUDIT_v1.json')
spec = JSON.parse(File.read(SPEC_PATH, encoding: 'UTF-8'))

def assert_contract!(condition, message)
  raise "Bootstrap boundary audit failed: #{message}" unless condition
end

record = BasicSharp::BootstrapBoundaryAudit.new(spec, root: ROOT).to_h
assert_contract!(record.fetch(:all_pass), 'one or more bootstrap boundary checks failed')
assert_contract!(record.fetch(:stage_count) >= 7, 'not enough boundary stages')
assert_contract!(record.fetch(:checks).fetch(:ruby_referee_declared), 'Ruby referee boundary missing')
assert_contract!(record.fetch(:checks).fetch(:subset_output_declared), 'subset output boundary missing')
assert_contract!(record.fetch(:checks).fetch(:runtime_smoke_declared), 'runtime smoke bridge missing')
assert_contract!(record.fetch(:checks).fetch(:production_boundary_declared), 'production runtime boundary missing')
assert_contract!(record.fetch(:checks).fetch(:no_self_hosting_claim), 'self-hosting claim prohibition missing')
assert_contract!(record.fetch(:checks).fetch(:ruby_replacement_forbidden), 'Ruby replacement prohibition missing')
assert_contract!(record.fetch(:checks).fetch(:profile_8_forbidden), 'Profile 8 prohibition missing')
assert_contract!(record.fetch(:checks).fetch(:production_runtime_change_forbidden), 'production runtime change prohibition missing')
assert_contract!(record.fetch(:checks).fetch(:authority_ladder_locked), 'authority ladder drifted')
assert_contract!(record.fetch(:checks).fetch(:no_expected_self_comparison_fallbacks), 'expected_* fallback/self-comparison pattern found')

puts "BASIC# Bootstrap Boundary Audit v#{BasicSharp::VERSION}: PASS"
puts "Boundary stages: #{record.fetch(:stage_count)}"
puts 'Ruby bootstrap referee remains source of truth: PASS'
puts 'BASIC# subset participation is fenced: PASS'
puts 'Runtime smoke bridge is evidence only: PASS'
puts 'v0.1.76 Slice 3 milestone gate remains guarded: PASS'
puts 'Golden fixture expected-field fallbacks absent: PASS'
puts "Boundary digest: #{record.fetch(:boundary_digest_sha256)}"
