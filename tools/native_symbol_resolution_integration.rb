#!/usr/bin/env ruby
# frozen_string_literal: true

require 'digest'
require 'json'
require 'tmpdir'
require_relative '../compiler/small_compiler_subset_driver'
require_relative '../compiler/small_compiler_subset_ir_emitter'
require_relative '../compiler/small_compiler_subset_native_symbol_resolution'
require_relative '../compiler/parser'
require_relative '../compiler/resolver'
require_relative '../compiler/bytecode_emitter'
require_relative '../compiler/bytecode_loader'
require_relative '../compiler/bytecode_virtual_machine'
require_relative '../compiler/runtime'

ROOT = File.expand_path('..', __dir__)
SPEC = JSON.parse(File.read(File.join(ROOT, 'spec/self_hosting/BASIC_SHARP_NATIVE_SYMBOL_RESOLUTION_INTEGRATION_v1.json'), encoding: 'UTF-8'))
COMPONENT = SPEC.fetch('native_component')
SOURCE_PATH = File.join(ROOT, COMPONENT.fetch('source_path'))
ARTIFACT_PATH = File.join(ROOT, COMPONENT.fetch('artifact_path'))
DISASSEMBLY_PATH = File.join(ROOT, COMPONENT.fetch('disassembly_path'))
TRIAL_SOURCE = File.read(File.join(ROOT, 'samples/trial_by_fire.bsharp'), encoding: 'UTF-8')

def assert_symbol!(condition, message)
  raise "Native symbol resolution integration failed: #{message}" unless condition
end

assert_symbol!(SPEC.fetch('format') == 'bsharp.native_symbol_resolution_integration.contract.json', 'wrong spec identity')
assert_symbol!(SPEC.fetch('target_version') == BasicSharp::VERSION, 'target version mismatch')
assert_symbol!(Digest::SHA256.file(ARTIFACT_PATH).hexdigest == COMPONENT.fetch('expected_binary_sha256'), 'native symbol artifact digest changed')
assert_symbol!(Digest::SHA256.file(DISASSEMBLY_PATH).hexdigest == COMPONENT.fetch('expected_disassembly_sha256'), 'native symbol disassembly digest changed')

resolver = BasicSharp::SmallCompilerSubsetNativeSymbolResolution.new
decisions = BasicSharp::SmallCompilerSubsetNativeSymbolResolution::PROBES.keys.to_h do |probe|
  [probe.to_s, resolver.decide(probe).decision]
end
assert_symbol!(decisions == COMPONENT.fetch('expected_decisions'), 'native symbol decision protocol changed')
assert_symbol!(resolver.invocation_count == 15, 'representative symbol decision count is not fifteen')

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
    alias_name = "__v083_native_symbol_original_new_#{index}".to_sym
    singleton.class_eval do
      alias_method alias_name, :new
      define_method(:new) { |*| raise "production constructor invoked: #{klass}" }
    end
    aliases << [singleton, alias_name]
  end

  driver = BasicSharp::SmallCompilerSubsetDriver.new(TRIAL_SOURCE)
  assert_symbol!(driver.native_dispatch_invocation_count.positive?, 'v0.1.81 native parser dispatch is not active')
  assert_symbol!(driver.native_semantic_invocation_count.positive?, 'v0.1.82 native semantic routing is not active')
  assert_symbol!(driver.native_symbol_invocation_count.positive?, 'native symbol decisions were not observed')
  assert_symbol!(!driver.pipeline.binary.empty?, 'independent source -> BSBC produced no bytes')
  driver.execute_in_memory(['player sounds brass bell'])
ensure
  aliases.reverse_each do |singleton, alias_name|
    singleton.class_eval do
      alias_method :new, alias_name
      remove_method alias_name
    end
  end
end

source = File.read(SOURCE_PATH, encoding: 'UTF-8')
Dir.mktmpdir('basic-sharp-v083-native-symbol') do |directory|
  sabotage_cases = [
    ['known Kind', '"resolve-known-kind"', '"reject-unknown-kind"', TRIAL_SOURCE],
    ['unknown Thing', '"reject-unknown-thing"', '"resolve-known-thing"', "KINDS\n[\n#thing\n#door is a #thing\n].\nWHEN PLAYER opens @ghost\n[\n|then (sound bell\n].\n"],
    ['duplicate Thing', '"reject-duplicate-thing"', '"accept-unique-thing"', "KINDS\n[\n#thing\n#door is a #thing\n].\nDEFINE\n[\n@north door is a #door\n@north door is a #door\n].\n"],
    ['Kind link', '"reject-kind-link"', '"accept-kind-link"', "KINDS\n[\n#thing\n#spirit door is a #ghost\n].\n"]
  ]

  sabotage_cases.each_with_index do |(label, from, to, candidate), index|
    sabotaged_source = source.sub(from, to)
    assert_symbol!(sabotaged_source != source, "#{label} sabotage did not modify source")
    artifact = File.join(directory, "sabotage_#{index}.bsbc")
    BasicSharp::SmallCompilerSubsetDriver.new(sabotaged_source).compile_to(artifact)
    begin
      BasicSharp::SmallCompilerSubsetNativeSymbolResolution.with_artifact_path(artifact) do
        BasicSharp::SmallCompilerSubsetDriver.new(candidate).pipeline.bsharp_ir
      end
      raise "Native symbol resolution integration failed: #{label} sabotage silently continued"
    rescue BasicSharp::SmallCompilerSubsetNativeSymbolResolutionError => error
      assert_symbol!(error.message.include?('expected'), "#{label} sabotage did not fail at native decision boundary")
    end
  end

  generation_2 = File.join(directory, 'generation_2.bsbc')
  BasicSharp::SmallCompilerSubsetNativeSymbolResolution.with_artifact_path(ARTIFACT_PATH) do
    BasicSharp::SmallCompilerSubsetDriver.new(source, source_label: '(v0.1.84 symbol generation 2)').compile_to(generation_2)
  end
  assert_symbol!(File.binread(generation_2) == File.binread(ARTIFACT_PATH), 'bootstrap generation #2 differs from generation #1')
  assert_symbol!(File.binread("#{generation_2}.txt") == File.binread(DISASSEMBLY_PATH), 'bootstrap disassembly generation #2 differs from generation #1')
end

begin
  BasicSharp::SmallCompilerSubsetNativeSymbolResolution.new.decide(:not_a_symbol_probe)
  raise 'Native symbol resolution integration failed: unknown probe silently continued'
rescue BasicSharp::SmallCompilerSubsetNativeSymbolResolutionError
  # Required fail-closed behavior.
end

independent = BasicSharp::SmallCompilerSubsetIREmitter.new(TRIAL_SOURCE).bsharp_ir
parser = BasicSharp::Parser.new(TRIAL_SOURCE)
production = BasicSharp::SemanticResolver.new(parser.parse, dictionary: parser.dictionary).resolve.to_h
assert_symbol!(production == independent, 'production semantic referee differs')

puts "BASIC# Native Symbol Resolution Integration v#{BasicSharp::VERSION}"
puts 'BASIC# native symbol artifact loaded: PASS'
puts 'Symbol resolution requests native decisions: PASS'
puts 'Kind identities resolved: PASS'
puts 'Thing identities resolved: PASS'
puts 'Thing -> Kind links resolved: PASS'
puts 'Builtin PLAYER resolved: PASS'
puts 'Value identities resolved: PASS'
puts 'Action identities resolved: PASS'
puts 'Duplicate-symbol decisions observed: PASS'
puts 'Unknown-symbol decisions observed: PASS'
puts 'Native symbol invocation count observed: PASS'
puts 'No hidden Ruby symbol fallback: PASS'
puts 'Wrong-known-symbol sabotage rejected: PASS'
puts 'Wrong-unknown-symbol sabotage rejected: PASS'
puts 'Wrong-duplicate-symbol sabotage rejected: PASS'
puts 'Wrong-Kind-link sabotage rejected: PASS'
puts 'v0.1.81 native parser dispatch remains active: PASS'
puts 'v0.1.82 native semantic routing remains active: PASS'
puts 'Production Parser unavailable on primary path: PASS'
puts 'Production SemanticResolver unavailable on primary path: PASS'
puts 'Production compiler constructors unavailable on primary path: PASS'
puts 'Ruby Runtime unavailable on primary path: PASS'
puts 'Independent source -> BSIR: PASS'
puts 'Independent source -> BSBC: PASS'
puts 'Independent BSBC execution: PASS'
puts 'Bootstrap fixed point: PASS (generation #1 == generation #2)'
puts 'Production referee parity: PASS'
puts 'Ruby referee parity: PASS'
puts 'NATIVE SYMBOL RESOLUTION INTEGRATION: PASS'
