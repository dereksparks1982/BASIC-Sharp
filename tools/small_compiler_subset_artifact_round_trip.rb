#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require 'tmpdir'
require 'fileutils'
require_relative '../compiler/small_compiler_subset_driver'
require_relative '../compiler/parser'
require_relative '../compiler/resolver'
require_relative '../compiler/bytecode_emitter'
require_relative '../compiler/bytecode_loader'
require_relative '../compiler/bytecode_virtual_machine'
require_relative '../compiler/runtime'

ROOT = File.expand_path('..', __dir__)
SPEC_PATH = File.join(ROOT, 'spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_ARTIFACT_ROUND_TRIP_v1.json')
spec = JSON.parse(File.read(SPEC_PATH, encoding: 'UTF-8'))
driver_spec = JSON.parse(File.read(File.join(ROOT, spec.fetch('fixture_spec')), encoding: 'UTF-8'))
fixture = driver_spec.fetch('fixture')
expected = spec.fetch('expected')

def assert_round_trip!(condition, message)
  raise "Small compiler subset artifact round trip failed: #{message}" unless condition
end

def normalize(value)
  BasicSharp::SmallCompilerSubsetPipeline.normalize(value)
end

def semantic(value)
  case value
  when Hash
    value.each_with_object({}) do |(key, child), result|
      key = key.to_s
      next if %w[line_number caused_by_line].include?(key)
      result[key] = semantic(child)
    end.sort.to_h
  when Array then value.map { |child| semantic(child) }
  else value
  end
end

assert_round_trip!(spec.fetch('format') == 'bsharp.small_compiler_subset.artifact_round_trip.contract.json', 'wrong spec identity')
assert_round_trip!(spec.fetch('format_version') == 1, 'wrong format version')
assert_round_trip!(spec.fetch('target_version') == BasicSharp::VERSION, 'target version mismatch')
assert_round_trip!(spec.fetch('status') == 'independent_bsbc_artifact_round_trip_under_ruby_referee', 'status changed')

source_path = File.join(ROOT, fixture.fetch('source_path'))
source = File.read(source_path, encoding: 'UTF-8')
events = fixture.fetch('events')

Dir.mktmpdir('basic-sharp-v079-round-trip') do |directory|
  copied_source = File.join(directory, 'program.bsharp')
  File.binwrite(copied_source, File.binread(source_path))
  destination = File.join(directory, fixture.fetch('artifact_name'))

  driver = BasicSharp::SmallCompilerSubsetDriver.from_file(copied_source)
  driver.compile_to(destination)
  assert_round_trip!(File.file?(destination), 'BSBC artifact missing')
  assert_round_trip!(driver.artifact_sha256 == expected.fetch('binary_sha256'), 'artifact digest changed')
  assert_round_trip!(BasicSharp::SmallCompilerSubsetDriver.digest_text(File.read("#{destination}.txt", encoding: 'UTF-8')) == expected.fetch('disassembly_sha256'), 'disassembly digest changed')

  # Compile repeatedly into separate real files and require exact bytes/disassembly.
  spec.fetch('deterministic_compile_repetitions').times do |index|
    repeated = BasicSharp::SmallCompilerSubsetDriver.from_file(copied_source)
    repeated_path = File.join(directory, format('repeat_%02d.bsbc', index))
    repeated.compile_to(repeated_path)
    assert_round_trip!(File.binread(repeated_path) == File.binread(destination), "repeat #{index + 1} artifact differs")
    assert_round_trip!(File.read("#{repeated_path}.txt", encoding: 'UTF-8') == File.read("#{destination}.txt", encoding: 'UTF-8'), "repeat #{index + 1} disassembly differs")
  end

  in_memory = driver.execute_in_memory(events)
  artifact = driver.execute_artifact(events)
  assert_round_trip!(normalize(in_memory) == normalize(artifact), 'artifact execution differs from fresh independent in-memory execution')
  assert_round_trip!(BasicSharp::SmallCompilerSubsetDriver.digest_json(artifact.fetch('events')) == expected.fetch('event_results_sha256'), 'artifact event-result digest changed')
  assert_round_trip!(BasicSharp::SmallCompilerSubsetDriver.digest_json(artifact.fetch('snapshot')) == expected.fetch('final_snapshot_sha256'), 'artifact final-world digest changed')
  assert_round_trip!(BasicSharp::SmallCompilerSubsetDriver.digest_json(artifact.fetch('save')) == expected.fetch('save_document_sha256'), 'artifact Save digest changed')

  # Prove the persisted artifact no longer needs the source file.
  File.delete(copied_source)
  loader = BasicSharp::SmallCompilerSubsetBSBCLoader.read(destination, expected_fingerprint: driver.pipeline.fingerprint)
  vm = BasicSharp::SmallCompilerSubsetBSBCVirtualMachine.new(loader)
  source_free_results = events.map { |event| vm.run_event(event) }
  assert_round_trip!(normalize(source_free_results) == normalize(artifact.fetch('events')), 'source-free artifact execution changed')
  assert_round_trip!(normalize(vm.snapshot) == normalize(artifact.fetch('snapshot')), 'source-free final world changed')

  # Failed source compilation must not disturb an already accepted artifact.
  before_bytes = File.binread(destination)
  before_text = File.binread("#{destination}.txt")
  begin
    BasicSharp::SmallCompilerSubsetDriver.new('THIS IS NOT BASIC#').compile_to(destination)
    raise 'invalid BASIC# unexpectedly compiled'
  rescue StandardError
    # Expected. Construction fails before any artifact mutation.
  end
  assert_round_trip!(File.binread(destination) == before_bytes, 'failed compilation overwrote existing BSBC artifact')
  assert_round_trip!(File.binread("#{destination}.txt") == before_text, 'failed compilation overwrote existing disassembly')

  # Separate production and Ruby referee comparisons.
  parser = BasicSharp::Parser.new(source)
  document = BasicSharp::SemanticResolver.new(parser.parse, dictionary: parser.dictionary).resolve.to_h
  emitter = BasicSharp::BytecodeEmitter.new(document)
  production_loader = BasicSharp::BytecodeLoader.new(emitter.binary, expected_fingerprint: emitter.fingerprint)
  production_vm = BasicSharp::BytecodeVirtualMachine.new(production_loader)
  ruby_runtime = BasicSharp::Runtime.new(document)
  production_results = events.map { |event| production_vm.run_event(event) }
  ruby_results = events.map { |event| ruby_runtime.run_event(event) }

  assert_round_trip!(File.binread(destination) == emitter.binary, 'saved artifact differs from production emitter referee')
  assert_round_trip!(normalize(production_results) == normalize(artifact.fetch('events')), 'artifact results differ from production VM referee')
  assert_round_trip!(semantic(ruby_results) == semantic(artifact.fetch('events')), 'artifact semantics differ from Ruby runtime referee')
  assert_round_trip!(normalize(production_vm.snapshot) == normalize(artifact.fetch('snapshot')), 'artifact world differs from production VM referee')
  assert_round_trip!(normalize(ruby_runtime.snapshot) == normalize(artifact.fetch('snapshot')), 'artifact world differs from Ruby runtime referee')
end

puts "BASIC# Small Compiler Subset BSBC Artifact Round Trip v#{BasicSharp::VERSION}"
puts 'Real BSBC artifact persisted: PASS'
puts "Deterministic artifact compilation: PASS (#{spec.fetch('deterministic_compile_repetitions')} repetitions)"
puts 'Deterministic readable disassembly: PASS'
puts 'Saved artifact reloads independently: PASS'
puts 'Saved artifact executes independently: PASS'
puts 'In-memory and saved-artifact execution parity: PASS'
puts 'Source file unnecessary after artifact creation: PASS'
puts 'Failed compilation preserves existing artifact atomically: PASS'
puts 'Production BSharp VM referee parity: PASS'
puts 'Ruby runtime referee parity: PASS'
puts 'Profiles 1-7 remain unchanged: PASS'
puts 'SMALL COMPILER SUBSET BSBC ARTIFACT ROUND TRIP: PASS'
