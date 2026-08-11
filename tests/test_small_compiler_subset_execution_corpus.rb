# frozen_string_literal: true

require 'json'
require 'minitest/autorun'
require_relative '../compiler/small_compiler_subset_execution_corpus'

class TestSmallCompilerSubsetExecutionCorpus < Minitest::Test
  ROOT = File.expand_path('..', __dir__)
  SPEC_PATH = File.join(ROOT, 'spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_EXECUTION_CORPUS_v1.json')
  PARITY_SPEC_PATH = File.join(ROOT, 'spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_BSBC_EXECUTION_PARITY_v1.json')

  def spec
    @spec ||= JSON.parse(File.read(SPEC_PATH, encoding: 'UTF-8'))
  end

  def parity_spec
    @parity_spec ||= JSON.parse(File.read(PARITY_SPEC_PATH, encoding: 'UTF-8'))
  end

  def record
    @record ||= BasicSharp::SmallCompilerSubsetExecutionCorpus.new(spec, parity_spec).to_h
  end

  def test_contract_identity
    assert_equal 'bsharp.small_compiler_subset.execution_corpus.json', spec.fetch('format')
    assert_equal 1, spec.fetch('format_version')
    assert_equal BasicSharp::VERSION, spec.fetch('target_version')
    assert_equal 'execution_corpus_expanded_under_ruby_referee', spec.fetch('status')
  end

  def test_execution_corpus_floor_is_larger_than_v064
    assert record.fetch(:all_pass)
    assert_operator record.fetch(:fixture_count), :>=, 18
    assert_operator record.fetch(:category_count), :>=, 13
    assert_operator record.fetch(:event_count), :>=, 56
  end

  def test_v065_new_fixture_categories_are_present
    categories = record.fetch(:category_counts).keys
    assert_includes categories, 'v065_multi_scene_execution'
    assert_includes categories, 'v065_follow_up_execution'
    assert_includes categories, 'v065_save_restore_execution'
  end


  def test_v074_semantic_resolver_object_interaction_fixture_is_present
    categories = record.fetch(:category_counts).keys
    assert_includes categories, 'v074_object_interaction_semantic_resolver'
  end

  def test_guardrails_forbid_overclaiming_self_hosting
    assert_includes spec.fetch('guardrails'), 'Ruby remains the referee'
    assert_includes spec.fetch('guardrails'), 'not full self-hosting'
    assert_includes spec.fetch('forbidden'), 'claiming BASIC# is self-hosted'
    assert_includes spec.fetch('forbidden'), 'removing the DKLab compatibility bridge'
  end

  def test_trial_by_fire_inventory_runs_execution_corpus_gate
    inventory = JSON.parse(File.read(File.join(ROOT, 'spec/trial_by_fire/BASIC_SHARP_TRIAL_BY_FIRE_VALIDATION_INVENTORY_v1.json'), encoding: 'UTF-8'))
    tools = inventory.fetch('required_tools').map { |entry| entry.fetch('path') }
    assert_includes tools, 'tools/small_compiler_subset_execution_corpus.rb'
  end
end
