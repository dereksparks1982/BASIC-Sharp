# frozen_string_literal: true

require 'json'
require 'minitest/autorun'
require_relative '../compiler/small_compiler_subset_bsbc_execution_parity'

class TestSmallCompilerSubsetBSBCExecutionParity < Minitest::Test
  ROOT = File.expand_path('..', __dir__)
  SPEC_PATH = File.join(ROOT, 'spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_BSBC_EXECUTION_PARITY_v1.json')

  def spec
    @spec ||= JSON.parse(File.read(SPEC_PATH, encoding: 'UTF-8'))
  end

  def parity
    @parity ||= BasicSharp::SmallCompilerSubsetBSBCExecutionParity.new(spec).to_h
  end

  def test_contract_identity
    assert_equal 'bsharp.small_compiler_subset.bsbc_execution_parity.json', spec.fetch('format')
    assert_equal 1, spec.fetch('format_version')
    assert_equal BasicSharp::VERSION, spec.fetch('target_version')
    assert_equal 'bsbc_execution_parity_under_ruby_referee', spec.fetch('status')
  end

  def test_execution_parity_remains_a_referee_check_not_self_hosting_claim
    forbidden = spec.fetch('scope').fetch('forbidden')
    assert_includes forbidden, 'claiming BASIC# is self-hosted'
    assert_includes forbidden, 'replacing Ruby bootstrap compiler'
    assert_includes forbidden, 'adding Profile 8'
    assert_includes forbidden, 'renaming bytecode or BSBC'
    assert_includes forbidden, 'changing production runtime behaviour'
    assert_includes forbidden, 'removing the DKLab compatibility bridge'
  end

  def test_every_fixture_executes_bsbc_in_the_vm_and_matches_ruby_referee
    assert parity.fetch(:all_pass)
    assert_operator parity.fetch(:fixture_count), :>=, 18
    parity.fetch(:fixtures).each do |fixture|
      assert fixture.fetch(:passes), fixture.fetch(:name)
      assert_equal fixture.fetch(:events).length, fixture.fetch(:runtime).fetch(:matched_event_count), fixture.fetch(:name)
      assert_equal fixture.fetch(:expected_vm_event_results_sha256), fixture.fetch(:runtime).fetch(:vm_event_results_sha256), fixture.fetch(:name)
      assert_equal fixture.fetch(:expected_referee_event_results_sha256), fixture.fetch(:runtime).fetch(:referee_event_results_sha256), fixture.fetch(:name)
      assert_equal fixture.fetch(:expected_final_snapshot_sha256), fixture.fetch(:runtime).fetch(:final_snapshot_sha256), fixture.fetch(:name)
      assert_equal fixture.fetch(:expected_save_document_sha256), fixture.fetch(:runtime).fetch(:save_document_sha256), fixture.fetch(:name)
      assert fixture.fetch(:checks).fetch(:vm_referee_event_results_match), fixture.fetch(:name)
      assert fixture.fetch(:checks).fetch(:vm_referee_snapshot_matches), fixture.fetch(:name)
      assert fixture.fetch(:checks).fetch(:vm_referee_save_document_matches), fixture.fetch(:name)
    end
  end


  def test_v074_object_interaction_fixture_crosses_independent_resolver_and_vm
    fixture = parity.fetch(:fixtures).find { |entry| entry.fetch(:name) == 'v074_object_interaction_semantic_resolver' }
    refute_nil fixture
    assert fixture.fetch(:passes)
    assert_equal 'v074_object_interaction_semantic_resolver', fixture.fetch(:category)
    assert_equal 1, fixture.fetch(:runtime).fetch(:matched_event_count)
  end

  def test_every_fixture_declares_required_expected_fields
    required = BasicSharp::SmallCompilerSubsetBSBCExecutionParity.required_expected_fields
    assert_equal 7, required.length
    spec.fetch('fixtures').each do |fixture|
      required.each do |field|
        assert fixture.key?(field), "#{fixture.fetch('name')} missing #{field}"
      end
    end
  end

  def test_missing_expected_vm_digest_fails_loudly
    broken = Marshal.load(Marshal.dump(spec))
    broken.fetch('fixtures').first.delete('expected_vm_event_results_sha256')

    error = assert_raises(KeyError) do
      BasicSharp::SmallCompilerSubsetBSBCExecutionParity.new(broken).to_h
    end
    assert_includes error.message, 'expected_vm_event_results_sha256'
  end

  def test_trial_by_fire_inventory_runs_execution_parity_tool
    inventory = JSON.parse(File.read(File.join(ROOT, 'spec/trial_by_fire/BASIC_SHARP_TRIAL_BY_FIRE_VALIDATION_INVENTORY_v1.json'), encoding: 'UTF-8'))
    tools = inventory.fetch('required_tools').map { |entry| entry.fetch('path') }
    assert_includes tools, 'tools/small_compiler_subset_bsbc_execution_parity.rb'
  end
end
