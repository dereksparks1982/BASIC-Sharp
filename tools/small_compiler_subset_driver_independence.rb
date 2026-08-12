#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require 'tmpdir'
require_relative '../compiler/small_compiler_subset_driver'
require_relative '../compiler/lexer'
require_relative '../compiler/parser'
require_relative '../compiler/resolver'
require_relative '../compiler/bytecode_emitter'
require_relative '../compiler/bytecode_loader'
require_relative '../compiler/bytecode_virtual_machine'
require_relative '../compiler/runtime'

ROOT = File.expand_path('..', __dir__)
SPEC_PATH = File.join(ROOT, 'spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_DRIVER_INDEPENDENCE_v1.json')
spec = JSON.parse(File.read(SPEC_PATH, encoding: 'UTF-8'))

def assert_contract!(condition, message)
  raise "Small compiler subset driver independence failed: #{message}" unless condition
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

assert_contract!(spec.fetch('format') == 'bsharp.small_compiler_subset.driver_independence.contract.json', 'wrong spec identity')
assert_contract!(spec.fetch('format_version') == 1, 'wrong format version')
assert_contract!(spec.fetch('target_version') == BasicSharp::VERSION, 'target version mismatch')
assert_contract!(spec.fetch('status') == BasicSharp::SmallCompilerSubsetDriver::STATUS, 'status changed')

driver_source = File.read(File.join(ROOT, 'compiler/small_compiler_subset_driver.rb'), encoding: 'UTF-8')
%w[lexer parser resolver bytecode_emitter bytecode_loader bytecode_virtual_machine runtime runtime_transition].each do |name|
  assert_contract!(!driver_source.include?("require_relative '#{name}'"), "driver requires production #{name}")
end
assert_contract!(driver_source.include?('SmallCompilerSubsetPipeline.new'), 'driver does not invoke the independent integrated pipeline')
assert_contract!(!driver_source.match?(/\bParser\.new\b/), 'driver calls production Parser')
assert_contract!(!driver_source.match?(/\bSemanticResolver\.new\b/), 'driver calls production SemanticResolver')
assert_contract!(!driver_source.match?(/\bBytecodeEmitter\.new\b/), 'driver calls production BytecodeEmitter')
assert_contract!(!driver_source.match?(/\bBytecodeLoader\.new\b/), 'driver calls production BytecodeLoader')
assert_contract!(!driver_source.match?(/\bBytecodeVirtualMachine\.new\b/), 'driver calls production BytecodeVirtualMachine')
assert_contract!(!driver_source.match?(/\bRuntime\.new\b/), 'driver calls production Runtime')

fixture = spec.fetch('fixture')
source_path = File.join(ROOT, fixture.fetch('source_path'))
source = File.read(source_path, encoding: 'UTF-8')

Dir.mktmpdir('basic-sharp-v079-driver') do |directory|
  destination = File.join(directory, fixture.fetch('artifact_name'))

  # Primary path must survive with every production constructor disabled.
  classes = [
    BasicSharp::Lexer,
    BasicSharp::Parser,
    BasicSharp::SemanticResolver,
    BasicSharp::BytecodeEmitter,
    BasicSharp::BytecodeLoader,
    BasicSharp::BytecodeVirtualMachine,
    BasicSharp::Runtime
  ]
  aliases = []
  begin
    classes.each_with_index do |klass, index|
      singleton = klass.singleton_class
      alias_name = "__v079_driver_gate_original_new_#{index}".to_sym
      singleton.class_eval do
        alias_method alias_name, :new
        define_method(:new) { |*| raise "production constructor invoked: #{klass}" }
      end
      aliases << [singleton, alias_name]
    end

    isolated_driver = BasicSharp::SmallCompilerSubsetDriver.from_file(source_path)
    isolated_driver.compile_to(destination)
    assert_contract!(isolated_driver.pipeline.is_a?(BasicSharp::SmallCompilerSubsetPipeline), 'driver did not retain the independent pipeline')
    assert_contract!(File.file?(destination), 'real BSBC artifact was not written')
    assert_contract!(File.file?("#{destination}.txt"), 'readable BSBC disassembly was not written')
    assert_contract!(isolated_driver.artifact_sha256 == fixture.fetch('expected_binary_sha256'), 'isolated artifact digest changed')
    isolated_result = isolated_driver.execute_artifact(fixture.fetch('events'))
    assert_contract!(BasicSharp::SmallCompilerSubsetDriver.digest_json(isolated_result.fetch('events')) == fixture.fetch('expected_event_results_sha256'), 'isolated artifact event results changed')
    assert_contract!(BasicSharp::SmallCompilerSubsetDriver.digest_json(isolated_result.fetch('snapshot')) == fixture.fetch('expected_final_snapshot_sha256'), 'isolated artifact final world changed')
  ensure
    aliases.reverse_each do |singleton, alias_name|
      singleton.class_eval do
        alias_method :new, alias_name
        remove_method alias_name
      end
    end
  end

  driver = BasicSharp::SmallCompilerSubsetDriver.from_file(source_path)
  driver.compile_to(destination)
  record = driver.driver_record
  assert_contract!(record.fetch(:profile) == fixture.fetch('expected_profile'), 'fixture profile changed')
  assert_contract!(record.fetch(:source_sha256) == fixture.fetch('expected_source_sha256'), 'source digest changed')
  assert_contract!(record.fetch(:bsharp_ir_sha256) == fixture.fetch('expected_bsharp_ir_sha256'), 'BSharp IR digest changed')
  assert_contract!(record.fetch(:binary_bytes) == fixture.fetch('expected_binary_bytes'), 'binary byte count changed')
  assert_contract!(record.fetch(:binary_sha256) == fixture.fetch('expected_binary_sha256'), 'binary digest changed')
  assert_contract!(record.fetch(:artifact_sha256) == fixture.fetch('expected_binary_sha256'), 'saved artifact digest changed')
  assert_contract!(record.fetch(:disassembly_sha256) == fixture.fetch('expected_disassembly_sha256'), 'disassembly digest changed')
  assert_contract!(record.fetch(:fingerprint) == fixture.fetch('expected_fingerprint'), 'fingerprint changed')
  assert_contract!(driver.artifact_bytes == driver.pipeline.binary, 'saved artifact bytes differ from independent in-memory bytes')
  assert_contract!(driver.artifact_loader.is_a?(BasicSharp::SmallCompilerSubsetBSBCLoader), 'saved artifact did not reload through independent loader')
  assert_contract!(driver.artifact_virtual_machine.is_a?(BasicSharp::SmallCompilerSubsetBSBCVirtualMachine), 'saved artifact did not execute through independent VM')

  # Separate production and Ruby referee comparisons.
  parser = BasicSharp::Parser.new(source)
  document = BasicSharp::SemanticResolver.new(parser.parse, dictionary: parser.dictionary).resolve.to_h
  production_emitter = BasicSharp::BytecodeEmitter.new(document)
  production_loader = BasicSharp::BytecodeLoader.new(production_emitter.binary, expected_fingerprint: production_emitter.fingerprint)
  production_vm = BasicSharp::BytecodeVirtualMachine.new(production_loader)
  ruby_runtime = BasicSharp::Runtime.new(document)

  assert_contract!(production_emitter.binary == driver.artifact_bytes, 'saved artifact differs from production emitter referee')
  artifact = driver.execute_artifact(fixture.fetch('events'))
  production_results = fixture.fetch('events').map { |event| production_vm.run_event(event) }
  ruby_results = fixture.fetch('events').map { |event| ruby_runtime.run_event(event) }
  assert_contract!(normalize(production_results) == normalize(artifact.fetch('events')), 'artifact event results differ from production VM referee')
  assert_contract!(semantic(ruby_results) == semantic(artifact.fetch('events')), 'artifact event semantics differ from Ruby runtime referee')
  assert_contract!(normalize(production_vm.snapshot) == normalize(artifact.fetch('snapshot')), 'artifact final world differs from production VM referee')
  assert_contract!(normalize(ruby_runtime.snapshot) == normalize(artifact.fetch('snapshot')), 'artifact final world differs from Ruby runtime referee')
end

self_hosting = JSON.parse(File.read(File.join(ROOT, 'spec/self_hosting/BASIC_SHARP_SELF_HOSTING_SUBSET_v1.json'), encoding: 'UTF-8'))
assert_contract!(self_hosting.fetch('approved_profiles_available_to_creator_programs').length == 7, 'Profiles 1-7 surface changed')
assert_contract!(!JSON.generate(self_hosting.fetch('approved_profiles_available_to_creator_programs')).include?('v8'), 'Profile 8 appeared')

puts "BASIC# Small Compiler Subset Independent Compiler Driver v#{BasicSharp::VERSION}"
puts 'Independent driver accepts BASIC# source files: PASS'
puts 'Independent driver invokes SmallCompilerSubsetPipeline: PASS'
puts 'Production compiler and runtime constructors disabled on primary path: PASS'
puts 'Real BSBC artifact produced: PASS'
puts 'Independent BSBC artifact equals independent in-memory bytes: PASS'
puts 'Saved BSBC reloads through independent loader: PASS'
puts 'Saved BSBC executes through independent BSharp VM: PASS'
puts 'Production compiler components used only as separate referees: PASS'
puts 'Ruby runtime used only as separate referee: PASS'
puts 'Exact event-result and final-world parity: PASS'
puts 'Profiles 1-7 remain unchanged: PASS'
puts 'SMALL COMPILER SUBSET INDEPENDENT COMPILER DRIVER: PASS'
