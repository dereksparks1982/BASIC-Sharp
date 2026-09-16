# frozen_string_literal: true

require 'digest'
require 'json'
require 'minitest/autorun'
require 'tmpdir'
require_relative '../compiler/small_compiler_subset_ir_emitter'
require_relative '../compiler/small_compiler_subset_driver'
require_relative '../compiler/small_compiler_subset_native_semantic_routing'
require_relative '../compiler/parser'
require_relative '../compiler/resolver'

class TestNativeSemanticRoutingIntegration < Minitest::Test
  ROOT = File.expand_path('..', __dir__)
  SPEC = JSON.parse(File.read(File.join(ROOT, 'spec/self_hosting/BASIC_SHARP_NATIVE_SEMANTIC_ROUTING_INTEGRATION_v1.json'), encoding: 'UTF-8'))
  COMPONENT = SPEC.fetch('native_component')
  SOURCE_PATH = File.join(ROOT, COMPONENT.fetch('source_path'))
  ARTIFACT_PATH = File.join(ROOT, COMPONENT.fetch('artifact_path'))
  DISASSEMBLY_PATH = File.join(ROOT, COMPONENT.fetch('disassembly_path'))
  TRIAL_SOURCE = File.read(File.join(ROOT, 'samples/trial_by_fire.bsharp'), encoding: 'UTF-8')

  def representative_entries
    emitter = BasicSharp::SmallCompilerSubsetIREmitter.new(TRIAL_SOURCE)
    program = emitter.program
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

  def test_contract_and_checked_in_artifact
    assert_equal 'bsharp.native_semantic_routing_integration.contract.json', SPEC.fetch('format')
    assert_equal BasicSharp::VERSION, SPEC.fetch('target_version')
    assert_equal COMPONENT.fetch('expected_binary_sha256'), Digest::SHA256.file(ARTIFACT_PATH).hexdigest
    assert_equal COMPONENT.fetch('expected_disassembly_sha256'), Digest::SHA256.file(DISASSEMBLY_PATH).hexdigest
  end

  def test_all_eight_semantic_families_are_native_routed
    router = BasicSharp::SmallCompilerSubsetNativeSemanticRouting.new
    decisions = representative_entries.to_h do |entry|
      result = router.route(entry)
      [result.semantic_name, result.decision]
    end

    assert_equal COMPONENT.fetch('expected_decisions'), decisions
    assert_equal 8, router.invocation_count
    assert_equal 8, router.matched_count
  end

  def test_primary_pipeline_observes_native_parser_and_semantic_routing
    driver = BasicSharp::SmallCompilerSubsetDriver.new(TRIAL_SOURCE)
    assert_operator driver.native_dispatch_invocation_count, :>, 0
    expected_semantic_calls = driver.pipeline.ir_emitter.program.then do |program|
      program.kind_definitions.length + program.definitions.length + program.facts.length +
        program.event_rules.length + program.if_rules.length + program.controls.length +
        program.hover_declarations.length + program.context_declarations.length
    end
    assert_equal expected_semantic_calls, driver.native_semantic_invocation_count
    assert_equal driver.pipeline.bsharp_ir, driver.pipeline.ir_emitter.ruby_referee_bsharp_ir
  end

  def test_wrong_native_route_fails_closed
    source = File.read(SOURCE_PATH, encoding: 'UTF-8')
    sabotage = source.sub('"resolve-event-rule"', '"resolve-starting-fact"')
    refute_equal source, sabotage

    Dir.mktmpdir('basic-sharp-v082-semantic-sabotage') do |directory|
      artifact = File.join(directory, 'wrong_semantic_route.bsbc')
      BasicSharp::SmallCompilerSubsetDriver.new(sabotage).compile_to(artifact)
      bad_router = BasicSharp::SmallCompilerSubsetNativeSemanticRouting.new(artifact_path: artifact)
      emitter = BasicSharp::SmallCompilerSubsetIREmitter.new(TRIAL_SOURCE)
      resolver = BasicSharp::SmallCompilerSubsetSemanticResolver.new(
        emitter.program,
        dictionary: emitter.dictionary,
        native_semantic_router: bad_router
      )
      error = assert_raises(BasicSharp::SmallCompilerSubsetNativeSemanticRoutingError) { resolver.resolve }
      assert_includes error.message, 'that route requires Fact'
    end
  end

  def test_unknown_native_route_fails_closed
    source = File.read(SOURCE_PATH, encoding: 'UTF-8')
    sabotage = source.sub('"resolve-event-rule"', '"resolve-unknown-semantic-route"')

    Dir.mktmpdir('basic-sharp-v082-semantic-unknown') do |directory|
      artifact = File.join(directory, 'unknown_semantic_route.bsbc')
      BasicSharp::SmallCompilerSubsetDriver.new(sabotage).compile_to(artifact)
      bad_router = BasicSharp::SmallCompilerSubsetNativeSemanticRouting.new(artifact_path: artifact)
      emitter = BasicSharp::SmallCompilerSubsetIREmitter.new(TRIAL_SOURCE)
      resolver = BasicSharp::SmallCompilerSubsetSemanticResolver.new(
        emitter.program,
        dictionary: emitter.dictionary,
        native_semantic_router: bad_router
      )
      error = assert_raises(BasicSharp::SmallCompilerSubsetNativeSemanticRoutingError) { resolver.resolve }
      assert_includes error.message, 'unknown decision'
    end
  end

  def test_generation_two_is_byte_identical_fixed_point
    source = File.read(SOURCE_PATH, encoding: 'UTF-8')
    Dir.mktmpdir('basic-sharp-v082-semantic-fixed-point') do |directory|
      generation_2 = File.join(directory, 'generation_2.bsbc')
      BasicSharp::SmallCompilerSubsetNativeSemanticRouting.with_artifact_path(ARTIFACT_PATH) do
        BasicSharp::SmallCompilerSubsetDriver.new(source, source_label: '(v0.1.84 semantic generation 2)').compile_to(generation_2)
      end
      assert_equal File.binread(ARTIFACT_PATH), File.binread(generation_2)
      assert_equal File.binread(DISASSEMBLY_PATH), File.binread("#{generation_2}.txt")
    end
  end

  def test_production_semantic_resolver_is_referee_only
    emitter = BasicSharp::SmallCompilerSubsetIREmitter.new(TRIAL_SOURCE)
    independent = emitter.bsharp_ir

    parser = BasicSharp::Parser.new(TRIAL_SOURCE)
    production = BasicSharp::SemanticResolver.new(parser.parse, dictionary: parser.dictionary).resolve.to_h
    assert_equal production, independent
  end
end
