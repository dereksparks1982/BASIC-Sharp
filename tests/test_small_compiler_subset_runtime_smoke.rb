# frozen_string_literal: true

require 'json'
require 'minitest/autorun'
require_relative '../compiler/small_compiler_subset_runtime_smoke'

class TestSmallCompilerSubsetRuntimeSmoke < Minitest::Test
  ROOT = File.expand_path('..', __dir__)
  SPEC_PATH = File.join(ROOT, 'spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_RUNTIME_SMOKE_v1.json')

  def spec
    @spec ||= JSON.parse(File.read(SPEC_PATH, encoding: 'UTF-8'))
  end

  def smoke
    @smoke ||= BasicSharp::SmallCompilerSubsetRuntimeSmoke.new(spec).to_h
  end

  def test_contract_identity
    assert_equal 'bsharp.small_compiler_subset.runtime_smoke.json', spec.fetch('format')
    assert_equal 1, spec.fetch('format_version')
    assert_equal BasicSharp::VERSION, spec.fetch('target_version')
    assert_equal 'runtime_smoke_under_ruby_referee', spec.fetch('status')
  end

  def test_runtime_smoke_remains_a_referee_check_not_self_hosting_claim
    forbidden = spec.fetch('scope').fetch('forbidden')
    assert_includes forbidden, 'claiming BASIC# is self-hosted'
    assert_includes forbidden, 'replacing Ruby bootstrap compiler'
    assert_includes forbidden, 'adding Profile 8'
    assert_includes forbidden, 'renaming bytecode or BSBC'
    assert_includes forbidden, 'changing production runtime behaviour'
  end

  def test_every_fixture_reaches_the_verifying_runtime_and_matches_golden_records
    assert smoke.fetch(:all_pass)
    assert_operator smoke.fetch(:fixture_count), :>=, 7
    smoke.fetch(:fixtures).each do |fixture|
      assert fixture.fetch(:passes), fixture.fetch(:name)
      assert_equal fixture.fetch(:events).length, fixture.fetch(:runtime).fetch(:matched_event_count), fixture.fetch(:name)
      assert_equal fixture.fetch(:expected_event_results_sha256), fixture.fetch(:runtime).fetch(:event_results_sha256), fixture.fetch(:name)
      assert_equal fixture.fetch(:expected_snapshot_sha256), fixture.fetch(:runtime).fetch(:snapshot_sha256), fixture.fetch(:name)
      assert_equal fixture.fetch(:expected_save_document_sha256), fixture.fetch(:runtime).fetch(:save_document_sha256), fixture.fetch(:name)
    end
  end

  def test_every_fixture_declares_required_expected_fields
    required = BasicSharp::SmallCompilerSubsetRuntimeSmoke.required_expected_fields
    assert_equal 6, required.length
    spec.fetch('fixtures').each do |fixture|
      required.each do |field|
        assert fixture.key?(field), "#{fixture.fetch('name')} missing #{field}"
      end
    end
  end

  def test_missing_expected_binary_digest_fails_loudly
    broken = Marshal.load(Marshal.dump(spec))
    broken.fetch('fixtures').first.delete('expected_binary_sha256')

    error = assert_raises(KeyError) do
      BasicSharp::SmallCompilerSubsetRuntimeSmoke.new(broken).to_h
    end
    assert_includes error.message, 'expected_binary_sha256'
  end

  def test_missing_expected_matched_event_count_fails_loudly
    broken = Marshal.load(Marshal.dump(spec))
    broken.fetch('fixtures').first.delete('expected_matched_event_count')

    error = assert_raises(KeyError) do
      BasicSharp::SmallCompilerSubsetRuntimeSmoke.new(broken).to_h
    end
    assert_includes error.message, 'expected_matched_event_count'
  end

  def test_trial_by_fire_inventory_runs_runtime_smoke_tool
    inventory = JSON.parse(File.read(File.join(ROOT, 'spec/trial_by_fire/BASIC_SHARP_TRIAL_BY_FIRE_VALIDATION_INVENTORY_v1.json'), encoding: 'UTF-8'))
    tools = inventory.fetch('required_tools').map { |entry| entry.fetch('path') }
    assert_includes tools, 'tools/small_compiler_subset_runtime_smoke.rb'
  end
end
