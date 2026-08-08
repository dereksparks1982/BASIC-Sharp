# frozen_string_literal: true

require 'digest'
require 'json'
require_relative 'small_compiler_subset_error_contract'
require_relative 'small_compiler_subset_ir_emitter'

module BasicSharp
  class SmallCompilerSubsetSceneBlockExpansion
    FORMAT = 'bsharp.small_compiler_subset.scene_block_expansion.record'
    STATUS = 'scene_block_expansion_under_ruby_referee'

    attr_reader :spec

    def initialize(spec)
      @spec = spec
    end

    def records
      @records ||= {
        valid: valid_records,
        invalid: invalid_records
      }
    end

    def all_pass?
      records.fetch(:valid).all? { |record| record.fetch(:passes) } &&
        records.fetch(:invalid).all? { |record| record.fetch(:passes) }
    end

    def to_h
      {
        format: FORMAT,
        version: BasicSharp::VERSION,
        status: STATUS,
        valid_fixture_count: records.fetch(:valid).length,
        invalid_fixture_count: records.fetch(:invalid).length,
        all_pass: all_pass?,
        valid_fixtures: records.fetch(:valid),
        invalid_fixtures: records.fetch(:invalid)
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

    def valid_records
      spec.fetch('valid_fixtures').map { |fixture| valid_fixture_record(fixture) }
    end

    def invalid_records
      spec.fetch('invalid_fixtures').map { |fixture| invalid_fixture_record(fixture) }
    end

    def valid_fixture_record(fixture)
      emitter = SmallCompilerSubsetIREmitter.new(fixture.fetch('source'))
      subset_ir = emitter.bsharp_ir
      referee_ir = emitter.ruby_referee_bsharp_ir
      parser_match = emitter.parser_matches_ruby_referee?
      ir_match = emitter.ir_matches_ruby_referee?
      counts = counts_for(subset_ir)
      expected_counts = fixture.fetch('expected_counts')
      counts_match = expected_counts.all? { |key, value| counts.fetch(key) == value }
      starters = emitter.subset_parser.statements.map(&:starter)
      expected_starters = fixture.fetch('expected_starters')
      starters_match = starters == expected_starters
      actions = emitter.subset_parser.statements.flat_map { |statement| statement.children.map(&:action) }.compact
      expected_actions = fixture.fetch('expected_actions')
      actions_match = actions == expected_actions
      subset_sha = self.class.digest_for(subset_ir)
      referee_sha = self.class.digest_for(referee_ir)
      expected_sha = fixture.fetch('expected_ir_sha256')

      {
        name: fixture.fetch('name'),
        parser_ruby_referee_matches: parser_match,
        ir_ruby_referee_matches: ir_match,
        subset_ir_sha256: subset_sha,
        ruby_referee_ir_sha256: referee_sha,
        expected_ir_sha256: expected_sha,
        golden_sha256_matches: subset_sha == expected_sha,
        referee_digest_matches: subset_sha == referee_sha,
        starters: starters,
        expected_starters: expected_starters,
        starters_match: starters_match,
        actions: actions,
        expected_actions: expected_actions,
        actions_match: actions_match,
        counts: counts,
        expected_counts: expected_counts,
        counts_match: counts_match,
        passes: parser_match && ir_match && subset_sha == expected_sha && subset_sha == referee_sha && starters_match && actions_match && counts_match
      }
    end

    def invalid_fixture_record(fixture)
      contract = SmallCompilerSubsetErrorContract.new([fixture])
      record = contract.to_h.fetch(:fixtures).first
      {
        name: fixture.fetch('name'),
        expected_errors_sha256: fixture.fetch('expected_errors_sha256'),
        canonical_errors_sha256: record.fetch(:canonical_errors_sha256),
        exact_errors_match: record.fetch(:exact_errors_match),
        digest_matches: record.fetch(:digest_matches),
        unknown_diagnostics: record.fetch(:unknown_diagnostics),
        passes: record.fetch(:passes)
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
