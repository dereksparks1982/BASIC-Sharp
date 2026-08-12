# frozen_string_literal: true

require 'json'
require 'minitest/autorun'
require_relative '../compiler/readme_current_release_truth'

class TestReadmeCurrentReleaseTruth < Minitest::Test
  ROOT = File.expand_path('..', __dir__)
  SPEC_PATH = File.join(ROOT, 'spec/self_hosting/BASIC_SHARP_README_CURRENT_RELEASE_TRUTH_v1.json')
  README_PATH = File.join(ROOT, 'README.md')

  def spec
    @spec ||= JSON.parse(File.read(SPEC_PATH, encoding: 'UTF-8'))
  end

  def readme
    File.read(README_PATH, encoding: 'UTF-8')
  end

  def truth
    @truth ||= BasicSharp::ReadmeCurrentReleaseTruth.new(readme, spec).to_h
  end

  def test_contract_identity
    assert_equal 'bsharp.readme_current_release_truth.json', spec.fetch('format')
    assert_equal 1, spec.fetch('format_version')
    assert_equal BasicSharp::VERSION, spec.fetch('target_version')
    assert_equal 'readme_current_release_truth_gate', spec.fetch('status')
  end

  def test_current_readme_section_matches_active_build
    assert truth.fetch(:all_pass), truth.inspect
    assert truth.fetch(:checks).fetch(:heading_matches)
    assert truth.fetch(:checks).fetch(:build_title_present)
    assert truth.fetch(:checks).fetch(:summary_present)
    assert truth.fetch(:checks).fetch(:required_mentions_present)
    assert truth.fetch(:checks).fetch(:canonical_current_lines_match)
  end

  def test_canonical_current_lines_match_active_slice_across_full_readme
    expected = spec.fetch('current_release').fetch('canonical_current_lines').values
    assert_equal expected, truth.fetch(:actual_current_lines)
    assert_equal expected, truth.fetch(:expected_current_lines)
  end

  def test_stale_current_build_line_outside_intro_section_is_rejected
    stale = readme.sub(
      'Current build: v0.1.78 Self-Hosting Milestone 2 Slice 5 Integrated Independent Compiler Pipeline',
      'Current build: v0.1.77 Self-Hosting Milestone 2 Slice 4 BSharp VM Execution Independence'
    )
    record = BasicSharp::ReadmeCurrentReleaseTruth.new(stale, spec).to_h
    refute record.fetch(:all_pass)
    refute record.fetch(:checks).fetch(:canonical_current_lines_match)
  end

  def test_stale_current_milestone_line_outside_intro_section_is_rejected
    stale = readme.sub(
      'Current self-hosting milestone: v0.1.78 Self-Hosting Milestone 2 Slice 5 under Ruby referee control',
      'Current self-hosting milestone: v0.1.77 Self-Hosting Milestone 2 Slice 4 under Ruby referee control'
    )
    record = BasicSharp::ReadmeCurrentReleaseTruth.new(stale, spec).to_h
    refute record.fetch(:all_pass)
    refute record.fetch(:checks).fetch(:canonical_current_lines_match)
  end

  def test_duplicate_current_truth_line_is_rejected
    duplicate = readme + "\n" + spec.fetch('current_release').fetch('canonical_current_lines').fetch('current_build') + "\n"
    record = BasicSharp::ReadmeCurrentReleaseTruth.new(duplicate, spec).to_h
    refute record.fetch(:all_pass)
    refute record.fetch(:checks).fetch(:canonical_current_lines_match)
  end

  def test_stale_current_release_text_is_rejected
    stale = readme.sub(
      'Elderedd identity migration',
      'adds the first small compiler subset IR golden parity harness'
    )
    record = BasicSharp::ReadmeCurrentReleaseTruth.new(stale, spec).to_h
    refute record.fetch(:all_pass)
    refute_empty record.fetch(:forbidden_hits)
  end

  def test_missing_required_current_release_phrase_is_rejected
    broken = readme.gsub('BCS', 'Creator Services')
    record = BasicSharp::ReadmeCurrentReleaseTruth.new(broken, spec).to_h
    refute record.fetch(:all_pass)
    assert_includes record.fetch(:missing_mentions), 'BCS'
  end

  def test_trial_by_fire_inventory_runs_readme_truth_gate
    inventory = JSON.parse(File.read(File.join(ROOT, 'spec/trial_by_fire/BASIC_SHARP_TRIAL_BY_FIRE_VALIDATION_INVENTORY_v1.json'), encoding: 'UTF-8'))
    tools = inventory.fetch('required_tools').map { |entry| entry.fetch('path') }
    assert_includes tools, 'tools/readme_current_release_truth.rb'
  end
end
