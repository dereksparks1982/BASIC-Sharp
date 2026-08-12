# frozen_string_literal: true

require 'json'
require 'minitest/autorun'
require_relative '../compiler/small_compiler_subset_bsbc_emitter'
require_relative '../compiler/small_compiler_subset_bsbc_encoder'

class TestSmallCompilerSubsetBSBCEmitterIndependence < Minitest::Test
  ROOT = File.expand_path('..', __dir__)
  SPEC_PATH = File.join(ROOT, 'spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_BSBC_EMITTER_INDEPENDENCE_v1.json')

  def spec
    @spec ||= JSON.parse(File.read(SPEC_PATH, encoding: 'UTF-8'))
  end

  def fixture
    spec.fetch('fixture')
  end

  def source
    File.read(File.join(ROOT, fixture.fetch('source_path')), encoding: 'UTF-8')
  end

  def test_contract_identity_and_live_version
    assert_equal 'bsharp.small_compiler_subset.bsbc_emitter_independence.contract.json', spec.fetch('format')
    assert_equal 1, spec.fetch('format_version')
    assert_equal '0.1.79', BasicSharp::VERSION
    assert_equal BasicSharp::VERSION, spec.fetch('target_version')
    assert_equal 'bsbc_emitter_independent_under_ruby_referee', spec.fetch('status')
  end

  def test_encoder_does_not_require_or_call_production_bytecode_emitter
    encoder_source = File.read(File.join(ROOT, 'compiler/small_compiler_subset_bsbc_encoder.rb'), encoding: 'UTF-8')
    refute_includes encoder_source, "require_relative 'bytecode_emitter'"
    refute_match(/\bBytecodeEmitter\.new\b/, encoder_source)
  end

  def test_primary_orchestrator_uses_independent_encoder_and_separate_referee
    emitter_source = File.read(File.join(ROOT, 'compiler/small_compiler_subset_bsbc_emitter.rb'), encoding: 'UTF-8')
    assert_includes emitter_source, 'SmallCompilerSubsetBSBCEncoder.new(ir_emitter.bsharp_ir)'
    assert_includes emitter_source, 'BytecodeEmitter.new(ir_emitter.ruby_referee_bsharp_ir)'
  end

  def test_dedicated_mixed_fixture_matches_locked_binary_and_referee
    record = BasicSharp::SmallCompilerSubsetBSBCEmitter.new(source).to_h
    assert_equal fixture.fetch('expected_profile'), record.fetch(:profile)
    assert_equal fixture.fetch('expected_binary_bytes'), record.fetch(:binary_bytes)
    assert_equal fixture.fetch('expected_binary_sha256'), record.fetch(:binary_sha256)
    assert_equal fixture.fetch('expected_disassembly_sha256'), record.fetch(:disassembly_sha256)
    assert_equal fixture.fetch('expected_bsharp_ir_sha256'), record.fetch(:bsharp_ir_sha256)
    assert_equal fixture.fetch('expected_fingerprint'), record.fetch(:fingerprint)
    assert_equal fixture.fetch('expected_loader_summary_sha256'), record.fetch(:loader_summary_sha256)
    assert record.fetch(:bsbc_ruby_referee_matches)
    assert record.fetch(:disassembly_ruby_referee_matches)
    assert record.fetch(:fingerprint_ruby_referee_matches)
    assert_equal record.fetch(:binary_sha256), record.fetch(:ruby_referee_binary_sha256)
  end

  def test_primary_binary_and_loader_work_with_production_binary_method_disabled
    klass = BasicSharp::BytecodeEmitter
    klass.class_eval do
      alias_method :__v075_test_original_binary, :binary
      define_method(:binary) { raise 'production emitter invoked' }
    end

    begin
      emitter = BasicSharp::SmallCompilerSubsetBSBCEmitter.new(source)
      assert_equal fixture.fetch('expected_binary_bytes'), emitter.binary.bytesize
      assert_equal fixture.fetch('expected_profile'), emitter.loader_summary.fetch('profile')
    ensure
      klass.class_eval do
        alias_method :binary, :__v075_test_original_binary
        remove_method :__v075_test_original_binary
      end
    end
  end

  def test_existing_bsbc_fixture_set_is_byte_for_byte_equal_to_ruby_referee
    emitter_spec = JSON.parse(File.read(File.join(ROOT, 'spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_BSBC_EMITTER_v1.json'), encoding: 'UTF-8'))
    emitter_spec.fetch('valid_fixtures').each do |entry|
      emitter = BasicSharp::SmallCompilerSubsetBSBCEmitter.new(entry.fetch('source'))
      assert emitter.binary_matches_ruby_referee?, entry.fetch('name')
      assert_equal emitter.bytecode_emitter.fingerprint, emitter.ruby_referee_bytecode_emitter.fingerprint, entry.fetch('name')
    end
  end

  def test_trial_by_fire_inventory_runs_independence_gate
    inventory = JSON.parse(File.read(File.join(ROOT, 'spec/trial_by_fire/BASIC_SHARP_TRIAL_BY_FIRE_VALIDATION_INVENTORY_v1.json'), encoding: 'UTF-8'))
    tools = inventory.fetch('required_tools').map { |entry| entry.fetch('path') }
    assert_includes tools, 'tools/small_compiler_subset_bsbc_emitter_independence.rb'
  end
end
