#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require_relative '../compiler/small_compiler_subset_bsbc_emitter'

ROOT = File.expand_path('..', __dir__)
SPEC_PATH = File.join(ROOT, 'spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_BSBC_EMITTER_v1.json')

spec = JSON.parse(File.read(SPEC_PATH, encoding: 'UTF-8'))

def assert_contract!(condition, message)
  raise "Small compiler subset BSBC emitter failed: #{message}" unless condition
end

assert_contract!(spec.fetch('format') == 'bsharp.small_compiler_subset.bsbc_emitter.json', 'wrong spec identity')
assert_contract!(spec.fetch('format_version') == 1, 'wrong spec format version')
assert_contract!(spec.fetch('target_version') == BasicSharp::VERSION, 'spec target does not match BasicSharp::VERSION')
assert_contract!(spec.fetch('status') == 'bsbc_emission_independent_under_ruby_referee', 'wrong contract status')

profiles = []
spec.fetch('valid_fixtures').each do |fixture|
  record = BasicSharp::SmallCompilerSubsetBSBCEmitter.new(fixture.fetch('source')).to_h
  profiles << record.fetch(:profile)
  assert_contract!(record.fetch(:parser_ruby_referee_matches), "parser referee mismatch for #{fixture.fetch('name')}")
  assert_contract!(record.fetch(:ir_ruby_referee_matches), "IR referee mismatch for #{fixture.fetch('name')}")
  assert_contract!(record.fetch(:bsbc_ruby_referee_matches), "BSBC referee mismatch for #{fixture.fetch('name')}")
  assert_contract!(record.fetch(:disassembly_ruby_referee_matches), "disassembly referee mismatch for #{fixture.fetch('name')}")
  assert_contract!(record.fetch(:fingerprint_ruby_referee_matches), "fingerprint referee mismatch for #{fixture.fetch('name')}")
  assert_contract!(record.fetch(:binary_format) == 'bsharp.bytecode.bin', "wrong binary format for #{fixture.fetch('name')}")
  assert_contract!(record.fetch(:profile) == fixture.fetch('expected_profile'), "profile changed for #{fixture.fetch('name')}")
  assert_contract!(record.fetch(:binary_bytes) == fixture.fetch('expected_binary_bytes'), "binary byte count changed for #{fixture.fetch('name')}")
  assert_contract!(record.fetch(:binary_sha256) == fixture.fetch('expected_binary_sha256'), "binary digest changed for #{fixture.fetch('name')}")
  assert_contract!(record.fetch(:disassembly_sha256) == fixture.fetch('expected_disassembly_sha256'), "disassembly digest changed for #{fixture.fetch('name')}")
  assert_contract!(record.fetch(:bsharp_ir_sha256) == fixture.fetch('expected_bsharp_ir_sha256'), "IR digest changed for #{fixture.fetch('name')}")
  assert_contract!(record.fetch(:fingerprint) == fixture.fetch('expected_fingerprint'), "meaning fingerprint changed for #{fixture.fetch('name')}")
  assert_contract!(BasicSharp::SmallCompilerSubsetBSBCEmitter.normalize(record.fetch(:loader_summary)) == BasicSharp::SmallCompilerSubsetBSBCEmitter.normalize(fixture.fetch('expected_loader_summary')), "loader summary changed for #{fixture.fetch('name')}")
  assert_contract!(record.fetch(:loader_summary_sha256) == fixture.fetch('expected_loader_summary_sha256'), "loader summary digest changed for #{fixture.fetch('name')}")
end

%w[bsharp.bytecode.v1 bsharp.bytecode.v2 bsharp.bytecode.v4 bsharp.bytecode.v7].each do |profile|
  assert_contract!(profiles.include?(profile), "missing protected subset bytecode profile #{profile}")
end

puts "BASIC# Small Compiler Subset BSBC Emitter v#{BasicSharp::VERSION}: PASS"

puts 'Independent Subset 0 encoder: PASS'
puts 'Production BytecodeEmitter referee parity: PASS'
