# frozen_string_literal: true

require 'json'
require 'digest'
require_relative 'small_compiler_subset_runtime_smoke'
require_relative 'bootstrap_boundary_audit'
require_relative 'readme_current_release_truth'

module BasicSharp
  class SelfHostingMilestone1
    FORMAT = 'bsharp.self_hosting_milestone_1.record'
    STATUS = 'self_hosting_milestone_1_under_ruby_referee'

    attr_reader :spec, :root

    def initialize(spec, root: File.expand_path('..', __dir__))
      @spec = spec
      @root = root
    end

    def runtime_smoke_record
      @runtime_smoke_record ||= begin
        path = File.join(root, 'spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_RUNTIME_SMOKE_v1.json')
        SmallCompilerSubsetRuntimeSmoke.new(JSON.parse(File.read(path, encoding: 'UTF-8'))).to_h
      end
    end

    def bootstrap_boundary_record
      @bootstrap_boundary_record ||= begin
        path = File.join(root, 'spec/self_hosting/BASIC_SHARP_BOOTSTRAP_BOUNDARY_AUDIT_v1.json')
        BootstrapBoundaryAudit.new(JSON.parse(File.read(path, encoding: 'UTF-8')), root: root).to_h
      end
    end

    def readme_truth_record
      @readme_truth_record ||= begin
        spec_path = File.join(root, 'spec/self_hosting/BASIC_SHARP_README_CURRENT_RELEASE_TRUTH_v1.json')
        readme_path = File.join(root, 'README.md')
        ReadmeCurrentReleaseTruth.new(
          File.read(readme_path, encoding: 'UTF-8'),
          JSON.parse(File.read(spec_path, encoding: 'UTF-8'))
        ).to_h
      end
    end

    def required_tool_paths
      spec.fetch('required_tools')
    end

    def missing_tools
      required_tool_paths.reject { |path| File.file?(File.join(root, path)) }
    end

    def missing_evidence_specs
      spec.fetch('evidence_specs').reject { |path| File.file?(File.join(root, path)) }
    end

    def inventory_tool_paths
      @inventory_tool_paths ||= begin
        path = File.join(root, 'spec/trial_by_fire/BASIC_SHARP_TRIAL_BY_FIRE_VALIDATION_INVENTORY_v1.json')
        JSON.parse(File.read(path, encoding: 'UTF-8')).fetch('required_tools').map { |entry| entry.fetch('path') }
      end
    end

    def missing_inventory_tools
      required_tool_paths - inventory_tool_paths
    end

    def checks
      @checks ||= {
        format_matches: spec.fetch('format') == 'bsharp.self_hosting_milestone_1.json',
        format_version_matches: spec.fetch('format_version') == 1,
        target_version_matches: spec.fetch('target_version') == BasicSharp::VERSION,
        status_matches: spec.fetch('status') == STATUS,
        definition_preserves_ruby_referee: spec.fetch('definition').include?('under Ruby referee supervision'),
        definition_names_ir_and_bsbc: spec.fetch('definition').include?('BSharp IR') && spec.fetch('definition').include?('BSBC'),
        allowed_claims_are_limited: spec.fetch('allowed_claims').all? { |claim| claim.include?('under Ruby referee') || claim.include?('not full self-hosting') || claim.include?('BSharp Compiler Subset 0') },
        forbidden_full_self_hosting: spec.fetch('forbidden_claims').include?('BASIC# is fully self-hosted'),
        forbidden_ruby_retirement: spec.fetch('forbidden_claims').include?('Ruby is retired'),
        forbidden_profile_8: spec.fetch('forbidden_claims').include?('Profile 8 exists'),
        all_required_tools_exist: missing_tools.empty?,
        all_evidence_specs_exist: missing_evidence_specs.empty?,
        all_required_tools_in_inventory: missing_inventory_tools.empty?,
        runtime_smoke_passes: runtime_smoke_record.fetch(:all_pass),
        bootstrap_boundary_passes: bootstrap_boundary_record.fetch(:all_pass),
        readme_truth_passes: readme_truth_record.fetch(:all_pass)
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
        checks: checks,
        required_lane_count: spec.fetch('required_lanes').length,
        missing_tools: missing_tools,
        missing_evidence_specs: missing_evidence_specs,
        missing_inventory_tools: missing_inventory_tools,
        evidence_digest_sha256: self.class.digest_for({
          runtime_smoke: runtime_smoke_record,
          bootstrap_boundary: bootstrap_boundary_record,
          readme_truth: readme_truth_record
        })
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
  end
end
