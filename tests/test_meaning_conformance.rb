# frozen_string_literal: true

require 'json'
require 'minitest/autorun'
require_relative '../compiler/meaning_profile'

class TestMeaningConformance < Minitest::Test
  ROOT = File.expand_path('..', __dir__)
  MANIFEST_PATH = File.join(ROOT, 'spec/meaning_v1/BASIC_SHARP_MEANING_PROFILE_v1.json')

  def manifest
    @manifest ||= JSON.parse(File.read(MANIFEST_PATH))
  end

  def test_profile_identity_and_case_count
    assert_equal 'bsharp.meaning.conformance.json', manifest.fetch('format')
    assert_equal 1, manifest.fetch('format_version')
    assert_equal 'bsharp.meaning.v1', manifest.fetch('profile')
    assert_equal '0.1.24', manifest.fetch('language_version')
    assert_equal 13, manifest.fetch('cases').length
  end

  def test_manifest_and_expected_hashes_are_valid
    assert BasicSharp::MeaningProfile.validate_manifest!(manifest, root: ROOT)
  end

  def test_all_profile_cases_match_their_implementation_neutral_expected_results
    manifest.fetch('cases').each do |entry|
      expected = JSON.parse(File.read(File.join(ROOT, entry.fetch('expected'))))
      actual = BasicSharp::MeaningProfile.observe_case(entry, root: ROOT)
      assert_equal expected, actual, entry.fetch('id')
      assert_equal true, actual['source_bsir_parity'], entry.fetch('id') unless actual.dig('compile', 'errors').any?
    end
  end

  def test_profile_files_contain_no_ruby_objects_machine_paths_or_timestamps
    paths = [MANIFEST_PATH] + manifest.fetch('cases').map { |entry| File.join(ROOT, entry.fetch('expected')) }
    paths.each do |path|
      refute BasicSharp::MeaningProfile.forbidden_serialized_data?(File.read(path)), path
    end
  end

  def test_current_heads_are_accepted
    assert_equal %w[KINDS DEFINE START WHEN IF OTHERWISE CONTROLS HOVER CONTEXT], BasicSharp::Parser::STATEMENT_STARTERS
    assert_equal %w[WORLD STATES RELATIONS ACTIONS WHILE], BasicSharp::Parser::DORMANT_HEADS
  end

  def test_each_dormant_head_receives_the_plain_profile_boundary_message
    BasicSharp::Parser::DORMANT_HEADS.each do |head|
      program = BasicSharp::Parser.new("#{head}\n[\n    placeholder\n].\n").parse
      errors = program.diagnostics.select { |entry| entry.severity == 'error' }
      assert_equal 1, errors.length, head
      assert_equal [
        "BASIC# does not have a #{head} Head.",
        '',
        'Current Heads are:',
        '  KINDS',
        '  DEFINE',
        '  START',
        '  WHEN',
        '  IF',
        '  OTHERWISE',
        '  CONTROLS',
        '  HOVER',
        '  CONTEXT'
      ].join("\n"), errors.first.message
    end
  end
end
