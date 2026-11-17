# frozen_string_literal: true

require 'json'
require 'minitest/autorun'
require_relative '../compiler/readme_current_release_truth'

class TestReadmeCurrentReleaseTruth < Minitest::Test
  ROOT = File.expand_path('..', __dir__)
  SPEC_PATH = File.join(ROOT, 'spec/self_hosting/BASIC_SHARP_README_CURRENT_RELEASE_TRUTH_v1.json')
  README_PATH = File.join(ROOT, 'README.md')
  HISTORY_PATH = File.join(ROOT, 'docs/history/BASIC_SHARP_TECHNICAL_HISTORY.md')

  def spec
    @spec ||= JSON.parse(File.read(SPEC_PATH, encoding: 'UTF-8'))
  end

  def readme
    File.read(README_PATH, encoding: 'UTF-8')
  end

  def history
    File.read(HISTORY_PATH, encoding: 'UTF-8')
  end

  def record(text = readme, history_text: history)
    BasicSharp::ReadmeCurrentReleaseTruth.new(text, spec, history_text: history_text).to_h
  end

  def test_contract_identity
    assert_equal 'bsharp.readme_current_release_truth.json', spec.fetch('format')
    assert_equal 1, spec.fetch('format_version')
    assert_equal BasicSharp::VERSION, spec.fetch('target_version')
    assert_equal 'readme_current_release_truth_gate', spec.fetch('status')
    assert_equal 'BASIC#', spec.fetch('current_release').fetch('heading')
    assert_equal 'v0.0.84', spec.fetch('current_release').fetch('version')
    assert_equal 'docs/history/BASIC_SHARP_TECHNICAL_HISTORY.md', spec.fetch('current_release').fetch('history_file')
    assert_equal 4, spec.fetch('protected_truths').length
  end

  def test_clean_public_readme_and_complete_archived_history
    r = record
    assert r.fetch(:all_pass), r.inspect
    assert r.fetch(:checks).fetch(:heading_matches)
    assert r.fetch(:checks).fetch(:intro_present)
    assert r.fetch(:checks).fetch(:history_in_docs)
    assert r.fetch(:checks).fetch(:history_link_present)
    assert r.fetch(:checks).fetch(:history_not_in_public_readme)
    assert r.fetch(:checks).fetch(:complete_history_present)
    assert r.fetch(:checks).fetch(:legal_section_present)
    assert r.fetch(:checks).fetch(:tagline_present)
    assert_empty r.fetch(:missing_history_versions)
    assert_includes history, '### v0.0.84'
    assert_includes history, '### v0.0.01'
    refute_includes readme, '## Technical History'
    assert_includes readme, 'https://dereksparks1982.github.io/BASIC-Sharp/'
  end

  def test_missing_history_version_fails
    broken = history.sub('### v0.0.42', '### missing-version')
    refute record(readme, history_text: broken).fetch(:all_pass)
    assert_includes record(readme, history_text: broken).fetch(:missing_history_versions), 'v0.0.42'
  end

  def test_wrong_current_version_fails
    broken = readme.sub('current accepted release is **v0.0.84**', 'current accepted release is **v0.0.83**')
    refute record(broken).fetch(:checks).fetch(:current_version_present)
  end

  def test_legal_section_is_required
    broken = readme.sub('## License / Legal', '## Legal section removed')
    refute record(broken).fetch(:checks).fetch(:legal_section_present)
  end

  def test_tagline_is_required
    broken = readme.sub('scripting language made for non-programmers, by non-programmers', 'scripting language')
    refute record(broken).fetch(:checks).fetch(:tagline_present)
  end

  def test_trial_by_fire_inventory_runs_readme_truth_gate
    inventory = JSON.parse(File.read(File.join(ROOT, 'spec/trial_by_fire/BASIC_SHARP_TRIAL_BY_FIRE_VALIDATION_INVENTORY_v1.json'), encoding: 'UTF-8'))
    tools = inventory.fetch('required_tools').map { |entry| entry.fetch('path') }
    assert_includes tools, 'tools/readme_current_release_truth.rb'
  end
end
