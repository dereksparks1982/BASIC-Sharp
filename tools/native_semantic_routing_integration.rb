#!/usr/bin/env ruby
# frozen_string_literal: true

require 'digest'
require 'json'
require 'tmpdir'
require_relative '../compiler/small_compiler_subset_ir_emitter'
require_relative '../compiler/small_compiler_subset_driver'
require_relative '../compiler/small_compiler_subset_native_semantic_routing'
require_relative '../compiler/parser'
require_relative '../compiler/resolver'
require_relative '../compiler/bytecode_emitter'
require_relative '../compiler/bytecode_loader'
require_relative '../compiler/bytecode_virtual_machine'
require_relative '../compiler/runtime'

ROOT = File.expand_path('..', __dir__)
SPEC = JSON.parse(File.read(File.join(ROOT, 'spec/self_hosting/BASIC_SHARP_NATIVE_SEMANTIC_ROUTING_INTEGRATION_v1.json'), encoding: 'UTF-8'))
COMPONENT = SPEC.fetch('native_component')
SOURCE_PATH = File.join(ROOT, COMPONENT.fetch('source_path'))
ARTIFACT_PATH = File.join(ROOT, COMPONENT.fetch('artifact_path'))
DISASSEMBLY_PATH = File.join(ROOT, COMPONENT.fetch('disassembly_path'))
TRIAL_SOURCE = File.read(File.join(ROOT, 'samples/trial_by_fire.bsharp'), encoding: 'UTF-8')

def assert_route!(condition, message)
  raise "Native semantic routing integration failed: #{message}" unless condition
end

def semantic_entries(program)
  [
    program.kind_definitions.first,
    program.definitions.first,
    program.facts.first,
    program.event_rules.first,
    program.if_rules.first,
    program.controls.first,
    program.hover_declarations.first,
    program.context_declarations.first
  ]
end

assert_route!(SPEC.fetch('format') == 'bsharp.native_semantic_routing_integration.contract.json', 'wrong spec identity')
assert_route!(SPEC.fetch('target_version') == BasicSharp::VERSION, 'target version mismatch')
assert_route!(Digest::SHA256.file(ARTIFACT_PATH).hexdigest == COMPONENT.fetch('expected_binary_sha256'), 'native semantic artifact digest changed')
assert_route!(Digest::SHA256.file(DISASSEMBLY_PATH).hexdigest == COMPONENT.fetch('expected_disassembly_sha256'), 'native semantic disassembly digest changed')

probe_emitter = BasicSharp::SmallCompilerSubsetIREmitter.new(TRIAL_SOURCE)
router = BasicSharp::SmallCompilerSubsetNativeSemanticRouting.new
decisions = semantic_entries(probe_emitter.program).to_h do |entry|
  result = router.route(entry)
  assert_route!(!result.nil?, "native artifact rejected #{entry.class}")
  [result.semantic_name, result.decision]
end
assert_route!(decisions == COMPONENT.fetch('expected_decisions'), 'semantic routing decision table changed')
assert_route!(router.invocation_count == 8, 'representative semantic invocation count is not eight')

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
    alias_name = "__v082_native_semantic_original_new_#{index}".to_sym
    singleton.class_eval do
      alias_method alias_name, :new
      define_method(:new) { |*| raise "production constructor invoked: #{klass}" }
    end
    aliases << [singleton, alias_name]
  end

  driver = BasicSharp::SmallCompilerSubsetDriver.new(TRIAL_SOURCE)
  expected_calls = driver.pipeline.ir_emitter.program.then do |program|
    program.kind_definitions.length + program.definitions.length + program.facts.length +
      program.event_rules.length + program.if_rules.length + program.controls.length +
      program.hover_declarations.length + program.context_declarations.length
  end
  assert_route!(driver.native_dispatch_invocation_count.positive?, 'v0.0.81 native parser dispatch is not active')
  assert_route!(driver.native_semantic_invocation_count == expected_calls, 'primary path did not route every semantic entry natively')
  assert_route!(!driver.pipeline.binary.empty?, 'independent source -> BSBC produced no bytes')
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
Dir.mktmpdir('basic-sharp-v082-native-semantic') do |directory|
  wrong_source = source.sub('"resolve-event-rule"', '"resolve-starting-fact"')
  wrong_artifact = File.join(directory, 'wrong_route.bsbc')
  BasicSharp::SmallCompilerSubsetDriver.new(wrong_source).compile_to(wrong_artifact)
  emitter = BasicSharp::SmallCompilerSubsetIREmitter.new(TRIAL_SOURCE)
  resolver = BasicSharp::SmallCompilerSubsetSemanticResolver.new(
    emitter.program,
    dictionary: emitter.dictionary,
    native_semantic_router: BasicSharp::SmallCompilerSubsetNativeSemanticRouting.new(artifact_path: wrong_artifact)
  )
  begin
    resolver.resolve
    raise 'Native semantic routing integration failed: wrong route silently fell back to Ruby'
  rescue BasicSharp::SmallCompilerSubsetNativeSemanticRoutingError => error
    assert_route!(error.message.include?('that route requires Fact'), 'wrong-route sabotage did not fail at route-shape boundary')
  end

  unknown_source = source.sub('"resolve-event-rule"', '"resolve-unknown-semantic-route"')
  unknown_artifact = File.join(directory, 'unknown_route.bsbc')
  BasicSharp::SmallCompilerSubsetDriver.new(unknown_source).compile_to(unknown_artifact)
  emitter = BasicSharp::SmallCompilerSubsetIREmitter.new(TRIAL_SOURCE)
  resolver = BasicSharp::SmallCompilerSubsetSemanticResolver.new(
    emitter.program,
    dictionary: emitter.dictionary,
    native_semantic_router: BasicSharp::SmallCompilerSubsetNativeSemanticRouting.new(artifact_path: unknown_artifact)
  )
  begin
    resolver.resolve
    raise 'Native semantic routing integration failed: unknown route silently fell back to Ruby'
  rescue BasicSharp::SmallCompilerSubsetNativeSemanticRoutingError => error
    assert_route!(error.message.include?('unknown decision'), 'unknown native route did not fail visibly')
  end

  generation_2 = File.join(directory, 'generation_2.bsbc')
  BasicSharp::SmallCompilerSubsetNativeSemanticRouting.with_artifact_path(ARTIFACT_PATH) do
    BasicSharp::SmallCompilerSubsetDriver.new(source, source_label: '(v0.0.82 semantic generation 2)').compile_to(generation_2)
  end
  assert_route!(File.binread(generation_2) == File.binread(ARTIFACT_PATH), 'bootstrap generation #2 differs from generation #1')
  assert_route!(File.binread("#{generation_2}.txt") == File.binread(DISASSEMBLY_PATH), 'bootstrap disassembly generation #2 differs from generation #1')
end

# Separate referees only after primary-path proof.
independent = BasicSharp::SmallCompilerSubsetIREmitter.new(TRIAL_SOURCE).bsharp_ir
parser = BasicSharp::Parser.new(TRIAL_SOURCE)
production = BasicSharp::SemanticResolver.new(parser.parse, dictionary: parser.dictionary).resolve.to_h
assert_route!(production == independent, 'production semantic referee differs')

puts "BASIC# Native Semantic Routing Integration v#{BasicSharp::VERSION}"
puts 'BASIC# semantic artifact loaded: PASS'
puts 'Semantic resolver requests native decisions: PASS'
puts 'All 8 accepted semantic families routed correctly: PASS'
puts 'Native semantic invocation count observed: PASS'
puts 'No hidden Ruby routing fallback: PASS'
puts 'Unknown semantic route rejected: PASS'
puts 'Wrong-route sabotage rejected without Ruby fallback: PASS'
puts 'v0.0.81 native parser dispatch remains active: PASS'
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
puts 'NATIVE SEMANTIC ROUTING INTEGRATION: PASS'
