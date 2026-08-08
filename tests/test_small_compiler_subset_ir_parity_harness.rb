# frozen_string_literal: true

require 'json'
require 'minitest/autorun'
require_relative '../compiler/small_compiler_subset_ir_parity_harness'

class TestSmallCompilerSubsetIRParityHarness < Minitest::Test
  ROOT = File.expand_path('..', __dir__)
  SPEC_PATH = File.join(ROOT, 'spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_IR_PARITY_HARNESS_v1.json')

  def spec
    @spec ||= JSON.parse(File.read(SPEC_PATH, encoding: 'UTF-8'))
  end

  def test_spec_targets_the_live_basic_sharp_version
    assert_equal '0.1.63', BasicSharp::VERSION
    assert_equal BasicSharp::VERSION, spec.fetch('target_version')
    assert_equal 'ir_golden_parity_under_ruby_referee', spec.fetch('status')
  end

  def test_golden_parity_harness_matches_every_fixture
    harness = BasicSharp::SmallCompilerSubsetIRParityHarness.new(spec.fetch('fixtures'))
    record = harness.to_h

    assert_equal 'bsharp.small_compiler_subset.ir_golden_parity.record', record.fetch(:format)
    assert_equal '0.1.63', record.fetch(:version)
    assert_equal 'ir_golden_parity_under_ruby_referee', record.fetch(:status)
    assert_equal spec.fetch('fixtures').length, record.fetch(:fixture_count)
    assert_equal true, record.fetch(:all_pass)

    record.fetch(:fixtures).each do |fixture|
      assert_equal true, fixture.fetch(:parser_ruby_referee_matches), fixture.fetch(:name)
      assert_equal true, fixture.fetch(:ir_ruby_referee_matches), fixture.fetch(:name)
      assert_equal true, fixture.fetch(:golden_sha256_matches), fixture.fetch(:name)
      assert_equal true, fixture.fetch(:referee_digest_matches), fixture.fetch(:name)
      assert_equal true, fixture.fetch(:counts_match), fixture.fetch(:name)
      assert_match(/\A[0-9a-f]{64}\z/, fixture.fetch(:subset_ir_sha256))
      assert_equal fixture.fetch(:expected_ir_sha256), fixture.fetch(:subset_ir_sha256)
      assert_equal fixture.fetch(:subset_ir_sha256), fixture.fetch(:ruby_referee_ir_sha256)
    end
  end

  def test_normalized_digest_is_key_order_stable
    left = { beta: [2, { alpha: 1 }], alpha: 'same' }
    right = { 'alpha' => 'same', 'beta' => [2, { 'alpha' => 1 }] }

    assert_equal BasicSharp::SmallCompilerSubsetIRParityHarness.digest_for(left),
                 BasicSharp::SmallCompilerSubsetIRParityHarness.digest_for(right)
  end

  def test_trial_by_fire_inventory_runs_the_parity_harness_tool
    inventory = JSON.parse(File.read(File.join(ROOT, 'spec/trial_by_fire/BASIC_SHARP_TRIAL_BY_FIRE_VALIDATION_INVENTORY_v1.json'), encoding: 'UTF-8'))
    tools = inventory.fetch('required_tools').map { |entry| entry.fetch('path') }

    assert_includes tools, 'tools/small_compiler_subset_ir_parity_harness.rb'
  end
end
