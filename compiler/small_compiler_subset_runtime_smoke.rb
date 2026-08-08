# frozen_string_literal: true

require 'digest'
require 'json'
require_relative 'small_compiler_subset_ir_emitter'
require_relative 'small_compiler_subset_bsbc_emitter'
require_relative 'runtime_transition'
require_relative 'world_save'

module BasicSharp
  class SmallCompilerSubsetRuntimeSmoke
    FORMAT = 'bsharp.small_compiler_subset.runtime_smoke.record'
    STATUS = 'runtime_smoke_under_ruby_referee'
    REQUIRED_EXPECTED_FIELDS = [
      'expected_binary_sha256',
      'expected_loader_summary_sha256',
      'expected_event_results_sha256',
      'expected_snapshot_sha256',
      'expected_save_document_sha256',
      'expected_matched_event_count'
    ].freeze

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

    def self.required_expected_fields
      REQUIRED_EXPECTED_FIELDS
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

    private

    def fixture_record(fixture)
      self.class.required_expected_fields.each { |field| fixture.fetch(field) }
      source = fixture.fetch('source')
      events = fixture.fetch('events')
      ir_emitter = SmallCompilerSubsetIREmitter.new(source)
      bsbc = SmallCompilerSubsetBSBCEmitter.new(source).to_h
      machine = RuntimeTransition.new(ir_emitter.bsharp_ir, mode: :verify)
      event_results = events.map { |event| machine.run_event(event) }
      matched_count = event_results.count { |result| result.fetch('matched') }
      snapshot = machine.snapshot
      save_document = WorldSave.document_for(machine)
      runtime = {
        event_results_sha256: self.class.digest_for(event_results),
        snapshot_sha256: self.class.digest_for(snapshot),
        save_document_sha256: self.class.digest_for(save_document),
        matched_event_count: matched_count,
        event_count: event_results.length
      }
      checks = {
        parser_ruby_referee_matches: ir_emitter.parser_matches_ruby_referee?,
        ir_ruby_referee_matches: ir_emitter.ir_matches_ruby_referee?,
        bsbc_binary_matches: bsbc.fetch(:binary_sha256) == fixture.fetch('expected_binary_sha256'),
        loader_summary_matches: bsbc.fetch(:loader_summary_sha256) == fixture.fetch('expected_loader_summary_sha256'),
        event_results_match: runtime.fetch(:event_results_sha256) == fixture.fetch('expected_event_results_sha256'),
        snapshot_matches: runtime.fetch(:snapshot_sha256) == fixture.fetch('expected_snapshot_sha256'),
        save_document_matches: runtime.fetch(:save_document_sha256) == fixture.fetch('expected_save_document_sha256'),
        matched_event_count_matches: matched_count == fixture.fetch('expected_matched_event_count')
      }
      {
        name: fixture.fetch('name'),
        category: fixture.fetch('category'),
        events: events,
        profile: bsbc.fetch(:profile),
        binary_sha256: bsbc.fetch(:binary_sha256),
        expected_binary_sha256: fixture.fetch('expected_binary_sha256'),
        loader_summary_sha256: bsbc.fetch(:loader_summary_sha256),
        expected_loader_summary_sha256: fixture.fetch('expected_loader_summary_sha256'),
        runtime: runtime,
        expected_event_results_sha256: fixture.fetch('expected_event_results_sha256'),
        expected_snapshot_sha256: fixture.fetch('expected_snapshot_sha256'),
        expected_save_document_sha256: fixture.fetch('expected_save_document_sha256'),
        checks: checks,
        passes: checks.values.all?
      }
    end
  end
end
