#!/usr/bin/env ruby
# frozen_string_literal: true

require 'digest'
require 'fileutils'
require 'json'
require 'tmpdir'
require_relative '../compiler/small_compiler_subset_native_dispatch'
require_relative '../compiler/small_compiler_subset_parser'
require_relative '../compiler/small_compiler_subset_driver'
require_relative '../compiler/lexer'
require_relative '../compiler/parser'
require_relative '../compiler/resolver'
require_relative '../compiler/bytecode_emitter'
require_relative '../compiler/bytecode_loader'
require_relative '../compiler/bytecode_virtual_machine'
require_relative '../compiler/runtime'

ROOT = File.expand_path('..', __dir__)
SPEC_PATH = File.join(ROOT, 'spec/self_hosting/BASIC_SHARP_NATIVE_PARSER_DISPATCH_INTEGRATION_v1.json')
spec = JSON.parse(File.read(SPEC_PATH, encoding: 'UTF-8'))
component = spec.fetch('native_component')
CURRENT_ARTIFACT = File.join(ROOT, component.fetch('artifact_path'))
CURRENT_DISASSEMBLY = File.join(ROOT, component.fetch('disassembly_path'))
NATIVE_SOURCE = File.join(ROOT, component.fetch('source_path'))
BOOTSTRAP_ARTIFACT = ARGV[0] ? File.expand_path(ARGV[0]) : CURRENT_ARTIFACT

def assert_dispatch!(condition, message)
  raise "Native parser dispatch integration failed: #{message}" unless condition
end

def classification_from(machine)
  object = machine.snapshot.find { |entry| entry.fetch('name') == 'compiler decision' }
  raise 'Native parser dispatch integration failed: compiler decision object missing' unless object

  object.fetch('values').fetch('classification')
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

assert_dispatch!(spec.fetch('format') == 'bsharp.native_parser_dispatch_integration.contract.json', 'wrong spec identity')
assert_dispatch!(spec.fetch('format_version') == 1, 'wrong spec format version')
assert_dispatch!(spec.fetch('target_version') == BasicSharp::VERSION, 'target version mismatch')
assert_dispatch!(File.file?(BOOTSTRAP_ARTIFACT), 'bootstrap native artifact is missing')
assert_dispatch!(File.file?(CURRENT_ARTIFACT), 'current native artifact is missing')
assert_dispatch!(Digest::SHA256.file(CURRENT_ARTIFACT).hexdigest == component.fetch('expected_binary_sha256'), 'current native artifact digest changed')
assert_dispatch!(Digest::SHA256.file(CURRENT_DISASSEMBLY).hexdigest == component.fetch('expected_disassembly_sha256'), 'current native disassembly digest changed')

dispatcher = BasicSharp::SmallCompilerSubsetNativeDispatch.new(artifact_path: CURRENT_ARTIFACT)
decisions = {}
component.fetch('expected_heads').each do |head|
  result = dispatcher.dispatch(head)
  assert_dispatch!(!result.nil?, "native artifact rejected accepted head #{head}")
  decisions[head.downcase] = result.decision
end
assert_dispatch!(decisions == component.fetch('expected_decisions'), 'native dispatch decision table changed')
assert_dispatch!(dispatcher.invocation_count == 9, 'native dispatch invocation count did not observe all nine accepted heads')

all_heads_source = <<~BASIC
  KINDS
  [
  ].
  DEFINE
  [
  ].
  START
  [
  ].
  WHEN PLAYER waits
  [
  ].
  IF PLAYER is ready
  [
  ].
  OTHERWISE
  [
  ].
  CONTROLS for PLAYER
  [
  ].
  HOVER for PLAYER
  [
  ].
  CONTEXT for PLAYER
  [
  ].
BASIC

classes = [
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
    alias_name = "__v081_native_dispatch_original_new_#{index}".to_sym
    singleton.class_eval do
      alias_method alias_name, :new
      define_method(:new) { |*| raise "production constructor invoked: #{klass}" }
    end
    aliases << [singleton, alias_name]
  end

  parser = BasicSharp::SmallCompilerSubsetParser.new(all_heads_source)
  assert_dispatch!(parser.statements.length == 9, 'primary parser did not parse all nine accepted heads')
  assert_dispatch!(parser.native_dispatcher.invocation_count == 9, 'primary parser did not invoke native dispatch exactly nine times')
ensure
  aliases.reverse_each do |singleton, alias_name|
    singleton.class_eval do
      alias_method :new, alias_name
      remove_method alias_name
    end
  end
end

invalid = BasicSharp::SmallCompilerSubsetParser.new("LOOP\n[\n].\n")
assert_dispatch!(invalid.statements.empty?, 'invalid head was accepted')
assert_dispatch!(invalid.issues.any? { |issue| issue.message == 'expected a Head before the Body' }, 'invalid head did not fail visibly')

source = File.read(NATIVE_SOURCE, encoding: 'UTF-8')
Dir.mktmpdir('basic-sharp-v081-native-dispatch') do |directory|
  sabotage_source = source.sub('"parse-kind-section"', '"parse-event-rule"')
  assert_dispatch!(sabotage_source != source, 'sabotage source did not change')
  sabotage_artifact = File.join(directory, 'wrong_dispatch.bsbc')
  BasicSharp::SmallCompilerSubsetDriver.new(sabotage_source, source_label: '(native dispatch sabotage)').compile_to(sabotage_artifact)
  bad_dispatcher = BasicSharp::SmallCompilerSubsetNativeDispatch.new(artifact_path: sabotage_artifact)
  sabotaged_parser = BasicSharp::SmallCompilerSubsetParser.new("KINDS\n[\n].\n", native_dispatcher: bad_dispatcher)
  assert_dispatch!(sabotaged_parser.statements.empty?, 'wrong native decision silently fell back to Ruby dispatch')
  assert_dispatch!(sabotaged_parser.issues.any? { |issue| issue.message == 'expected a Head before the Body' }, 'wrong native decision did not fail visibly')

  generation_1 = File.join(directory, 'generation_1.bsbc')
  generation_2 = File.join(directory, 'generation_2.bsbc')

  BasicSharp::SmallCompilerSubsetNativeDispatch.with_artifact_path(BOOTSTRAP_ARTIFACT) do
    BasicSharp::SmallCompilerSubsetDriver.new(source, source_label: '(v0.1.81 bootstrap generation 1)').compile_to(generation_1)
  end
  BasicSharp::SmallCompilerSubsetNativeDispatch.with_artifact_path(generation_1) do
    BasicSharp::SmallCompilerSubsetDriver.new(source, source_label: '(v0.1.81 bootstrap generation 2)').compile_to(generation_2)
  end

  assert_dispatch!(File.binread(generation_1) == File.binread(generation_2), 'bootstrap generation #2 differs from generation #1')
  assert_dispatch!(File.binread("#{generation_1}.txt") == File.binread("#{generation_2}.txt"), 'bootstrap disassembly generation #2 differs from generation #1')
  assert_dispatch!(File.binread(generation_2) == File.binread(CURRENT_ARTIFACT), 'checked-in native artifact differs from fixed point')
  assert_dispatch!(File.binread("#{generation_2}.txt") == File.binread(CURRENT_DISASSEMBLY), 'checked-in native disassembly differs from fixed point')
end

# Separate referees after the primary proof.
production_parser = BasicSharp::Parser.new(all_heads_source)
subset_parser = BasicSharp::SmallCompilerSubsetParser.new(all_heads_source)
assert_dispatch!(subset_parser.ruby_referee_statements == production_parser.parse.statements.map { |statement| subset_parser.send(:statement_to_subset_hash, statement) }, 'production Parser referee parity changed')

native_source_parser = BasicSharp::Parser.new(source)
document = BasicSharp::SemanticResolver.new(native_source_parser.parse, dictionary: native_source_parser.dictionary).resolve.to_h
emitter = BasicSharp::BytecodeEmitter.new(document)
assert_dispatch!(emitter.binary == File.binread(CURRENT_ARTIFACT), 'production BytecodeEmitter referee differs from native artifact')

component.fetch('expected_heads').each do |head|
  event = "player examines #{head.downcase} head"
  native_loader = BasicSharp::SmallCompilerSubsetBSBCLoader.read(CURRENT_ARTIFACT)
  native_vm = BasicSharp::SmallCompilerSubsetBSBCVirtualMachine.new(native_loader)
  native_result = native_vm.run_event(event)
  native_decision = classification_from(native_vm)

  prod_loader = BasicSharp::BytecodeLoader.new(emitter.binary, expected_fingerprint: emitter.fingerprint)
  prod_vm = BasicSharp::BytecodeVirtualMachine.new(prod_loader)
  prod_result = prod_vm.run_event(event)
  prod_decision = classification_from(prod_vm)

  ruby_runtime = BasicSharp::Runtime.new(document)
  ruby_result = ruby_runtime.run_event(event)
  ruby_decision = classification_from(ruby_runtime)

  assert_dispatch!(native_decision == component.fetch('expected_decisions').fetch(head.downcase), "native decision changed for #{head}")
  assert_dispatch!(prod_decision == native_decision, "production VM decision differs for #{head}")
  assert_dispatch!(ruby_decision == native_decision, "Ruby Runtime decision differs for #{head}")
  assert_dispatch!(BasicSharp::SmallCompilerSubsetPipeline.normalize(prod_result) == BasicSharp::SmallCompilerSubsetPipeline.normalize(native_result), "production VM result differs for #{head}")
  assert_dispatch!(semantic(ruby_result) == semantic(native_result), "Ruby Runtime semantics differ for #{head}")
end

puts "BASIC# Native Parser Dispatch Integration v#{BasicSharp::VERSION}"
puts 'BASIC# native dispatch artifact loaded: PASS'
puts 'Parser requests dispatch decision from native artifact: PASS'
puts 'All 9 accepted heads dispatched correctly: PASS'
puts 'Native dispatch invocation count observed: PASS (9)'
puts 'Parser cannot silently bypass native dispatch: PASS'
puts 'Invalid/unmatched head rejected: PASS'
puts 'Wrong-dispatch sabotage rejected without Ruby fallback: PASS'
puts 'Production Parser unavailable on primary path: PASS'
puts 'Production compiler constructors unavailable on primary path: PASS'
puts 'Ruby Runtime unavailable on primary path: PASS'
puts 'Independent source -> BSBC compilation: PASS'
puts 'Independent BSBC execution: PASS'
puts 'Bootstrap fixed point: PASS (generation #1 == generation #2)'
puts 'Production referee parity: PASS'
puts 'Ruby referee parity: PASS'
puts 'NATIVE PARSER DISPATCH INTEGRATION: PASS'
