# frozen_string_literal: true

require 'json'
require 'minitest/autorun'
require_relative '../compiler/bootstrap_boundary_audit'

class TestBootstrapBoundaryAudit < Minitest::Test
  ROOT = File.expand_path('..', __dir__)
  SPEC_PATH = File.join(ROOT, 'spec/self_hosting/BASIC_SHARP_BOOTSTRAP_BOUNDARY_AUDIT_v1.json')

  def spec
    @spec ||= JSON.parse(File.read(SPEC_PATH, encoding: 'UTF-8'))
  end

  def audit
    @audit ||= BasicSharp::BootstrapBoundaryAudit.new(spec, root: ROOT).to_h
  end

  def test_contract_identity_and_milestone
    assert_equal 'bsharp.bootstrap_boundary_audit.json', spec.fetch('format')
    assert_equal 1, spec.fetch('format_version')
    assert_equal BasicSharp::VERSION, spec.fetch('target_version')
    assert_equal 'bootstrap_boundary_audit_under_ruby_referee', spec.fetch('status')
    assert_equal 'v0.1.64 Self-Hosting Milestone 1', spec.fetch('next_milestone')
  end

  def test_boundaries_pass_and_every_path_exists
    assert audit.fetch(:all_pass)
    assert_operator audit.fetch(:stage_count), :>=, 7
    audit.fetch(:stages).each do |stage|
      assert_empty stage.fetch(:missing_paths), stage.fetch(:name)
      assert_operator stage.fetch(:existing_path_count), :>, 0, stage.fetch(:name)
    end
  end

  def test_audit_forbids_unsafe_milestone_claims
    forbidden = spec.fetch('forbidden_until_after_milestone')
    assert_includes forbidden, 'claiming BASIC# is self-hosted'
    assert_includes forbidden, 'replacing the Ruby bootstrap compiler'
    assert_includes forbidden, 'adding Profile 8'
    assert_includes forbidden, 'changing production runtime behaviour'
    assert_includes forbidden, 'renaming bytecode or BSBC'
  end

  def test_no_golden_expected_fetch_uses_computed_fallback
    assert audit.fetch(:checks).fetch(:no_expected_self_comparison_fallbacks)
    assert_empty audit.fetch(:expected_fallback_offenders)
  end

  def test_trial_by_fire_inventory_runs_bootstrap_boundary_audit
    inventory = JSON.parse(File.read(File.join(ROOT, 'spec/trial_by_fire/BASIC_SHARP_TRIAL_BY_FIRE_VALIDATION_INVENTORY_v1.json'), encoding: 'UTF-8'))
    tools = inventory.fetch('required_tools').map { |entry| entry.fetch('path') }
    assert_includes tools, 'tools/bootstrap_boundary_audit.rb'
  end
end
