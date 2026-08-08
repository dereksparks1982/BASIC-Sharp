# frozen_string_literal: true

require 'digest'
require 'json'
require_relative 'small_compiler_subset_bsbc_emitter'
require_relative 'small_compiler_subset_symbol_table_contract'

module BasicSharp
  class SelfHostingFixtureCorpus
    FORMAT = 'bsharp.self_hosting.fixture_corpus.record'
    STATUS = 'self_hosting_fixture_corpus_under_ruby_referee'

    attr_reader :spec

    def initialize(spec)
      @spec = spec
    end

    def fixtures
      spec.fetch('fixtures')
    end

    def records
      @records ||= fixtures.map { |fixture| fixture_record(fixture) }
    end

    def all_pass?
      records.all? { |record| record.fetch(:passes) }
    end

    def profile_counts
      records.each_with_object(Hash.new(0)) { |record, counts| counts[record.fetch(:profile)] += 1 }.sort.to_h
    end

    def to_h
      {
        format: FORMAT,
        version: BasicSharp::VERSION,
        status: STATUS,
        company_identity: spec.fetch('company_identity'),
        workspace_identity: spec.fetch('workspace_identity'),
        workspace_meaning: spec.fetch('workspace_meaning'),
        fixture_count: records.length,
        profile_counts: profile_counts,
        all_pass: all_pass?,
        fixtures: records
      }
    end

    def self.digest_for(value)
      Digest::SHA256.hexdigest(JSON.generate(normalize(value)))
    end

    def self.normalize(value)
      case value
      when Hash
        value.each_with_object({}) { |(key, child), result| result[key.to_s] = normalize(child) }.sort.to_h
      when Array
        value.map { |child| normalize(child) }
      else
        value
      end
    end

    private

    def fixture_record(fixture)
      source = fixture.fetch('source')
      bsbc = SmallCompilerSubsetBSBCEmitter.new(source).to_h
      symbols = SmallCompilerSubsetSymbolTableContract.new(source).to_h
      checks = {
        parser_ruby_referee_matches: bsbc.fetch(:parser_ruby_referee_matches),
        ir_ruby_referee_matches: bsbc.fetch(:ir_ruby_referee_matches),
        profile_matches: bsbc.fetch(:profile) == fixture.fetch('expected_profile'),
        binary_sha256_matches: bsbc.fetch(:binary_sha256) == fixture.fetch('expected_binary_sha256'),
        loader_summary_sha256_matches: bsbc.fetch(:loader_summary_sha256) == fixture.fetch('expected_loader_summary_sha256'),
        bsharp_ir_sha256_matches: bsbc.fetch(:bsharp_ir_sha256) == fixture.fetch('expected_bsharp_ir_sha256'),
        symbol_table_sha256_matches: symbols.fetch(:symbols_sha256) == fixture.fetch('expected_symbols_sha256'),
        symbol_table_errors_sha256_matches: symbols.fetch(:errors_sha256) == fixture.fetch('expected_errors_sha256')
      }
      {
        name: fixture.fetch('name'),
        category: fixture.fetch('category'),
        profile: bsbc.fetch(:profile),
        expected_profile: fixture.fetch('expected_profile'),
        binary_bytes: bsbc.fetch(:binary_bytes),
        binary_sha256: bsbc.fetch(:binary_sha256),
        expected_binary_sha256: fixture.fetch('expected_binary_sha256'),
        loader_summary_sha256: bsbc.fetch(:loader_summary_sha256),
        expected_loader_summary_sha256: fixture.fetch('expected_loader_summary_sha256'),
        bsharp_ir_sha256: bsbc.fetch(:bsharp_ir_sha256),
        expected_bsharp_ir_sha256: fixture.fetch('expected_bsharp_ir_sha256'),
        symbol_table_sha256: symbols.fetch(:symbols_sha256),
        expected_symbols_sha256: fixture.fetch('expected_symbols_sha256'),
        errors_sha256: symbols.fetch(:errors_sha256),
        expected_errors_sha256: fixture.fetch('expected_errors_sha256'),
        checks: checks,
        passes: checks.values.all?
      }
    end
  end
end
