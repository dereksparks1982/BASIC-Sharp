# frozen_string_literal: true
require_relative 'ast_nodes'
module BasicSharp
  class ReadmeCurrentReleaseTruth
    STATUS='readme_current_release_truth_gate'; attr_reader :readme_text,:spec
    def initialize(readme_text,spec);@readme_text=readme_text;@spec=spec;end
    def expected_versions;(1..84).to_a.reverse.map{|n|format('v0.0.%02d',n)};end
    def missing_history_versions;expected_versions.reject{|v|readme_text.include?("### #{v} ")||readme_text.include?("### #{v} —")};end
    def checks;{format_matches:spec.fetch('format')=='bsharp.readme_current_release_truth.json',format_version_matches:spec.fetch('format_version')==1,target_version_matches:spec.fetch('target_version')==BasicSharp::VERSION,status_matches:spec.fetch('status')==STATUS,heading_matches:readme_text.lines.first.to_s.strip=='# BASIC#',intro_present:readme_text.include?('## Intro'),current_version_present:readme_text.include?("The current version is **v#{BasicSharp::VERSION}**."),tagline_present:readme_text.include?('scripting language made for non-programmers, by non-programmers'),technical_history_present:readme_text.include?('## Technical History'),complete_history_present:missing_history_versions.empty?,additional_notes_present:readme_text.include?('## Additional Notes'),legal_section_present:readme_text.include?('## License / Legal'),ruby_authority_preserved:readme_text.include?('Ruby'),not_full_self_hosting_declared:readme_text.include?('not yet fully self-hosted')};end
    def all_pass?;checks.values.all?;end
    def to_h;{format:'bsharp.readme_current_release_truth.record',version:BasicSharp::VERSION,status:STATUS,all_pass:all_pass?,checks:checks,missing_history_versions:missing_history_versions};end
  end
end
