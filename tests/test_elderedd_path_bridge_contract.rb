# frozen_string_literal: true

require 'json'
require 'minitest/autorun'
require_relative '../compiler/ast_nodes'

class TestEldereddPathBridgeContract < Minitest::Test
  ROOT = File.expand_path('..', __dir__)
  SPEC_PATH = File.join(ROOT, 'spec/governance/BASIC_SHARP_ELDEREDD_PATH_BRIDGE_CONTRACT_v1.json')

  def spec
    @spec ||= JSON.parse(File.read(SPEC_PATH, encoding: 'UTF-8'))
  end

  def test_contract_identity
    assert_equal 'bsharp.elderedd_path_bridge_contract.json', spec.fetch('format')
    assert_equal 1, spec.fetch('format_version')
    assert_equal BasicSharp::VERSION, spec.fetch('target_version')
  end

  def test_canonical_and_legacy_paths_are_both_explicit
    assert_equal '~/Elderedd/Projects/BASIC#', spec.fetch('canonical_path')
    assert_equal '~/DKLab/Projects/BASIC#', spec.fetch('legacy_path')
    assert_equal 'active_retirement_bridge', spec.fetch('bridge_status')
    assert_equal 'forbidden_in_v0.1.84', spec.fetch('removal_status')
  end

  def test_bridge_removal_and_workspace_deletion_are_forbidden
    forbidden = spec.fetch('forbidden')
    assert_includes forbidden, 'removing the DKLab compatibility bridge in v0.1.84'
    assert_includes forbidden, 'deleting unrelated DKLab workspace contents'
    assert_includes forbidden, 'treating DKLab as the active laboratory identity'
  end

  def test_current_docs_carry_path_bridge_truth
    paths = [
      'README.md',
      'docs/company_bible/BASIC_SHARP_COMPANY_BIBLE.md',
      'docs/roadmap/BASIC_SHARP_ROADMAP.md',
      'docs/hand_off/BASIC_SHARP_MASTER_THREAD_HANDOFF.md'
    ]
    text = paths.map { |path| File.read(File.join(ROOT, path), encoding: 'UTF-8') }.join("\n")
    assert_includes text, '~/Elderedd/Projects/BASIC#'
    assert_includes text, '~/DKLab/Projects/BASIC#'
    assert_includes text, 'compatibility bridge'
    assert_includes text, 'DKLab is retired'
    refute_includes text, 'DKLab is the active laboratory'
  end

  def test_trial_by_fire_inventory_runs_path_bridge_tool
    inventory = JSON.parse(File.read(File.join(ROOT, 'spec/trial_by_fire/BASIC_SHARP_TRIAL_BY_FIRE_VALIDATION_INVENTORY_v1.json'), encoding: 'UTF-8'))
    tools = inventory.fetch('required_tools').map { |entry| entry.fetch('path') }
    assert_includes tools, 'tools/elderedd_path_bridge_contract.rb'
  end
end
