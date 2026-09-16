# frozen_string_literal: true

require 'digest'
require 'json'
require_relative 'ast_nodes'

module BasicSharp
  class BootstrapBoundaryAudit
    FORMAT = 'bsharp.bootstrap_boundary_audit.record'
    STATUS = 'bootstrap_boundary_audit_under_ruby_referee'

    attr_reader :spec, :root

    def initialize(spec, root: File.expand_path('..', __dir__))
      @spec = spec
      @root = root
    end

    def stages
      spec.fetch('stages')
    end

    def records
      @records ||= stages.map { |stage| stage_record(stage) }
    end

    def checks
      @checks ||= {
        identity_matches: spec.fetch('format') == 'bsharp.bootstrap_boundary_audit.json',
        format_version_matches: spec.fetch('format_version') == 1,
        target_version_matches: spec.fetch('target_version') == BasicSharp::VERSION,
        status_matches: spec.fetch('status') == STATUS,
        ruby_referee_declared: stage_named?('ruby_bootstrap_referee'),
        subset_output_declared: stage_named?('basic_sharp_subset_outputs'),
        driver_artifact_declared: stage_named?('basic_sharp_subset_driver_artifact'),
        native_component_declared: stage_named?('basic_sharp_authored_compiler_component'),
        native_dispatch_integration_declared: stage_named?('basic_sharp_native_parser_dispatch'),
        native_semantic_routing_declared: stage_named?('basic_sharp_native_semantic_routing'),
        native_symbol_resolution_declared: stage_named?('basic_sharp_native_symbol_resolution'),
        runtime_smoke_declared: stage_named?('runtime_smoke_bridge'),
        production_boundary_declared: stage_named?('production_runtime_boundary'),
        milestone_guard_declared: spec.fetch('next_milestone') == 'v0.0.84 Self-Hosting Milestone 2 Slice 11: BASIC# Native Action Routing Integration',
        no_self_hosting_claim: forbidden.include?('claiming BASIC# is self-hosted'),
        ruby_replacement_forbidden: forbidden.include?('replacing the Ruby bootstrap compiler'),
        profile_8_forbidden: forbidden.include?('adding Profile 8'),
        production_runtime_change_forbidden: forbidden.include?('changing production runtime behaviour'),
        every_stage_has_existing_paths: records.all? { |record| record.fetch(:missing_paths).empty? },
        every_stage_has_owner: stages.all? { |stage| !stage.fetch('owner').to_s.empty? },
        every_stage_has_boundary: stages.all? { |stage| !stage.fetch('boundary').to_s.empty? },
        authority_ladder_locked: authority_ladder == spec.fetch('expected_authority_ladder'),
        no_expected_self_comparison_fallbacks: expected_fallback_offenders.empty?
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
        stage_count: stages.length,
        checks: checks,
        authority_ladder: authority_ladder,
        stages: records,
        boundary_digest_sha256: self.class.digest_for(records),
        expected_fallback_offenders: expected_fallback_offenders
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

    def forbidden
      spec.fetch('forbidden_until_after_milestone')
    end

    def stage_named?(name)
      stages.any? { |stage| stage.fetch('name') == name }
    end

    def authority_ladder
      stages.map { |stage| [stage.fetch('name'), stage.fetch('owner'), stage.fetch('authority')] }
    end

    def expected_fallback_offenders
      @expected_fallback_offenders ||= Dir[File.join(root, '{compiler,tools,tests}', '**', '*.rb')].sort.filter_map do |path|
        relative = path.delete_prefix(root + '/')
        lines = File.readlines(path, encoding: 'UTF-8')
        matches = lines.each_with_index.filter_map do |line, index|
          next unless line.match?(/fixture\.fetch\(['\"]expected_[^'\"]+['\"],/)

          { path: relative, line: index + 1, text: line.strip }
        end
        next if matches.empty?

        { path: relative, matches: matches }
      end
    end

    def stage_record(stage)
      existing = stage.fetch('paths').select { |path| File.file?(File.join(root, path)) }
      missing = stage.fetch('paths') - existing
      {
        name: stage.fetch('name'),
        owner: stage.fetch('owner'),
        authority: stage.fetch('authority'),
        boundary: stage.fetch('boundary'),
        path_count: stage.fetch('paths').length,
        existing_path_count: existing.length,
        missing_paths: missing,
        path_sha256: existing.map { |path| [path, file_sha256(path)] }.to_h
      }
    end

    def file_sha256(path)
      Digest::SHA256.hexdigest(File.binread(File.join(root, path)))
    end
  end
end
