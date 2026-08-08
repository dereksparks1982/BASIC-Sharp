# frozen_string_literal: true

require 'digest'
require 'json'
require_relative 'small_compiler_subset_ir_emitter'
require_relative 'small_compiler_subset_bsbc_emitter'
require_relative 'bytecode_loader'
require_relative 'bytecode_virtual_machine'
require_relative 'runtime_transition'
require_relative 'world_save'

module BasicSharp
  class SmallCompilerSubsetBSBCExecutionParity
    FORMAT = 'bsharp.small_compiler_subset.bsbc_execution_parity.record'
    STATUS = 'bsbc_execution_parity_under_ruby_referee'
    REQUIRED_EXPECTED_FIELDS = [
      'expected_binary_sha256',
      'expected_loader_summary_sha256',
      'expected_vm_event_results_sha256',
      'expected_referee_event_results_sha256',
      'expected_final_snapshot_sha256',
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
      bsbc_emitter = SmallCompilerSubsetBSBCEmitter.new(source)
      bsbc = bsbc_emitter.to_h
      loader = BytecodeLoader.new(bsbc_emitter.binary, expected_fingerprint: bsbc_emitter.bytecode_emitter.fingerprint)
      vm = BytecodeVirtualMachine.new(loader)
      referee = RuntimeTransition.new(ir_emitter.bsharp_ir, mode: :verify)

      vm_event_results = events.map { |event| vm.run_event(event) }
      referee_event_results = events.map { |event| referee.run_event(event) }
      vm_snapshot = vm.snapshot
      referee_snapshot = referee.snapshot
      vm_save_document = WorldSave.document_for(vm)
      referee_save_document = WorldSave.document_for(referee)

      matched_count = vm_event_results.count { |result| result.fetch('matched') }
      runtime = {
        vm_event_results_sha256: self.class.digest_for(vm_event_results),
        referee_event_results_sha256: self.class.digest_for(referee_event_results),
        final_snapshot_sha256: self.class.digest_for(vm_snapshot),
        save_document_sha256: self.class.digest_for(vm_save_document),
        matched_event_count: matched_count,
        event_count: vm_event_results.length
      }

      checks = {
        parser_ruby_referee_matches: ir_emitter.parser_matches_ruby_referee?,
        ir_ruby_referee_matches: ir_emitter.ir_matches_ruby_referee?,
        bsbc_binary_matches: bsbc.fetch(:binary_sha256) == fixture.fetch('expected_binary_sha256'),
        loader_summary_matches: bsbc.fetch(:loader_summary_sha256) == fixture.fetch('expected_loader_summary_sha256'),
        vm_referee_event_results_match: self.class.normalize(vm_event_results) == self.class.normalize(referee_event_results),
        vm_referee_snapshot_matches: self.class.normalize(vm_snapshot) == self.class.normalize(referee_snapshot),
        vm_referee_save_document_matches: self.class.normalize(vm_save_document) == self.class.normalize(referee_save_document),
        vm_event_results_match: runtime.fetch(:vm_event_results_sha256) == fixture.fetch('expected_vm_event_results_sha256'),
        referee_event_results_match: runtime.fetch(:referee_event_results_sha256) == fixture.fetch('expected_referee_event_results_sha256'),
        final_snapshot_matches: runtime.fetch(:final_snapshot_sha256) == fixture.fetch('expected_final_snapshot_sha256'),
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
        expected_vm_event_results_sha256: fixture.fetch('expected_vm_event_results_sha256'),
        expected_referee_event_results_sha256: fixture.fetch('expected_referee_event_results_sha256'),
        expected_final_snapshot_sha256: fixture.fetch('expected_final_snapshot_sha256'),
        expected_save_document_sha256: fixture.fetch('expected_save_document_sha256'),
        checks: checks,
        passes: checks.values.all?
      }
    end
  end
end
