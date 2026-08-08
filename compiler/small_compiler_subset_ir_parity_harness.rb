# frozen_string_literal: true

require 'digest'
require 'json'
require_relative 'small_compiler_subset_ir_emitter'

module BasicSharp
  class SmallCompilerSubsetIRParityHarness
    FORMAT = 'bsharp.small_compiler_subset.ir_golden_parity.record'
    STATUS = 'ir_golden_parity_under_ruby_referee'

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
      case value
      when Hash
        value.each_with_object({}) do |(key, child), result|
          result[key.to_s] = normalize(child)
        end.sort.to_h
      when Array
        value.map { |child| normalize(child) }
      else
        value
      end
    end

    private

    def fixture_record(fixture)
      name = fixture.fetch('name')
      source = fixture.fetch('source')
      expected_sha = fixture.fetch('expected_ir_sha256')
      emitter = SmallCompilerSubsetIREmitter.new(source)
      subset_ir = emitter.bsharp_ir
      referee_ir = emitter.ruby_referee_bsharp_ir
      subset_sha = self.class.digest_for(subset_ir)
      referee_sha = self.class.digest_for(referee_ir)
      counts = counts_for(subset_ir)
      expected_counts = fixture.fetch('expected_counts')
      counts_match = expected_counts.all? { |key, value| counts.fetch(key) == value }
      parser_match = emitter.parser_matches_ruby_referee?
      ir_match = emitter.ir_matches_ruby_referee?
      golden_match = subset_sha == expected_sha
      referee_digest_match = subset_sha == referee_sha

      {
        name: name,
        parser_ruby_referee_matches: parser_match,
        ir_ruby_referee_matches: ir_match,
        subset_ir_sha256: subset_sha,
        ruby_referee_ir_sha256: referee_sha,
        expected_ir_sha256: expected_sha,
        golden_sha256_matches: golden_match,
        referee_digest_matches: referee_digest_match,
        counts: counts,
        expected_counts: expected_counts,
        counts_match: counts_match,
        passes: parser_match && ir_match && golden_match && referee_digest_match && counts_match
      }
    end

    def counts_for(ir)
      {
        'kinds' => ir.fetch(:kinds).length,
        'objects' => ir.fetch(:objects).length,
        'facts' => ir.fetch(:facts).length,
        'events' => ir.fetch(:events).length,
        'if_rules' => ir.fetch(:if_rules).length,
        'controls' => ir.fetch(:controls).length,
        'hover_declarations' => ir.fetch(:hover_declarations).length,
        'context_declarations' => ir.fetch(:context_declarations).length,
        'diagnostics' => ir.fetch(:diagnostics).length,
        'meaning_profile' => ir.fetch(:meaning_profile, 'bsharp.meaning.v1')
      }
    end
  end
end
