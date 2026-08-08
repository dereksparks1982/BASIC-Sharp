# frozen_string_literal: true

require 'json'
require 'minitest/autorun'
require_relative '../compiler/small_compiler_subset_bsbc_emitter'

class TestSmallCompilerSubsetBSBCEmitter < Minitest::Test
  ROOT = File.expand_path('..', __dir__)
  SPEC_PATH = File.join(ROOT, 'spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_BSBC_EMITTER_v1.json')

  def spec
    @spec ||= JSON.parse(File.read(SPEC_PATH, encoding: 'UTF-8'))
  end

  def test_contract_identity
    assert_equal 'bsharp.small_compiler_subset.bsbc_emitter.json', spec.fetch('format')
    assert_equal 1, spec.fetch('format_version')
    assert_equal BasicSharp::VERSION, spec.fetch('target_version')
    assert_equal 'bsbc_emission_under_ruby_referee', spec.fetch('status')
  end

  def test_fixtures_emit_stable_real_bsbc_and_load_back
    spec.fetch('valid_fixtures').each do |fixture|
      record = BasicSharp::SmallCompilerSubsetBSBCEmitter.new(fixture.fetch('source')).to_h

      assert record.fetch(:parser_ruby_referee_matches), fixture.fetch('name')
      assert record.fetch(:ir_ruby_referee_matches), fixture.fetch('name')
      assert_equal 'bsharp.bytecode.bin', record.fetch(:binary_format), fixture.fetch('name')
      assert_equal fixture.fetch('expected_profile'), record.fetch(:profile), fixture.fetch('name')
      assert_equal fixture.fetch('expected_binary_bytes'), record.fetch(:binary_bytes), fixture.fetch('name')
      assert_equal fixture.fetch('expected_binary_sha256'), record.fetch(:binary_sha256), fixture.fetch('name')
      assert_equal fixture.fetch('expected_disassembly_sha256'), record.fetch(:disassembly_sha256), fixture.fetch('name')
      assert_equal fixture.fetch('expected_bsharp_ir_sha256'), record.fetch(:bsharp_ir_sha256), fixture.fetch('name')
      assert_equal fixture.fetch('expected_fingerprint'), record.fetch(:fingerprint), fixture.fetch('name')
      assert_equal BasicSharp::SmallCompilerSubsetBSBCEmitter.normalize(fixture.fetch('expected_loader_summary')), BasicSharp::SmallCompilerSubsetBSBCEmitter.normalize(record.fetch(:loader_summary)), fixture.fetch('name')
      assert_equal fixture.fetch('expected_loader_summary_sha256'), record.fetch(:loader_summary_sha256), fixture.fetch('name')
    end
  end

  def test_profile_coverage_reaches_existing_bytecode_lanes_without_profile_8
    profiles = spec.fetch('valid_fixtures').map { |fixture| fixture.fetch('expected_profile') }
    assert_includes profiles, 'bsharp.bytecode.v1'
    assert_includes profiles, 'bsharp.bytecode.v2'
    assert_includes profiles, 'bsharp.bytecode.v4'
    refute_includes profiles, 'bsharp.bytecode.v8'
  end
end
