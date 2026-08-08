# frozen_string_literal: true

require 'json'
require 'minitest/autorun'
require_relative '../compiler/small_compiler_subset_scene_block_expansion'

class TestSmallCompilerSubsetSceneBlockExpansion < Minitest::Test
  ROOT = File.expand_path('..', __dir__)
  SPEC_PATH = File.join(ROOT, 'spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_SCENE_BLOCK_EXPANSION_v1.json')

  def spec
    @spec ||= JSON.parse(File.read(SPEC_PATH, encoding: 'UTF-8'))
  end

  def test_spec_targets_the_live_basic_sharp_version
    assert_equal '0.1.61', BasicSharp::VERSION
    assert_equal BasicSharp::VERSION, spec.fetch('target_version')
    assert_equal 'scene_block_expansion_under_ruby_referee', spec.fetch('status')
  end

  def test_expanded_scene_and_block_fixtures_pass
    record = BasicSharp::SmallCompilerSubsetSceneBlockExpansion.new(spec).to_h

    assert_equal 'bsharp.small_compiler_subset.scene_block_expansion.record', record.fetch(:format)
    assert_equal '0.1.61', record.fetch(:version)
    assert_equal 'scene_block_expansion_under_ruby_referee', record.fetch(:status)
    assert_equal true, record.fetch(:all_pass)
    assert_equal spec.fetch('valid_fixtures').length, record.fetch(:valid_fixture_count)
    assert_equal spec.fetch('invalid_fixtures').length, record.fetch(:invalid_fixture_count)
  end

  def test_valid_expanded_fixtures_preserve_ruby_referee_parity
    record = BasicSharp::SmallCompilerSubsetSceneBlockExpansion.new(spec).to_h

    record.fetch(:valid_fixtures).each do |fixture|
      assert fixture.fetch(:parser_ruby_referee_matches), "Parser mismatch for #{fixture.fetch(:name)}"
      assert fixture.fetch(:ir_ruby_referee_matches), "IR mismatch for #{fixture.fetch(:name)}"
      assert fixture.fetch(:golden_sha256_matches), "Golden digest mismatch for #{fixture.fetch(:name)}"
      assert fixture.fetch(:referee_digest_matches), "Referee digest mismatch for #{fixture.fetch(:name)}"
      assert fixture.fetch(:starters_match), "Starter sequence mismatch for #{fixture.fetch(:name)}"
      assert fixture.fetch(:actions_match), "Action sequence mismatch for #{fixture.fetch(:name)}"
      assert fixture.fetch(:counts_match), "Count mismatch for #{fixture.fetch(:name)}"
    end
  end

  def test_invalid_expanded_fixtures_use_plain_english_error_contract
    record = BasicSharp::SmallCompilerSubsetSceneBlockExpansion.new(spec).to_h

    record.fetch(:invalid_fixtures).each do |fixture|
      assert fixture.fetch(:exact_errors_match), "Error records changed for #{fixture.fetch(:name)}"
      assert fixture.fetch(:digest_matches), "Error digest changed for #{fixture.fetch(:name)}"
      assert_empty fixture.fetch(:unknown_diagnostics), "Unknown diagnostics for #{fixture.fetch(:name)}"
    end
  end

  def test_trial_by_fire_inventory_runs_the_scene_block_expansion_tool
    inventory = JSON.parse(File.read(File.join(ROOT, 'spec/trial_by_fire/BASIC_SHARP_TRIAL_BY_FIRE_VALIDATION_INVENTORY_v1.json'), encoding: 'UTF-8'))
    tools = inventory.fetch('required_tools').map { |entry| entry.fetch('path') }

    assert_includes tools, 'tools/small_compiler_subset_scene_block_expansion.rb'
  end
end
