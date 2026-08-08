#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require_relative '../compiler/small_compiler_subset_symbol_table_contract'

ROOT = File.expand_path('..', __dir__)
SPEC_PATH = File.join(ROOT, 'spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_SYMBOL_TABLE_CONTRACT_v1.json')

spec = JSON.parse(File.read(SPEC_PATH, encoding: 'UTF-8'))

def assert_contract!(condition, message)
  raise "Small compiler subset symbol table contract failed: #{message}" unless condition
end

assert_contract!(spec.fetch('format') == 'bsharp.small_compiler_subset.symbol_table_contract.json', 'wrong spec identity')
assert_contract!(spec.fetch('format_version') == 1, 'wrong spec format version')
assert_contract!(spec.fetch('target_version') == BasicSharp::VERSION, 'spec target does not match BasicSharp::VERSION')
assert_contract!(spec.fetch('status') == 'symbol_table_contract_under_ruby_referee', 'wrong contract status')

all = spec.fetch('valid_fixtures') + spec.fetch('invalid_fixtures')
all.each do |fixture|
  contract = BasicSharp::SmallCompilerSubsetSymbolTableContract.new(fixture.fetch('source'))
  record = contract.to_h
  expected_symbols = fixture.fetch('expected_symbols')
  expected_errors = fixture.fetch('expected_errors')
  assert_contract!(record.fetch(:parser_ruby_referee_matches), "parser referee mismatch for #{fixture.fetch('name')}")
  assert_contract!(BasicSharp::SmallCompilerSubsetSymbolTableContract.normalize(record.fetch(:symbols)) == BasicSharp::SmallCompilerSubsetSymbolTableContract.normalize(expected_symbols), "symbol table changed for #{fixture.fetch('name')}")
  assert_contract!(record.fetch(:symbols_sha256) == fixture.fetch('expected_symbols_sha256'), "symbol digest changed for #{fixture.fetch('name')}")
  assert_contract!(BasicSharp::SmallCompilerSubsetSymbolTableContract.normalize(record.fetch(:errors)) == BasicSharp::SmallCompilerSubsetSymbolTableContract.normalize(expected_errors), "symbol errors changed for #{fixture.fetch('name')}")
  assert_contract!(record.fetch(:errors_sha256) == fixture.fetch('expected_errors_sha256'), "symbol error digest changed for #{fixture.fetch('name')}")
end

required_error_ids = all.flat_map { |fixture| fixture.fetch('expected_errors').map { |entry| entry.fetch('id') } }
%w[BSS1001 BSS1002 BSS2002 BSS2003].each do |id|
  assert_contract!(required_error_ids.include?(id), "missing required error #{id}")
end

puts "BASIC# Small Compiler Subset Symbol Table Contract v#{BasicSharp::VERSION}: PASS"
