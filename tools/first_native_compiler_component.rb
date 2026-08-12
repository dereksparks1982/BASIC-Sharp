#!/usr/bin/env ruby
# frozen_string_literal: true

require 'fileutils'
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
SPEC_PATH = File.join(ROOT, 'spec/self_hosting/BASIC_SHARP_FIRST_NATIVE_COMPILER_COMPONENT_v1.json')
spec = JSON.parse(File.read(SPEC_PATH, encoding: 'UTF-8'))
component = spec.fetch('component')

SOURCE_PATH = File.join(ROOT, component.fetch('source_path'))
ARTIFACT_PATH = File.join(ROOT, component.fetch('artifact_path'))
DISASSEMBLY_PATH = File.join(ROOT, component.fetch('disassembly_path'))


def assert_native!(condition, message)
  raise "First BASIC#-authored compiler component failed: #{message}" unless condition
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

def classification_from(machine, object_name, value_name)
  object = machine.snapshot.find { |entry| entry.fetch('name') == object_name }
  raise "Native compiler decision object is missing: #{object_name}" unless object

  object.fetch('values').fetch(value_name)
end

assert_native!(spec.fetch('format') == 'bsharp.first_native_compiler_component.contract.json', 'wrong spec identity')
assert_native!(spec.fetch('format_version') == 1, 'wrong format version')
assert_native!(spec.fetch('target_version') == BasicSharp::VERSION, 'target version mismatch')
assert_native!(spec.fetch('status') == 'first_bsharp_authored_compiler_component_under_ruby_referee', 'status changed')
assert_native!(File.extname(SOURCE_PATH) == '.bsharp', 'compiler component source is not BASIC# source')
assert_native!(File.file?(SOURCE_PATH), 'compiler component BASIC# source is missing')
assert_native!(File.file?(ARTIFACT_PATH), 'checked-in native BSBC artifact is missing')
assert_native!(File.file?(DISASSEMBLY_PATH), 'checked-in native BSBC disassembly is missing')

source = File.read(SOURCE_PATH, encoding: 'UTF-8')
assert_native!(source.include?('WHEN PLAYER examines @kinds head'), 'native compiler source no longer owns the KINDS decision')
assert_native!(source.include?('(change classification of @compiler decision'), 'native compiler source no longer writes compiler decisions')

expected_heads = component.fetch('input_heads')
expected_decisions = component.fetch('expected_decisions')
assert_native!(expected_heads.map(&:downcase).sort == expected_decisions.keys.sort, 'head/decision table coverage changed')

Dir.mktmpdir('basic-sharp-v080-native-component') do |directory|
  copied_source = File.join(directory, 'first_bsharp_compiler_component.bsharp')
  generated_artifact = File.join(directory, 'first_bsharp_compiler_component.bsbc')
  FileUtils.cp(SOURCE_PATH, copied_source)

  # Primary proof: the BASIC# component must compile and execute while every
  # production compiler/runtime constructor is disabled.
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
      alias_name = "__v080_native_component_original_new_#{index}".to_sym
      singleton.class_eval do
        alias_method alias_name, :new
        define_method(:new) { |*| raise "production constructor invoked: #{klass}" }
      end
      aliases << [singleton, alias_name]
    end

    driver = BasicSharp::SmallCompilerSubsetDriver.from_file(copied_source)
    driver.compile_to(generated_artifact)
    assert_native!(driver.pipeline.profile == component.fetch('profile'), 'native compiler component profile changed')
    assert_native!(driver.driver_record.fetch(:source_sha256) == component.fetch('expected_source_sha256'), 'native source digest changed')
    assert_native!(driver.driver_record.fetch(:bsharp_ir_sha256) == component.fetch('expected_bsharp_ir_sha256'), 'native BSharp IR digest changed')
    assert_native!(driver.driver_record.fetch(:binary_bytes) == component.fetch('expected_binary_bytes'), 'native BSBC byte count changed')
    assert_native!(driver.artifact_sha256 == component.fetch('expected_binary_sha256'), 'native BSBC digest changed')
    assert_native!(driver.driver_record.fetch(:disassembly_sha256) == component.fetch('expected_disassembly_sha256'), 'native disassembly digest changed')
    assert_native!(driver.driver_record.fetch(:fingerprint) == component.fetch('expected_fingerprint'), 'native fingerprint changed')
    assert_native!(File.binread(generated_artifact) == File.binread(ARTIFACT_PATH), 'generated native BSBC differs from checked-in native artifact')
    assert_native!(File.read("#{generated_artifact}.txt", encoding: 'UTF-8') == File.read(DISASSEMBLY_PATH, encoding: 'UTF-8'), 'generated native disassembly differs from checked-in disassembly')
  ensure
    aliases.reverse_each do |singleton, alias_name|
      singleton.class_eval do
        alias_method :new, alias_name
        remove_method alias_name
      end
    end
  end

  # Prove persisted native bytecode is enough. The temporary source copy is
  # removed before any classification below.
  File.delete(copied_source)
  assert_native!(!File.exist?(copied_source), 'temporary BASIC# compiler source copy was not removed')

  decisions = {}
  native_event_results = []
  expected_heads.each do |head|
    loader = BasicSharp::SmallCompilerSubsetBSBCLoader.read(generated_artifact)
    machine = BasicSharp::SmallCompilerSubsetBSBCVirtualMachine.new(loader)
    event = "player examines #{head.downcase} head"
    result = machine.run_event(event)
    assert_native!(result.fetch('matched'), "native compiler decision did not match #{head}")
    decisions[head.downcase] = classification_from(machine, component.fetch('decision_object'), component.fetch('decision_value'))
    native_event_results << result
  end
  assert_native!(decisions == expected_decisions, 'native compiler decisions changed')
  assert_native!(BasicSharp::SmallCompilerSubsetDriver.digest_json(decisions) == component.fetch('expected_decisions_sha256'), 'native decision digest changed')
  assert_native!(BasicSharp::SmallCompilerSubsetDriver.digest_json(native_event_results) == component.fetch('expected_event_results_sha256'), 'native event-result digest changed')

  # Recompile repeatedly to lock deterministic bytecode and disassembly.
  32.times do |index|
    path = File.join(directory, "repeat_#{index}.bsbc")
    BasicSharp::SmallCompilerSubsetDriver.new(source, source_label: '(native deterministic replay)').compile_to(path)
    assert_native!(File.binread(path) == File.binread(ARTIFACT_PATH), "native BSBC replay #{index} changed")
    assert_native!(File.read("#{path}.txt", encoding: 'UTF-8') == File.read(DISASSEMBLY_PATH, encoding: 'UTF-8'), "native disassembly replay #{index} changed")
  end
end

# Separate referees run only after the independent primary proof.
parser = BasicSharp::Parser.new(source)
document = BasicSharp::SemanticResolver.new(parser.parse, dictionary: parser.dictionary).resolve.to_h
production_emitter = BasicSharp::BytecodeEmitter.new(document)
assert_native!(production_emitter.binary == File.binread(ARTIFACT_PATH), 'native artifact differs from production BytecodeEmitter referee')
assert_native!(BasicSharp::Parser::BLOCK_HEADS == expected_heads, 'native compiler head table differs from production Parser referee')

expected_heads.each do |head|
  event = "player examines #{head.downcase} head"

  production_loader = BasicSharp::BytecodeLoader.new(production_emitter.binary, expected_fingerprint: production_emitter.fingerprint)
  production_vm = BasicSharp::BytecodeVirtualMachine.new(production_loader)
  production_result = production_vm.run_event(event)
  production_decision = classification_from(production_vm, component.fetch('decision_object'), component.fetch('decision_value'))

  ruby_runtime = BasicSharp::Runtime.new(document)
  ruby_result = ruby_runtime.run_event(event)
  ruby_decision = classification_from(ruby_runtime, component.fetch('decision_object'), component.fetch('decision_value'))

  native_loader = BasicSharp::SmallCompilerSubsetBSBCLoader.read(ARTIFACT_PATH)
  native_vm = BasicSharp::SmallCompilerSubsetBSBCVirtualMachine.new(native_loader)
  native_result = native_vm.run_event(event)
  native_decision = classification_from(native_vm, component.fetch('decision_object'), component.fetch('decision_value'))

  assert_native!(native_decision == expected_decisions.fetch(head.downcase), "native decision changed for #{head}")
  assert_native!(production_decision == native_decision, "production VM decision differs for #{head}")
  assert_native!(ruby_decision == native_decision, "Ruby Runtime decision differs for #{head}")
  assert_native!(normalize(production_result) == normalize(native_result), "production VM event result differs for #{head}")
  assert_native!(semantic(ruby_result) == semantic(native_result), "Ruby Runtime event semantics differ for #{head}")
end

self_hosting = JSON.parse(File.read(File.join(ROOT, 'spec/self_hosting/BASIC_SHARP_SELF_HOSTING_SUBSET_v1.json'), encoding: 'UTF-8'))
assert_native!(self_hosting.fetch('approved_profiles_available_to_creator_programs').length == 7, 'Profiles 1-7 surface changed')
assert_native!(!JSON.generate(self_hosting.fetch('approved_profiles_available_to_creator_programs')).include?('v8'), 'Profile 8 appeared')

puts "BASIC# First BASIC#-Authored Compiler Component v#{BasicSharp::VERSION}"
puts 'BASIC# compiler-component source exists: PASS'
puts 'Independent compiler driver compiles BASIC# component: PASS'
puts 'Real checked-in BSBC compiler artifact: PASS'
puts 'Production compiler/runtime constructors disabled on primary path: PASS'
puts 'Source-free native artifact execution: PASS'
puts 'Accepted compiler-head classification coverage: PASS (9 heads)'
puts 'Native compiler decisions correct: PASS'
puts 'Deterministic compilation: PASS (32 repetitions)'
puts 'Production BytecodeEmitter and BSharp VM referee parity: PASS'
puts 'Ruby Runtime referee parity: PASS'
puts 'Profiles 1-7 remain unchanged: PASS'
puts 'FIRST BASIC#-AUTHORED COMPILER COMPONENT: PASS'
