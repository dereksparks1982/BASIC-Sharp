# frozen_string_literal: true

require 'json'
require 'minitest/autorun'
require_relative '../compiler/small_compiler_subset_ir_emitter'
require_relative '../compiler/small_compiler_subset_semantic_resolver'

class TestSmallCompilerSubsetSemanticResolver < Minitest::Test
  ROOT = File.expand_path('..', __dir__)
  SPEC_PATH = File.join(ROOT, 'spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_SEMANTIC_RESOLVER_v1.json')
  IR_SPEC_PATH = File.join(ROOT, 'spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_IR_EMITTER_v1.json')

  def spec
    @spec ||= JSON.parse(File.read(SPEC_PATH, encoding: 'UTF-8'))
  end

  def ir_spec
    @ir_spec ||= JSON.parse(File.read(IR_SPEC_PATH, encoding: 'UTF-8'))
  end

  def fixture_source(entry)
    return File.read(File.join(ROOT, entry.fetch('source_path')), encoding: 'UTF-8') if entry['source_path']

    ir_spec.fetch('fixtures').find { |fixture| fixture.fetch('name') == entry.fetch('name') }.fetch('source')
  end

  def object_source
    entry = spec.fetch('fixtures').find { |fixture| fixture.fetch('name') == 'v074_object_interaction_independence' }
    fixture_source(entry)
  end

  def test_contract_identity_and_version
    assert_equal 'bsharp.small_compiler_subset.semantic_resolver.contract.json', spec.fetch('format')
    assert_equal 1, spec.fetch('format_version')
    assert_equal '0.1.82', BasicSharp::VERSION
    assert_equal BasicSharp::VERSION, spec.fetch('target_version')
    assert_equal 'semantic_resolver_independent_under_ruby_referee', spec.fetch('status')
  end

  def test_independent_resolver_file_does_not_call_or_require_production_resolver
    source = File.read(File.join(ROOT, 'compiler/small_compiler_subset_semantic_resolver.rb'), encoding: 'UTF-8')
    refute_match(/\bSemanticResolver\.new\b/, source)
    refute_includes source, "require_relative 'resolver'"
  end

  def test_ir_emitter_uses_independent_resolver_for_primary_document
    source = File.read(File.join(ROOT, 'compiler/small_compiler_subset_ir_emitter.rb'), encoding: 'UTF-8')
    assert_includes source, 'SmallCompilerSubsetSemanticResolver.new(program, dictionary: dictionary)'
    assert_includes source, 'SemanticResolver.new(ruby_program, dictionary: parser.dictionary).resolve'
  end

  def test_all_semantic_resolver_fixtures_match_ruby_referee_exactly
    spec.fetch('fixtures').each do |entry|
      emitter = BasicSharp::SmallCompilerSubsetIREmitter.new(fixture_source(entry))
      assert emitter.parser_matches_ruby_referee?, entry.fetch('name')
      assert emitter.ir_matches_ruby_referee?, entry.fetch('name')
      assert_equal emitter.ruby_referee_bsharp_ir, emitter.bsharp_ir, entry.fetch('name')
    end
  end

  def test_primary_document_does_not_invoke_production_semantic_resolver
    klass = BasicSharp::SemanticResolver
    klass.class_eval do
      alias_method :__v074_test_original_resolve, :resolve
      define_method(:resolve) { raise 'production resolver invoked' }
    end

    begin
      emitter = BasicSharp::SmallCompilerSubsetIREmitter.new(object_source)
      document = emitter.document
      assert_equal 'bsir.debug.json', document.to_h.fetch(:format)
    ensure
      klass.class_eval do
        alias_method :resolve, :__v074_test_original_resolve
        remove_method :__v074_test_original_resolve
      end
    end
  end

  def test_v073_object_interactions_canonicalize_identically
    emitter = BasicSharp::SmallCompilerSubsetIREmitter.new(object_source)
    assert emitter.ir_matches_ruby_referee?

    actions = emitter.bsharp_ir.fetch(:events).flat_map { |event| event.fetch('then') }
    assert_equal %w[change change change carry], actions.map { |action| action.fetch('action') }
    assert_equal %w[open closed locked], actions.first(3).map { |action| action.fetch('to').fetch('name') }
  end

  def test_trial_by_fire_inventory_runs_semantic_resolver_gate
    inventory = JSON.parse(File.read(File.join(ROOT, 'spec/trial_by_fire/BASIC_SHARP_TRIAL_BY_FIRE_VALIDATION_INVENTORY_v1.json'), encoding: 'UTF-8'))
    tools = inventory.fetch('required_tools').map { |entry| entry.fetch('path') }
    assert_includes tools, 'tools/small_compiler_subset_semantic_resolver.rb'
  end
end
