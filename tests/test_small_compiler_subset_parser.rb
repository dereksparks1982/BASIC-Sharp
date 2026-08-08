# frozen_string_literal: true

require 'json'
require 'minitest/autorun'
require_relative '../compiler/parser'
require_relative '../compiler/small_compiler_subset_parser'

class TestSmallCompilerSubsetParser < Minitest::Test
  ROOT = File.expand_path('..', __dir__)
  SPEC_PATH = File.join(ROOT, 'spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_PARSER_v1.json')

  def spec
    @spec ||= JSON.parse(File.read(SPEC_PATH, encoding: 'UTF-8'))
  end

  def test_spec_targets_the_live_basic_sharp_version
    assert_equal '0.1.59', BasicSharp::VERSION
    assert_equal BasicSharp::VERSION, spec.fetch('target_version')
    assert_equal 'implementation_under_ruby_referee', spec.fetch('status')
  end

  def test_subset_parser_matches_ruby_referee_for_each_fixture
    spec.fetch('fixtures').each do |fixture|
      parser = BasicSharp::SmallCompilerSubsetParser.new(fixture.fetch('source'))
      document = parser.to_h

      assert parser.parser_matches_ruby_referee?, "Ruby Parser referee mismatch for #{fixture.fetch('name')}"
      assert_equal fixture.fetch('expected_statement_count'), document.fetch(:statements).length
      assert_equal fixture.fetch('expected_starters'), document.fetch(:statements).map { |entry| entry.fetch(:starter) }
    end
  end

  def test_subset_parser_collects_result_markers_and_action_words
    fixture = spec.fetch('fixtures').find { |entry| entry.fetch('name') == 'start_when_if_subset' }
    parser = BasicSharp::SmallCompilerSubsetParser.new(fixture.fetch('source'))
    actions = parser.statements.flat_map(&:children).map(&:action).compact
    markers = parser.statements.flat_map(&:children).map(&:result_marker).compact

    assert_equal fixture.fetch('expected_action_words'), actions
    assert_equal %w[then then], markers
  end

  def test_to_h_declares_non_production_status
    parser = BasicSharp::SmallCompilerSubsetParser.new("START\n[\n    PLAYER is ready\n].\n")
    document = parser.to_h

    assert_equal 'bsharp.small_compiler_subset.parser.record', document.fetch(:format)
    assert_equal '0.1.59', document.fetch(:version)
    assert_equal 'implementation_under_ruby_referee', document.fetch(:status)
    assert_equal true, document.fetch(:ruby_referee_matches)
  end

  def test_trial_by_fire_inventory_runs_the_subset_parser_tool
    inventory = JSON.parse(File.read(File.join(ROOT, 'spec/trial_by_fire/BASIC_SHARP_TRIAL_BY_FIRE_VALIDATION_INVENTORY_v1.json'), encoding: 'UTF-8'))
    tools = inventory.fetch('required_tools').map { |entry| entry.fetch('path') }

    assert_includes tools, 'tools/small_compiler_subset_parser.rb'
  end
end
