# frozen_string_literal: true

require 'digest'
require 'json'
require_relative 'small_compiler_subset_bsbc_emitter'

module BasicSharp
  class SmallCompilerSubsetBSBCParityHarness
    FORMAT = 'bsharp.small_compiler_subset.bsbc_golden_parity.record'
    STATUS = 'bsbc_golden_parity_under_ruby_referee'

    attr_reader :fixtures

    def initialize(fixtures)
      @fixtures = fixtures
    end

    def records
      @records ||= fixtures.map { |fixture| fixture_record(fixture) }
    end

    def all_pass?
      records.all? { |record| record.fetch(:passes) }
    end

    def to_h
      {
        format: FORMAT,
        version: BasicSharp::VERSION,
        status: STATUS,
        fixture_count: records.length,
        all_pass: all_pass?,
        fixtures: records
      }
    end

    def self.digest_for(value)
      Digest::SHA256.hexdigest(JSON.generate(normalize(value)))
    end

    def self.normalize(value)
      SmallCompilerSubsetBSBCEmitter.normalize(value)
    end

    private

    def fixture_record(fixture)
      name = fixture.fetch('name')
      record = SmallCompilerSubsetBSBCEmitter.new(fixture.fetch('source')).to_h
      loader_summary = record.fetch(:loader_summary)
      expected_loader_summary = fixture.fetch('expected_loader_summary')

      checks = {
        parser_ruby_referee_matches: record.fetch(:parser_ruby_referee_matches),
        ir_ruby_referee_matches: record.fetch(:ir_ruby_referee_matches),
        bsbc_ruby_referee_matches: record.fetch(:bsbc_ruby_referee_matches),
        disassembly_ruby_referee_matches: record.fetch(:disassembly_ruby_referee_matches),
        fingerprint_ruby_referee_matches: record.fetch(:fingerprint_ruby_referee_matches),
        profile_matches: record.fetch(:profile) == fixture.fetch('expected_profile'),
        binary_bytes_match: record.fetch(:binary_bytes) == fixture.fetch('expected_binary_bytes'),
        binary_sha256_matches: record.fetch(:binary_sha256) == fixture.fetch('expected_binary_sha256'),
        disassembly_sha256_matches: record.fetch(:disassembly_sha256) == fixture.fetch('expected_disassembly_sha256'),
        bsharp_ir_sha256_matches: record.fetch(:bsharp_ir_sha256) == fixture.fetch('expected_bsharp_ir_sha256'),
        fingerprint_matches: record.fetch(:fingerprint) == fixture.fetch('expected_fingerprint'),
        loader_summary_matches: self.class.normalize(loader_summary) == self.class.normalize(expected_loader_summary),
        loader_summary_sha256_matches: record.fetch(:loader_summary_sha256) == fixture.fetch('expected_loader_summary_sha256')
      }

      {
        name: name,
        profile: record.fetch(:profile),
        expected_profile: fixture.fetch('expected_profile'),
        binary_bytes: record.fetch(:binary_bytes),
        expected_binary_bytes: fixture.fetch('expected_binary_bytes'),
        binary_sha256: record.fetch(:binary_sha256),
        expected_binary_sha256: fixture.fetch('expected_binary_sha256'),
        disassembly_sha256: record.fetch(:disassembly_sha256),
        expected_disassembly_sha256: fixture.fetch('expected_disassembly_sha256'),
        bsharp_ir_sha256: record.fetch(:bsharp_ir_sha256),
        expected_bsharp_ir_sha256: fixture.fetch('expected_bsharp_ir_sha256'),
        fingerprint: record.fetch(:fingerprint),
        expected_fingerprint: fixture.fetch('expected_fingerprint'),
        loader_summary_sha256: record.fetch(:loader_summary_sha256),
        expected_loader_summary_sha256: fixture.fetch('expected_loader_summary_sha256'),
        checks: checks,
        passes: checks.values.all?
      }
    end
  end
end
