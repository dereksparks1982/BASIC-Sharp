# frozen_string_literal: true

require 'json'
require 'minitest/autorun'
require_relative '../compiler/small_compiler_subset_symbol_table_contract'

class TestSmallCompilerSubsetSymbolTableContract < Minitest::Test
  ROOT = File.expand_path('..', __dir__)
  SPEC_PATH = File.join(ROOT, 'spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_SYMBOL_TABLE_CONTRACT_v1.json')

  def spec
    @spec ||= JSON.parse(File.read(SPEC_PATH, encoding: 'UTF-8'))
  end

  def test_contract_identity
    assert_equal 'bsharp.small_compiler_subset.symbol_table_contract.json', spec.fetch('format')
    assert_equal 1, spec.fetch('format_version')
    assert_equal BasicSharp::VERSION, spec.fetch('target_version')
    assert_equal 'native_symbol_resolution_integration_under_ruby_referee', spec.fetch('status')
  end

  def test_valid_fixtures_have_stable_symbol_tables_without_errors
    spec.fetch('valid_fixtures').each do |fixture|
      record = BasicSharp::SmallCompilerSubsetSymbolTableContract.new(fixture.fetch('source')).to_h

      assert record.fetch(:parser_ruby_referee_matches), fixture.fetch('name')
      assert_equal BasicSharp::SmallCompilerSubsetSymbolTableContract.normalize(fixture.fetch('expected_symbols')), BasicSharp::SmallCompilerSubsetSymbolTableContract.normalize(record.fetch(:symbols)), fixture.fetch('name')
      assert_equal fixture.fetch('expected_symbols_sha256'), record.fetch(:symbols_sha256), fixture.fetch('name')
      assert_empty record.fetch(:errors), fixture.fetch('name')
      assert_equal fixture.fetch('expected_errors_sha256'), record.fetch(:errors_sha256), fixture.fetch('name')
      assert_operator record.fetch(:native_symbol_invocation_count), :>, 0, fixture.fetch('name')
    end
  end

  def test_invalid_fixtures_have_stable_plain_english_symbol_errors
    spec.fetch('invalid_fixtures').each do |fixture|
      record = BasicSharp::SmallCompilerSubsetSymbolTableContract.new(fixture.fetch('source')).to_h

      assert_equal BasicSharp::SmallCompilerSubsetSymbolTableContract.normalize(fixture.fetch('expected_symbols')), BasicSharp::SmallCompilerSubsetSymbolTableContract.normalize(record.fetch(:symbols)), fixture.fetch('name')
      assert_equal fixture.fetch('expected_symbols_sha256'), record.fetch(:symbols_sha256), fixture.fetch('name')
      assert_equal BasicSharp::SmallCompilerSubsetSymbolTableContract.normalize(fixture.fetch('expected_errors')), BasicSharp::SmallCompilerSubsetSymbolTableContract.normalize(record.fetch(:errors)), fixture.fetch('name')
      assert_equal fixture.fetch('expected_errors_sha256'), record.fetch(:errors_sha256), fixture.fetch('name')
      assert_operator record.fetch(:native_symbol_invocation_count), :>, 0, fixture.fetch('name')
    end
  end
end
