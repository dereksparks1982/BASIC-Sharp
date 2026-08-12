# frozen_string_literal: true

require 'json'
require 'minitest/autorun'
require_relative '../compiler/ast_nodes'

class TestWholeLanguageGauntletContract < Minitest::Test
  ROOT = File.expand_path('..', __dir__)

  def setup
    @spec = JSON.parse(File.read(File.join(ROOT, 'spec/trial_by_fire/BASIC_SHARP_WHOLE_LANGUAGE_GAUNTLET_EXPANSION_v1.json'), encoding: 'UTF-8'))
    @inventory = JSON.parse(File.read(File.join(ROOT, 'spec/trial_by_fire/BASIC_SHARP_TRIAL_BY_FIRE_VALIDATION_INVENTORY_v1.json'), encoding: 'UTF-8'))
  end

  def test_spec_identity_and_version
    assert_equal 'bsharp.whole_language_gauntlet_expansion.json', @spec.fetch('format')
    assert_equal 1, @spec.fetch('format_version')
    assert_equal '0.1.78', @spec.fetch('target_version')
    assert_equal BasicSharp::VERSION, @spec.fetch('target_version')
    assert_equal 'v0.1.78', @spec.fetch('required_target_version')
  end

  def test_expanded_counts_are_sealed_in_inventory
    expected = {
      'events_per_path' => 128_000,
      'platform_frames' => 128_000,
      'input_movement_frames' => 64_000,
      'ask_questions' => 32_000,
      'save_checkpoints' => 1_250,
      'isolated_worlds' => 320,
      'generated_programs' => 384,
      'mutations_per_boundary' => 3_072,
      'hostile_artifacts' => 12_288,
      'follow_up_boundaries' => [1_023, 1_024, 1_025]
    }
    assert_equal expected, @spec.fetch('default_counts')
    assert_equal expected, @inventory.fetch('gauntlet_defaults')
  end

  def test_contract_tool_is_required_by_installer_order_inventory
    tools = @inventory.fetch('required_tools').map { |entry| entry.fetch('path') }
    assert_includes tools, 'tools/whole_language_gauntlet_contract.rb'
    assert_includes tools, 'tools/release_forensic_overlay.rb'
    assert_includes tools, 'tools/trial_by_fire_gauntlet.rb'
  end
end
