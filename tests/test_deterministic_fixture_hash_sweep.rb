# frozen_string_literal: true

require 'json'
require 'minitest/autorun'
require_relative '../compiler/ast_nodes'

class TestDeterministicFixtureHashSweep < Minitest::Test
  ROOT = File.expand_path('..', __dir__)
  SPEC_PATH = File.join(ROOT, 'spec/release/BASIC_SHARP_DETERMINISTIC_FIXTURE_HASH_SWEEP_v1.json')

  def spec
    @spec ||= JSON.parse(File.read(SPEC_PATH, encoding: 'UTF-8'))
  end

  def test_contract_identity
    assert_equal 'bsharp.deterministic_fixture_hash_sweep.json', spec.fetch('format')
    assert_equal 1, spec.fetch('format_version')
    assert_equal BasicSharp::VERSION, spec.fetch('target_version')
    assert_equal 'active_release_gate', spec.fetch('status')
  end

  def test_complete_fixture_family_is_named_together
    tools = spec.fetch('required_tools')
    assert_includes tools, 'tools/text_value_stress.rb'
    assert_includes tools, 'tools/number_change_stress.rb'
    assert_includes tools, 'tools/compound_if_stress.rb'
    assert_includes tools, 'tools/otherwise_branch_stress.rb'
    assert_includes tools, 'tools/small_compiler_subset_bsbc_execution_parity.rb'
    assert_operator tools.length, :>=, 5
  end

  def test_forbids_single_goblin_repair
    forbidden = spec.fetch('forbidden')
    assert_includes forbidden, 'single-goblin repair'
    assert_includes forbidden, 'stale expected_sha256 records'
    assert_includes forbidden, 'stale sealed artifact byte counts'
  end

  def test_trial_by_fire_inventory_runs_sweep
    inventory = JSON.parse(File.read(File.join(ROOT, 'spec/trial_by_fire/BASIC_SHARP_TRIAL_BY_FIRE_VALIDATION_INVENTORY_v1.json'), encoding: 'UTF-8'))
    tools = inventory.fetch('required_tools').map { |entry| entry.fetch('path') }
    assert_includes tools, 'tools/deterministic_fixture_hash_sweep.rb'
  end
end
