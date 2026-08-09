#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require_relative '../compiler/small_compiler_subset_execution_corpus'

ROOT = File.expand_path('..', __dir__)
SPEC_PATH = File.join(ROOT, 'spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_EXECUTION_CORPUS_v1.json')
PARITY_SPEC_PATH = File.join(ROOT, 'spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_BSBC_EXECUTION_PARITY_v1.json')

spec = JSON.parse(File.read(SPEC_PATH, encoding: 'UTF-8'))
parity_spec = JSON.parse(File.read(PARITY_SPEC_PATH, encoding: 'UTF-8'))
record = BasicSharp::SmallCompilerSubsetExecutionCorpus.new(spec, parity_spec).to_h

unless record.fetch(:all_pass)
  warn JSON.pretty_generate(record)
  raise 'Small compiler subset execution corpus gate failed'
end

puts "BASIC# Small Compiler Subset Execution Corpus v#{BasicSharp::VERSION}: PASS"
puts "Fixtures: #{record.fetch(:fixture_count)}"
puts "Categories: #{record.fetch(:category_count)}"
puts "Events: #{record.fetch(:event_count)}"
puts 'Source -> BSIR -> BSBC -> BSharp VM execution corpus: PASS'
puts 'Ruby referee parity remains required: PASS'
