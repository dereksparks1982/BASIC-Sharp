# frozen_string_literal: true

require 'json'
require 'minitest/autorun'
require_relative '../compiler/self_hosting_milestone_1'

class TestSelfHostingMilestone1 < Minitest::Test
  ROOT = File.expand_path('..', __dir__)
  SPEC_PATH = File.join(ROOT, 'spec/self_hosting/BASIC_SHARP_SELF_HOSTING_MILESTONE_1_v1.json')

  def spec
    @spec ||= JSON.parse(File.read(SPEC_PATH, encoding: 'UTF-8'))
  end

  def milestone
    @milestone ||= BasicSharp::SelfHostingMilestone1.new(spec, root: ROOT).to_h
  end

  def test_contract_identity
    assert_equal 'bsharp.self_hosting_milestone_1.json', spec.fetch('format')
    assert_equal 1, spec.fetch('format_version')
    assert_equal BasicSharp::VERSION, spec.fetch('target_version')
    assert_equal 'self_hosting_milestone_1_under_ruby_referee', spec.fetch('status')
  end

  def test_milestone_passes_with_fenced_claims
    assert milestone.fetch(:all_pass), milestone.inspect
    assert milestone.fetch(:checks).fetch(:runtime_smoke_passes)
    assert milestone.fetch(:checks).fetch(:bootstrap_boundary_passes)
    assert milestone.fetch(:checks).fetch(:readme_truth_passes)
    assert milestone.fetch(:checks).fetch(:forbidden_full_self_hosting)
    assert milestone.fetch(:checks).fetch(:forbidden_ruby_retirement)
  end

  def test_required_tools_are_in_trial_by_fire_inventory
    assert_empty milestone.fetch(:missing_inventory_tools)
    assert_includes spec.fetch('required_tools'), 'tools/self_hosting_milestone_1.rb'
    assert_includes spec.fetch('required_tools'), 'tools/readme_current_release_truth.rb'
  end

  def test_milestone_definition_is_not_full_self_hosting
    assert_includes spec.fetch('definition'), 'under Ruby referee supervision'
    assert_includes spec.fetch('allowed_claims').join('\n'), 'not full self-hosting'
    assert_includes spec.fetch('forbidden_claims'), 'BASIC# is fully self-hosted'
    assert_includes spec.fetch('forbidden_claims'), 'Ruby is retired'
  end
end
