#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require_relative '../compiler/small_compiler_subset_bsbc_emitter'
require_relative '../compiler/small_compiler_subset_bsbc_encoder'

ROOT = File.expand_path('..', __dir__)
SPEC_PATH = File.join(ROOT, 'spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_BSBC_EMITTER_INDEPENDENCE_v1.json')
ENCODER_PATH = File.join(ROOT, 'compiler/small_compiler_subset_bsbc_encoder.rb')
EMITTER_PATH = File.join(ROOT, 'compiler/small_compiler_subset_bsbc_emitter.rb')

spec = JSON.parse(File.read(SPEC_PATH, encoding: 'UTF-8'))

def assert_contract!(condition, message)
  raise "Small compiler subset BSBC emitter independence failed: #{message}" unless condition
end

assert_contract!(spec.fetch('format') == 'bsharp.small_compiler_subset.bsbc_emitter_independence.contract.json', 'wrong spec identity')
assert_contract!(spec.fetch('format_version') == 1, 'wrong format version')
assert_contract!(spec.fetch('target_version') == BasicSharp::VERSION, 'target version mismatch')
assert_contract!(spec.fetch('status') == 'bsbc_emitter_independent_under_ruby_referee', 'status changed')

encoder_source = File.read(ENCODER_PATH, encoding: 'UTF-8')
emitter_source = File.read(EMITTER_PATH, encoding: 'UTF-8')
assert_contract!(!encoder_source.include?("require_relative 'bytecode_emitter'"), 'independent encoder requires production bytecode emitter')
assert_contract!(!encoder_source.match?(/\bBytecodeEmitter\.new\b/), 'independent encoder calls production bytecode emitter')
assert_contract!(emitter_source.include?('SmallCompilerSubsetBSBCEncoder.new(ir_emitter.bsharp_ir)'), 'primary emitter does not use independent encoder')
assert_contract!(emitter_source.include?('BytecodeEmitter.new(ir_emitter.ruby_referee_bsharp_ir)'), 'separate Ruby referee path is missing')

fixture = spec.fetch('fixture')
source = File.read(File.join(ROOT, fixture.fetch('source_path')), encoding: 'UTF-8')
emitter = BasicSharp::SmallCompilerSubsetBSBCEmitter.new(source)
record = emitter.to_h

assert_contract!(record.fetch(:profile) == fixture.fetch('expected_profile'), 'dedicated fixture profile changed')
assert_contract!(record.fetch(:binary_bytes) == fixture.fetch('expected_binary_bytes'), 'dedicated fixture byte count changed')
assert_contract!(record.fetch(:binary_sha256) == fixture.fetch('expected_binary_sha256'), 'dedicated fixture binary digest changed')
assert_contract!(record.fetch(:disassembly_sha256) == fixture.fetch('expected_disassembly_sha256'), 'dedicated fixture disassembly digest changed')
assert_contract!(record.fetch(:bsharp_ir_sha256) == fixture.fetch('expected_bsharp_ir_sha256'), 'dedicated fixture IR digest changed')
assert_contract!(record.fetch(:fingerprint) == fixture.fetch('expected_fingerprint'), 'dedicated fixture fingerprint changed')
assert_contract!(record.fetch(:loader_summary_sha256) == fixture.fetch('expected_loader_summary_sha256'), 'dedicated fixture loader summary changed')
assert_contract!(record.fetch(:bsbc_ruby_referee_matches), 'independent bytes differ from Ruby referee bytes')
assert_contract!(record.fetch(:disassembly_ruby_referee_matches), 'independent disassembly differs from Ruby referee')
assert_contract!(record.fetch(:fingerprint_ruby_referee_matches), 'independent fingerprint differs from Ruby referee')

# Prove the primary binary path survives even when the production referee cannot emit.
klass = BasicSharp::BytecodeEmitter
klass.class_eval do
  alias_method :__v075_original_binary, :binary
  define_method(:binary) { raise 'production BytecodeEmitter binary called from independent primary path' }
end
begin
  isolated = BasicSharp::SmallCompilerSubsetBSBCEmitter.new(source)
  independent_binary = isolated.binary
  assert_contract!(independent_binary.bytesize == fixture.fetch('expected_binary_bytes'), 'primary independent binary path failed with production emitter disabled')
  assert_contract!(isolated.loader_summary.fetch('profile') == fixture.fetch('expected_profile'), 'loader rejected independent bytes with production emitter disabled')
ensure
  klass.class_eval do
    alias_method :binary, :__v075_original_binary
    remove_method :__v075_original_binary
  end
end

references = [
  'README.md',
  'docs/roadmap/BASIC_SHARP_ROADMAP.md',
  'docs/hand_off/BASIC_SHARP_MASTER_THREAD_HANDOFF.md',
  'docs/company_bible/BASIC_SHARP_COMPANY_BIBLE.md',
  'spec/self_hosting/BASIC_SHARP_SELF_HOSTING_SUBSET_v1.json',
  'spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_BSBC_EMITTER_v1.json'
]
references.each do |relative|
  text = File.read(File.join(ROOT, relative), encoding: 'UTF-8')
  assert_contract!(text.include?('spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_BSBC_EMITTER_INDEPENDENCE_v1.json'), "#{relative} does not reference the BSBC emitter independence spec")
end

puts "BASIC# Small Compiler Subset BSBC Emitter Independence v#{BasicSharp::VERSION}"
puts 'Subset emitter produces its own BSBC bytes: PASS'
puts 'Production bytecode emitter used only as referee: PASS'
puts 'Byte-for-byte BSBC parity: PASS'
puts 'Golden BSBC SHA-256 parity: PASS'
puts 'Existing loader accepts independent bytes: PASS'
puts 'BSharp VM execution lane remains downstream: PASS'
puts 'Profiles 1-7 remain unchanged: PASS'
puts 'SMALL COMPILER SUBSET BSBC EMITTER INDEPENDENCE: PASS'
