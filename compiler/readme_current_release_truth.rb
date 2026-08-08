# frozen_string_literal: true

require_relative 'ast_nodes'

module BasicSharp
  class ReadmeCurrentReleaseTruth
    FORMAT = 'bsharp.readme_current_release_truth.record'
    STATUS = 'readme_current_release_truth_gate'

    attr_reader :readme_text, :spec

    def initialize(readme_text, spec)
      @readme_text = readme_text
      @spec = spec
    end

    def current_release
      spec.fetch('current_release')
    end

    def current_section
      @current_section ||= begin
        lines = readme_text.lines
        first_h2 = lines.find_index { |line| line.start_with?('## ') }
        first_h2 ? lines[0...first_h2].join : readme_text
      end
    end

    def forbidden_phrases
      current_release.fetch('forbidden_current_section_phrases')
    end

    def missing_mentions
      current_release.fetch('must_mention').reject { |phrase| current_section.include?(phrase) }
    end

    def forbidden_hits
      forbidden_phrases.select { |phrase| current_section.include?(phrase) }
    end

    def checks
      @checks ||= {
        format_matches: spec.fetch('format') == 'bsharp.readme_current_release_truth.json',
        format_version_matches: spec.fetch('format_version') == 1,
        target_version_matches: spec.fetch('target_version') == BasicSharp::VERSION,
        status_matches: spec.fetch('status') == STATUS,
        heading_matches: readme_text.lines.first.to_s.strip == "# #{current_release.fetch('heading')}",
        build_title_present: current_section.include?(current_release.fetch('build_title')),
        summary_present: current_section.include?(current_release.fetch('summary')),
        required_mentions_present: missing_mentions.empty?,
        forbidden_current_section_phrases_absent: forbidden_hits.empty?,
        old_false_current_claim_absent: !current_section.include?('small compiler subset IR golden parity harness'),
        ruby_authority_preserved: current_section.include?('Ruby remains the bootstrap compiler'),
        not_full_self_hosting_declared: current_section.include?('not full self-hosting')
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
        missing_mentions: missing_mentions,
        forbidden_hits: forbidden_hits,
        current_section_bytes: current_section.bytesize
      }
    end
  end
end
