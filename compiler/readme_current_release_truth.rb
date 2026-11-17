# frozen_string_literal: true

require_relative 'ast_nodes'

module BasicSharp
  class ReadmeCurrentReleaseTruth
    STATUS = 'readme_current_release_truth_gate'
    HISTORY_PATH = 'docs/history/BASIC_SHARP_TECHNICAL_HISTORY.md'
    attr_reader :readme_text, :history_text, :spec

    def initialize(readme_text, spec, history_text: nil)
      @readme_text = readme_text
      @spec = spec
      @history_text = history_text || File.read(File.expand_path("../#{HISTORY_PATH}", __dir__), encoding: 'UTF-8')
    end

    def expected_versions
      (1..84).to_a.reverse.map { |n| format('v0.0.%02d', n) }
    end

    def missing_history_versions
      expected_versions.reject { |version| history_text.include?("### #{version} —") || history_text.include?("### #{version} ") }
    end

    def checks
      {
        format_matches: spec.fetch('format') == 'bsharp.readme_current_release_truth.json',
        format_version_matches: spec.fetch('format_version') == 1,
        target_version_matches: spec.fetch('target_version') == BasicSharp::VERSION,
        status_matches: spec.fetch('status') == STATUS,
        heading_matches: readme_text.lines.first.to_s.strip == '# BASIC#',
        intro_present: readme_text.include?('## Intro'),
        current_version_present: readme_text.include?("current accepted release is **v#{BasicSharp::VERSION}**"),
        tagline_present: readme_text.include?('scripting language made for non-programmers, by non-programmers'),
        history_in_docs: history_text.start_with?('# BASIC# Technical History') && history_text.include?('## Technical History'),
        history_link_present: readme_text.include?(HISTORY_PATH),
        history_not_in_public_readme: !readme_text.include?('## Technical History') && !readme_text.include?('### v0.0.84'),
        complete_history_present: missing_history_versions.empty?,
        legal_section_present: readme_text.include?('## License / Legal'),
        ruby_authority_preserved: readme_text.include?('Ruby'),
        not_full_self_hosting_declared: readme_text.include?('not yet fully self-hosted')
      }
    end

    def all_pass?
      checks.values.all?
    end

    def to_h
      { format: 'bsharp.readme_current_release_truth.record', version: BasicSharp::VERSION,
        status: STATUS, all_pass: all_pass?, checks: checks,
        history_path: HISTORY_PATH, missing_history_versions: missing_history_versions }
    end
  end
end
