# frozen_string_literal: true

require 'digest'
require 'json'
require_relative 'small_compiler_subset_ir_emitter'

module BasicSharp
  class SmallCompilerSubsetErrorContract
    FORMAT = 'bsharp.small_compiler_subset.error_contract.record'
    STATUS = 'plain_english_error_contract_under_ruby_referee'

    ErrorRecord = Struct.new(:id, :line_number, :severity, :plain_message, :source_message, keyword_init: true) do
      def to_h
        {
          id: id,
          line_number: line_number,
          severity: severity,
          plain_message: plain_message,
          source_message: source_message
        }
      end
    end

    RULES = [
      {
        id: 'BSE1001',
        source_include: 'Body must start with [',
        plain_message: 'This Body needs to begin with [ on the line after its Head.'
      },
      {
        id: 'BSE1002',
        source_include: 'Body is missing its End ].',
        plain_message: 'This Body is missing its closing ]. line.'
      },
      {
        id: 'BSE1003',
        source_include: 'A Body must close with ].',
        plain_message: 'This Body closes with ], but BASIC# needs ]. to finish the Body.'
      },
      {
        id: 'BSE2001',
        source_include: 'Every WHEN Body instruction must begin with |then',
        plain_message: 'Every WHEN instruction inside the Body must begin with |then.'
      },
      {
        id: 'BSE2002',
        source_include: 'Every IF Body instruction must begin with |then',
        plain_message: 'Every IF instruction inside the Body must begin with |then.'
      },
      {
        id: 'BSE2003',
        source_include: 'Result must be followed by an official word such as (damage',
        plain_message: 'After |then, use an official word that starts with (, such as (damage.'
      },
      {
        id: 'BSE2004',
        source_include: 'needs at least one |then followed by an official word',
        plain_message: 'This Body needs at least one |then instruction followed by an official word.'
      },
      {
        id: 'BSE3001',
        source_include: 'OTHERWISE must directly follow the IF Body it belongs to.',
        plain_message: 'OTHERWISE must come immediately after the IF Body it belongs to.'
      },
      {
        id: 'BSE4001',
        source_include: "Kind must look like '#dragon is a #creature'",
        plain_message: 'A Kind line must look like #dragon is a #creature.'
      },
      {
        id: 'BSE5001',
        source_include: 'expected a Head before the Body',
        plain_message: 'BASIC# expected a Head line here before reading Body lines.'
      }
    ].freeze

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
        value.each_with_object({}) { |(key, child), result| result[key.to_s] = normalize(child) }.sort.to_h
      when Array
        value.map { |child| normalize(child) }
      else
        value
      end
    end

    def self.canonicalize_diagnostics(diagnostics)
      diagnostics.filter_map do |diagnostic|
        source_message = diagnostic.message
        rule = RULES.find { |entry| source_message.include?(entry.fetch(:source_include)) }
        next unless rule

        ErrorRecord.new(
          id: rule.fetch(:id),
          line_number: diagnostic.line_number,
          severity: diagnostic.severity,
          plain_message: rule.fetch(:plain_message),
          source_message: source_message
        )
      end
    end

    private

    def fixture_record(fixture)
      name = fixture.fetch('name')
      source = fixture.fetch('source')
      emitter = SmallCompilerSubsetIREmitter.new(source)
      emitter.program
      diagnostics = emitter.diagnostics.items
      canonical_errors = self.class.canonicalize_diagnostics(diagnostics).map(&:to_h)
      expected_errors = fixture.fetch('expected_errors')
      actual_digest = self.class.digest_for(canonical_errors)
      expected_digest = fixture.fetch('expected_errors_sha256')

      {
        name: name,
        canonical_errors: canonical_errors,
        expected_errors: expected_errors,
        canonical_errors_sha256: actual_digest,
        expected_errors_sha256: expected_digest,
        exact_errors_match: self.class.normalize(canonical_errors) == self.class.normalize(expected_errors),
        digest_matches: actual_digest == expected_digest,
        unknown_diagnostics: unknown_diagnostics(diagnostics, canonical_errors),
        passes: self.class.normalize(canonical_errors) == self.class.normalize(expected_errors) && actual_digest == expected_digest
      }
    end

    def unknown_diagnostics(diagnostics, canonical_errors)
      known_messages = canonical_errors.map { |entry| entry.fetch(:source_message) }
      diagnostics.reject { |diagnostic| known_messages.include?(diagnostic.message) }.map(&:to_h)
    end
  end
end
