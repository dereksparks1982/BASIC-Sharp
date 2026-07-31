# frozen_string_literal: true

require 'json'
require 'minitest/autorun'
require_relative '../compiler/meaning_profile'

class TestMeaningProfile2 < Minitest::Test
  ROOT = File.expand_path('..', __dir__)
  MANIFEST_PATH = File.join(ROOT, 'spec/meaning_v2/BASIC_SHARP_MEANING_PROFILE_v2.json')

  def manifest
    @manifest ||= JSON.parse(File.read(MANIFEST_PATH, encoding: 'UTF-8'))
  end

  def test_profile_identity_and_exact_case_set
    assert_equal 'bsharp.meaning.conformance.json', manifest.fetch('format')
    assert_equal 1, manifest.fetch('format_version')
    assert_equal 'bsharp.meaning.v2', manifest.fetch('profile')
    assert_equal %w[01_text_start 02_text_change_selection 03_text_if_reactivity 04_text_save_ask 05_invalid_text_boundaries],
                 manifest.fetch('cases').map { |entry| entry.fetch('id') }
  end

  def test_manifest_and_expected_hashes_are_valid
    assert BasicSharp::MeaningProfile.validate_manifest!(manifest, root: ROOT)
  end

  def test_all_profile_2_cases_match_their_expected_meaning
    manifest.fetch('cases').each do |entry|
      expected = JSON.parse(File.read(File.join(ROOT, entry.fetch('expected')), encoding: 'UTF-8'))
      actual = BasicSharp::MeaningProfile.observe_case(
        entry,
        root: ROOT,
        profile: BasicSharp::MeaningProfile::PROFILE_2
      )
      assert_equal expected, actual, entry.fetch('id')
      assert_equal true, actual.fetch('source_bsir_parity'), entry.fetch('id') if actual.dig('compile', 'errors').empty?
    end
  end

  def test_profile_2_preserves_exact_creator_text
    entry = manifest.fetch('cases').find { |candidate| candidate.fetch('id') == '01_text_start' }
    observed = BasicSharp::MeaningProfile.observe_case(
      entry,
      root: ROOT,
      profile: BasicSharp::MeaningProfile::PROFILE_2
    )
    fact = observed.dig('compile', 'meaning', 'facts', 0)
    assert_equal 'North  Gate — OPEN!', fact.fetch('text_value')
    assert_equal 'bsharp.meaning.v2', observed.fetch('profile')
    assert_equal 'North  Gate — OPEN!', observed.dig('execution', 'startup', 'snapshot', 1, 'values', 'title')
  end

  def test_invalid_boundary_case_never_executes
    entry = manifest.fetch('cases').find { |candidate| candidate.fetch('id') == '05_invalid_text_boundaries' }
    observed = BasicSharp::MeaningProfile.observe_case(
      entry,
      root: ROOT,
      profile: BasicSharp::MeaningProfile::PROFILE_2
    )
    refute_empty observed.dig('compile', 'errors')
    refute observed.key?('execution')
    assert_includes observed.dig('compile', 'errors').first.fetch('message'), 'straight double quotes'
  end

  def test_profile_1_manifest_remains_supported
    profile_1_path = File.join(ROOT, 'spec/meaning_v1/BASIC_SHARP_MEANING_PROFILE_v1.json')
    profile_1 = JSON.parse(File.read(profile_1_path, encoding: 'UTF-8'))
    assert BasicSharp::MeaningProfile.validate_manifest!(profile_1, root: ROOT)
    assert_equal 13, profile_1.fetch('cases').length
    assert_equal 'bsharp.meaning.v1', profile_1.fetch('profile')
  end
end
