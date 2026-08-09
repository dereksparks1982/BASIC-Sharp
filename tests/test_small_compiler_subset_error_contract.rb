# frozen_string_literal: true

require 'json'
require 'minitest/autorun'
require_relative '../compiler/small_compiler_subset_error_contract'
require_relative '../compiler/small_compiler_subset_ir_parity_harness'

class TestSmallCompilerSubsetErrorContract < Minitest::Test
  ROOT = File.expand_path('..', __dir__)
  SPEC_PATH = File.join(ROOT, 'spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_ERROR_CONTRACT_v1.json')
  PARITY_SPEC_PATH = File.join(ROOT, 'spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_IR_PARITY_HARNESS_v1.json')

  def spec
    @spec ||= JSON.parse(File.read(SPEC_PATH, encoding: 'UTF-8'))
  end

  def test_spec_targets_the_live_basic_sharp_version
    assert_equal '0.1.65', BasicSharp::VERSION
    assert_equal BasicSharp::VERSION, spec.fetch('target_version')
    assert_equal 'plain_english_error_contract_under_ruby_referee', spec.fetch('status')
  end

  def test_every_invalid_fixture_matches_locked_plain_english_errors
    record = BasicSharp::SmallCompilerSubsetErrorContract.new(spec.fetch('fixtures')).to_h

    assert_equal 'bsharp.small_compiler_subset.error_contract.record', record.fetch(:format)
    assert_equal '0.1.65', record.fetch(:version)
    assert_equal spec.fetch('fixtures').length, record.fetch(:fixture_count)
    assert_equal true, record.fetch(:all_pass)

    record.fetch(:fixtures).each do |fixture|
      assert_equal true, fixture.fetch(:exact_errors_match), fixture.fetch(:name)
      assert_equal true, fixture.fetch(:digest_matches), fixture.fetch(:name)
      assert_empty fixture.fetch(:unknown_diagnostics), fixture.fetch(:name)
      fixture.fetch(:canonical_errors).each do |error|
        assert_match(/\ABSE\d{4}\z/, error.fetch(:id))
        assert_equal 'error', error.fetch(:severity)
        refute_match(/Ruby|node|stack|exception/i, error.fetch(:plain_message))
        assert_match(/\A[A-Z].*[.]\z/, error.fetch(:plain_message))
      end
    end
  end

  def test_error_contract_does_not_break_valid_ir_golden_parity
    parity_spec = JSON.parse(File.read(PARITY_SPEC_PATH, encoding: 'UTF-8'))
    record = BasicSharp::SmallCompilerSubsetIRParityHarness.new(parity_spec.fetch('fixtures')).to_h

    assert_equal true, record.fetch(:all_pass)
  end

  def test_trial_by_fire_inventory_runs_the_error_contract_tool
    inventory = JSON.parse(File.read(File.join(ROOT, 'spec/trial_by_fire/BASIC_SHARP_TRIAL_BY_FIRE_VALIDATION_INVENTORY_v1.json'), encoding: 'UTF-8'))
    tools = inventory.fetch('required_tools').map { |entry| entry.fetch('path') }

    assert_includes tools, 'tools/small_compiler_subset_error_contract.rb'
  end
end
