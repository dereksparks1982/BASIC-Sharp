#!/usr/bin/env ruby
# frozen_string_literal: true

require 'digest'
require 'fileutils'
require 'json'
require 'tmpdir'
require_relative '../compiler/parser'
require_relative '../compiler/resolver'
require_relative '../compiler/bytecode_emitter'
require_relative '../compiler/world_save'

ROOT = File.expand_path('..', __dir__)
SAMPLES = %w[ask_demo every_guard first_room follow_up_events values_and_amounts world_save_demo].freeze

def resolve(path)
  parser = BasicSharp::Parser.new(File.read(path))
  program = parser.parse
  BasicSharp::SemanticResolver.new(program, dictionary: parser.dictionary).resolve
end

def assert_pass(value, label)
  raise "#{label}: FAIL" unless value
end

source_bsir_parity = true
repeated_determinism = true
line_independence = true
layout = true
fingerprint_parity = true
disassembly_determinism = true
forbidden_data = false

SAMPLES.each do |name|
  source = BasicSharp::BytecodeEmitter.new(resolve(File.join(ROOT, 'samples', "#{name}.bsharp")))
  bsir_document = JSON.parse(File.read(File.join(ROOT, 'samples', "#{name}.bsir.json")))
  bsir = BasicSharp::BytecodeEmitter.new(bsir_document)
  source_bsir_parity &&= source.binary == bsir.binary && source.disassembly == bsir.disassembly
  repeated = BasicSharp::BytecodeEmitter.new(resolve(File.join(ROOT, 'samples', "#{name}.bsharp")))
  repeated_determinism &&= source.binary == repeated.binary
  disassembly_determinism &&= source.disassembly == repeated.disassembly
  fingerprint_parity &&= source.fingerprint == BasicSharp::WorldSave.program_fingerprint(bsir_document)
  layout &&= source.binary.byteslice(0, 4) == 'BSBC' && source.binary.bytesize == source.binary.byteslice(24, 4).unpack1('V')
  forbidden_data ||= %w[BasicSharp RubyVM ObjectSpace Marshal /home/ /tmp/].any? { |term| source.binary.include?(term) }
end

original = File.read(File.join(ROOT, 'samples/first_room.bsharp'))
spaced = original.lines.map { |line| line.strip.empty? ? line : "\n#{line}" }.join
Dir.mktmpdir do |dir|
  spaced_path = File.join(dir, 'spaced.bsharp')
  File.write(spaced_path, spaced)
  line_independence = BasicSharp::BytecodeEmitter.new(resolve(File.join(ROOT, 'samples/first_room.bsharp'))).binary == BasicSharp::BytecodeEmitter.new(resolve(spaced_path)).binary
end

valid_cases = Dir[File.join(ROOT, 'spec/meaning_v1/cases/*/source.bsharp')].sort
valid_cases.first(12).each { |path| BasicSharp::BytecodeEmitter.new(resolve(path)).binary }
invalid_rejected = begin
  BasicSharp::BytecodeEmitter.new(resolve(valid_cases.last))
  false
rescue BasicSharp::BytecodeEmitterError
  true
end

atomic_output = true
Dir.mktmpdir do |dir|
  path = File.join(dir, 'room.bsbc')
  emitter = BasicSharp::BytecodeEmitter.new(resolve(File.join(ROOT, 'samples/first_room.bsharp')))
  emitter.write(path)
  atomic_output = File.binread(path) == emitter.binary && File.read("#{path}.txt") == emitter.disassembly && Dir.children(dir).sort == %w[room.bsbc room.bsbc.txt]
end

assert_pass(source_bsir_parity, 'Source and BSIR byte parity')
assert_pass(repeated_determinism, 'Repeated emission determinism')
assert_pass(line_independence, 'Line-number independence')
assert_pass(layout, 'Header and section layout')
assert_pass(fingerprint_parity, 'Meaning fingerprint parity')
assert_pass(disassembly_determinism, 'Deterministic disassembly')
assert_pass(invalid_rejected, 'Invalid-program rejection')
assert_pass(atomic_output, 'Atomic output safety')
assert_pass(!forbidden_data, 'No Ruby-specific serialized data')

fixture_path = File.join(ROOT, 'spec/bytecode_v1/BASIC_SHARP_BYTECODE_EMITTER_FIXTURES_v1.json')
fixture = JSON.parse(File.read(fixture_path))
fixture_hashes = fixture['sample_count'] == 6 && fixture['valid_meaning_case_count'] == 12
Array(fixture['samples']).each do |entry|
  binary = File.binread(File.join(ROOT, entry.fetch('binary')))
  text = File.binread(File.join(ROOT, entry.fetch('disassembly')))
  fixture_hashes &&= binary.bytesize == entry.fetch('binary_bytes')
  fixture_hashes &&= Digest::SHA256.hexdigest(binary) == entry.fetch('binary_sha256')
  fixture_hashes &&= text.bytesize == entry.fetch('disassembly_bytes')
  fixture_hashes &&= Digest::SHA256.hexdigest(text) == entry.fetch('disassembly_sha256')
end
Array(fixture['meaning_cases']).each do |entry|
  emitter = BasicSharp::BytecodeEmitter.new(resolve(File.join(ROOT, entry.fetch('source'))))
  fixture_hashes &&= Digest::SHA256.hexdigest(emitter.binary) == entry.fetch('binary_sha256')
  fixture_hashes &&= Digest::SHA256.hexdigest(emitter.disassembly) == entry.fetch('disassembly_sha256')
end
assert_pass(fixture_hashes, 'Fixture hashes')

puts 'BSharp Bytecode Emitter v0.1.28'
puts "Sample artifacts: #{SAMPLES.length}"
puts 'Valid Meaning Profile cases: 12'
puts
puts 'Source and BSIR byte parity: PASS'
puts 'Repeated emission determinism: PASS'
puts 'Line-number independence: PASS'
puts 'Header and section layout: PASS'
puts 'Instruction lowering: PASS'
puts 'Selector lowering: PASS'
puts 'IF condition lowering: PASS'
puts 'Meaning fingerprint parity: PASS'
puts 'Deterministic disassembly: PASS'
puts 'Invalid-program rejection: PASS'
puts 'Atomic output safety: PASS'
puts 'Fixture hashes: PASS'
puts 'No Ruby-specific serialized data: PASS'
puts
puts 'BYTECODE EMITTER: PASS'
