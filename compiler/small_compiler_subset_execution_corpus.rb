# frozen_string_literal: true

require 'json'
require_relative 'ast_nodes'
require_relative 'small_compiler_subset_bsbc_execution_parity'

module BasicSharp
  class SmallCompilerSubsetExecutionCorpus
    FORMAT = 'bsharp.small_compiler_subset.execution_corpus.record'
    STATUS = 'execution_corpus_expanded_under_ruby_referee'

    attr_reader :spec, :parity_spec

    def initialize(spec, parity_spec)
      @spec = spec
      @parity_spec = parity_spec
    end

    def parity_record
      @parity_record ||= SmallCompilerSubsetBSBCExecutionParity.new(parity_spec).to_h
    end

    def fixtures
      parity_spec.fetch('fixtures')
    end

    def categories
      fixtures.map { |fixture| fixture.fetch('category') }
    end

    def category_counts
      categories.tally.sort.to_h
    end

    def event_count
      fixtures.sum { |fixture| fixture.fetch('events').length }
    end

    def checks
      @checks ||= {
        spec_identity_matches: spec.fetch('format') == 'bsharp.small_compiler_subset.execution_corpus.json',
        spec_format_version_matches: spec.fetch('format_version') == 1,
        target_version_matches: spec.fetch('target_version') == BasicSharp::VERSION,
        status_matches: spec.fetch('status') == STATUS,
        parity_source_declared: spec.fetch('parity_spec') == 'spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_BSBC_EXECUTION_PARITY_v1.json',
        parity_record_passes: parity_record.fetch(:all_pass),
        fixture_floor_met: fixtures.length >= spec.fetch('minimums').fetch('fixtures'),
        category_floor_met: category_counts.keys.length >= spec.fetch('minimums').fetch('categories'),
        event_floor_met: event_count >= spec.fetch('minimums').fetch('events'),
        ruby_referee_guard_declared: spec.fetch('guardrails').include?('Ruby remains the referee'),
        not_full_self_hosting_declared: spec.fetch('guardrails').include?('not full self-hosting'),
        bridge_removal_forbidden: spec.fetch('forbidden').include?('removing the DKLab compatibility bridge')
      }
    end

    def all_pass?
      checks.values.all?
    end

    def to_h
      {
        format: FORMAT,
        version: BasicSharp::VERSION,
        status: STATUS,
        all_pass: all_pass?,
        fixture_count: fixtures.length,
        category_count: category_counts.keys.length,
        event_count: event_count,
        category_counts: category_counts,
        checks: checks
      }
    end
  end
end
