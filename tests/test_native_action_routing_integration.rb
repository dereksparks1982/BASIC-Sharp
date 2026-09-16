# frozen_string_literal: true

require 'digest'
require 'json'
require 'minitest/autorun'
require 'tmpdir'
require_relative '../compiler/ast_nodes'
require_relative '../compiler/small_compiler_subset_native_action_routing'
require_relative '../compiler/small_compiler_subset_driver'
require_relative '../compiler/small_compiler_subset_ir_emitter'

class TestNativeActionRoutingIntegration < Minitest::Test
  ROOT = File.expand_path('..', __dir__)
  SPEC = JSON.parse(File.read(File.join(ROOT, 'spec/self_hosting/BASIC_SHARP_NATIVE_ACTION_ROUTING_INTEGRATION_v1.json'), encoding: 'UTF-8'))
  COMPONENT = SPEC.fetch('native_component')
  ARTIFACT_PATH = File.join(ROOT, COMPONENT.fetch('artifact_path'))
  SOURCE_PATH = File.join(ROOT, COMPONENT.fetch('source_path'))

  def action(verb)
    BasicSharp::ActionCall.new(verb: verb, target: 'PLAYER', tail: '', text_literal: nil, line_number: 1)
  end

  def test_contract_and_artifact
    assert_equal '0.1.84', BasicSharp::VERSION
    assert_equal BasicSharp::VERSION, SPEC.fetch('target_version')
    assert_equal COMPONENT.fetch('expected_binary_sha256'), Digest::SHA256.file(ARTIFACT_PATH).hexdigest
  end

  def test_every_accepted_action_word_is_routed_natively
    router = BasicSharp::SmallCompilerSubsetNativeActionRouting.new
    SPEC.fetch('expected_routes').each do |verb, expected|
      route = router.route(action(verb))
      refute_nil route, verb
      assert_equal expected, route.decision, verb
    end
    assert_equal SPEC.fetch('expected_routes').length, router.invocation_count
  end

  def test_unknown_action_is_rejected_by_native_artifact
    router = BasicSharp::SmallCompilerSubsetNativeActionRouting.new
    assert_nil router.route(action('not-a-real-action'))
    assert_equal 1, router.rejected_count
  end

  def test_wrong_family_sabotage_fails_closed
    source = File.read(SOURCE_PATH, encoding: 'UTF-8')
    wrong_source = source.sub('"resolve-damage-action"', '"resolve-object-interaction-action"')
    Dir.mktmpdir('basic-sharp-v084-wrong-action') do |directory|
      wrong_artifact = File.join(directory, 'wrong.bsbc')
      BasicSharp::SmallCompilerSubsetNativeActionRouting.with_artifact_path(ARTIFACT_PATH) do
        BasicSharp::SmallCompilerSubsetDriver.new(wrong_source).compile_to(wrong_artifact)
      end
      router = BasicSharp::SmallCompilerSubsetNativeActionRouting.new(artifact_path: wrong_artifact)
      src = <<~BSHARP
        DEFINE
        [
            @bell is a #device
        ].
        WHEN PLAYER examines @bell
        [
            |then (damage PLAYER
        ].
      BSHARP
      emitter = BasicSharp::SmallCompilerSubsetIREmitter.new(src)
      resolver = BasicSharp::SmallCompilerSubsetSemanticResolver.new(
        emitter.program,
        dictionary: emitter.dictionary,
        native_action_router: router
      )
      error = assert_raises(BasicSharp::SmallCompilerSubsetNativeActionRoutingError) { resolver.resolve }
      assert_includes error.message, 'does not accept it'
    end
  end

  def test_primary_pipeline_observes_action_routing_and_upstream_native_stages
    source = <<~BSHARP
      DEFINE
      [
          @door is a #door
      ].
      WHEN PLAYER examines @door
      [
          |then (open @door
          |then (damage PLAYER
      ].
    BSHARP
    driver = BasicSharp::SmallCompilerSubsetDriver.new(source)
    driver.pipeline.bsharp_ir
    assert_operator driver.native_dispatch_invocation_count, :>, 0
    assert_operator driver.native_semantic_invocation_count, :>, 0
    assert_operator driver.native_symbol_invocation_count, :>, 0
    assert_equal 2, driver.native_action_invocation_count
  end
end
