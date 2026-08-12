# frozen_string_literal: true

require 'json'
require 'minitest/autorun'
require_relative '../compiler/small_compiler_subset_bsbc_parity_harness'

class TestSmallCompilerSubsetBSBCParityHarness < Minitest::Test
  ROOT = File.expand_path('..', __dir__)
  SPEC_PATH = File.join(ROOT, 'spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_BSBC_PARITY_HARNESS_v1.json')

  def spec
    @spec ||= JSON.parse(File.read(SPEC_PATH, encoding: 'UTF-8'))
  end

  def test_spec_targets_the_live_basic_sharp_version
    assert_equal '0.1.82', BasicSharp::VERSION
    assert_equal BasicSharp::VERSION, spec.fetch('target_version')
    assert_equal 'bsbc_golden_parity_under_ruby_referee', spec.fetch('status')
  end

  def test_golden_parity_harness_matches_every_fixture
    harness = BasicSharp::SmallCompilerSubsetBSBCParityHarness.new(spec.fetch('fixtures'))
    record = harness.to_h

    assert_equal 'bsharp.small_compiler_subset.bsbc_golden_parity.record', record.fetch(:format)
    assert_equal '0.1.82', record.fetch(:version)
    assert_equal 'bsbc_golden_parity_under_ruby_referee', record.fetch(:status)
    assert_equal spec.fetch('fixtures').length, record.fetch(:fixture_count)
    assert_equal true, record.fetch(:all_pass)

    record.fetch(:fixtures).each do |fixture|
      assert_equal true, fixture.fetch(:passes), fixture.fetch(:name)
      fixture.fetch(:checks).each_value { |passed| assert_equal true, passed, fixture.fetch(:name) }
      assert_match(/\A[0-9a-f]{64}\z/, fixture.fetch(:binary_sha256))
      assert_match(/\A[0-9a-f]{64}\z/, fixture.fetch(:loader_summary_sha256))
      assert_equal fixture.fetch(:expected_binary_sha256), fixture.fetch(:binary_sha256)
      assert_equal fixture.fetch(:expected_loader_summary_sha256), fixture.fetch(:loader_summary_sha256)
    end
  end

  def test_profile_coverage_reaches_existing_bytecode_lanes_without_profile_8
    profiles = spec.fetch('fixtures').map { |fixture| fixture.fetch('expected_profile') }
    assert_includes profiles, 'bsharp.bytecode.v1'
    assert_includes profiles, 'bsharp.bytecode.v2'
    assert_includes profiles, 'bsharp.bytecode.v4'
    assert_includes profiles, 'bsharp.bytecode.v7'
    refute_includes profiles, 'bsharp.bytecode.v8'
  end

  def test_trial_by_fire_inventory_runs_the_bsbc_parity_harness_tool
    inventory = JSON.parse(File.read(File.join(ROOT, 'spec/trial_by_fire/BASIC_SHARP_TRIAL_BY_FIRE_VALIDATION_INVENTORY_v1.json'), encoding: 'UTF-8'))
    tools = inventory.fetch('required_tools').map { |entry| entry.fetch('path') }

    assert_includes tools, 'tools/small_compiler_subset_bsbc_parity_harness.rb'
  end
end
