# frozen_string_literal: true

require 'json'
require 'minitest/autorun'
require 'tmpdir'
require_relative '../compiler/small_compiler_subset_native_dispatch'
require_relative '../compiler/small_compiler_subset_parser'
require_relative '../compiler/small_compiler_subset_driver'
require_relative '../compiler/parser'

class TestNativeParserDispatchIntegration < Minitest::Test
  ROOT = File.expand_path('..', __dir__)
  SPEC_PATH = File.join(ROOT, 'spec/self_hosting/BASIC_SHARP_NATIVE_PARSER_DISPATCH_INTEGRATION_v1.json')
  NATIVE_SOURCE = File.join(ROOT, 'compiler/native/first_bsharp_compiler_component.bsharp')

  def spec
    @spec ||= JSON.parse(File.read(SPEC_PATH, encoding: 'UTF-8'))
  end

  def component
    spec.fetch('native_component')
  end

  def dispatcher
    BasicSharp::SmallCompilerSubsetNativeDispatch.new(
      artifact_path: File.join(ROOT, component.fetch('artifact_path'))
    )
  end

  def all_heads_source
    <<~BASIC
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
  end

  def test_contract_identity_and_live_version
    assert_equal 'bsharp.native_parser_dispatch_integration.contract.json', spec.fetch('format')
    assert_equal 1, spec.fetch('format_version')
    assert_equal '0.0.84', BasicSharp::VERSION
    assert_equal BasicSharp::VERSION, spec.fetch('target_version')
    assert_equal 'native_parser_dispatch_integration_under_ruby_referee', spec.fetch('status')
  end

  def test_dispatcher_loads_checked_in_native_artifact
    instance = dispatcher
    assert_instance_of BasicSharp::SmallCompilerSubsetBSBCLoader, instance.loader
    assert_equal component.fetch('expected_binary_sha256'), Digest::SHA256.file(instance.artifact_path).hexdigest
    assert_equal 0, instance.invocation_count
  end

  def test_all_nine_heads_are_decided_by_native_bsbc
    instance = dispatcher
    decisions = {}
    component.fetch('expected_heads').each do |head|
      result = instance.dispatch(head)
      refute_nil result, head
      decisions[head.downcase] = result.decision
    end

    assert_equal component.fetch('expected_decisions'), decisions
    assert_equal 9, instance.invocation_count
    assert_equal 9, instance.matched_count
    assert_equal 0, instance.rejected_count
  end

  def test_parser_invocation_count_is_observable_and_exact_for_all_heads
    parser = BasicSharp::SmallCompilerSubsetParser.new(all_heads_source)
    assert_equal 9, parser.statements.length
    assert_equal spec.dig('parser_integration', 'expected_fixture_dispatch_invocations'), parser.native_dispatcher.invocation_count
    assert_equal component.fetch('expected_heads'), parser.statements.map(&:starter)
  end

  def test_pipeline_and_driver_expose_native_dispatch_activity
    driver = BasicSharp::SmallCompilerSubsetDriver.new("START\n[\n].\n")
    assert_equal 1, driver.native_dispatch_invocation_count
    assert_same driver.pipeline.native_dispatcher, driver.native_dispatcher
  end

  def test_invalid_head_is_rejected_without_ruby_guess
    instance = dispatcher
    parser = BasicSharp::SmallCompilerSubsetParser.new("LOOP\n[\n].\n", native_dispatcher: instance)
    assert_empty parser.statements
    assert_equal 1, instance.invocation_count
    assert_operator instance.rejected_count, :>=, 1
    assert_includes parser.issues.map(&:message), 'expected a Head before the Body'
  end

  def test_primary_parser_path_does_not_construct_production_parser
    singleton = BasicSharp::Parser.singleton_class
    alias_name = :__v081_native_dispatch_original_new
    singleton.class_eval do
      alias_method alias_name, :new
      define_method(:new) { |*| raise 'production Parser constructor invoked' }
    end

    parser = BasicSharp::SmallCompilerSubsetParser.new(all_heads_source)
    assert_equal 9, parser.statements.length
    assert_equal 9, parser.native_dispatcher.invocation_count
  ensure
    if singleton.method_defined?(alias_name)
      singleton.class_eval do
        alias_method :new, alias_name
        remove_method alias_name
      end
    end
  end

  def test_wrong_native_dispatch_fails_visibly_instead_of_falling_back
    source = File.read(NATIVE_SOURCE, encoding: 'UTF-8')
    sabotage = source.sub('"parse-kind-section"', '"parse-event-rule"')
    refute_equal source, sabotage

    Dir.mktmpdir('basic-sharp-v081-native-dispatch-sabotage') do |directory|
      bad_artifact = File.join(directory, 'wrong_dispatch.bsbc')
      BasicSharp::SmallCompilerSubsetDriver.new(sabotage, source_label: '(wrong dispatch sabotage)').compile_to(bad_artifact)
      bad_dispatcher = BasicSharp::SmallCompilerSubsetNativeDispatch.new(artifact_path: bad_artifact)
      parser = BasicSharp::SmallCompilerSubsetParser.new("KINDS\n[\n].\n", native_dispatcher: bad_dispatcher)

      assert_empty parser.statements
      assert_equal 1, bad_dispatcher.invocation_count
      assert_includes parser.issues.map(&:message), 'expected a Head before the Body'
    end
  end

  def test_parser_source_has_no_old_hardcoded_dispatch_table
    text = File.read(File.join(ROOT, 'compiler/small_compiler_subset_parser.rb'), encoding: 'UTF-8')
    assert_includes text, 'native_dispatcher.dispatch(text)'
    refute_includes text, '%w[KINDS DEFINE START OTHERWISE]'
    refute_includes text, 'Parser::BLOCK_HEADS.any?'
  end

  def test_trial_by_fire_inventory_runs_native_dispatch_gate
    inventory = JSON.parse(File.read(File.join(ROOT, 'spec/trial_by_fire/BASIC_SHARP_TRIAL_BY_FIRE_VALIDATION_INVENTORY_v1.json'), encoding: 'UTF-8'))
    tools = inventory.fetch('required_tools').map { |entry| entry.fetch('path') }
    assert_includes tools, 'tools/native_parser_dispatch_integration.rb'
  end
end
