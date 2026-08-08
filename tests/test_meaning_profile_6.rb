# frozen_string_literal: true

require 'json'
require 'minitest/autorun'
require_relative '../compiler/meaning_profile'

class TestMeaningProfile6 < Minitest::Test
  ROOT = File.expand_path('..', __dir__)
  PROFILE_PATH = File.join(ROOT, 'spec/meaning_v6/BASIC_SHARP_MEANING_PROFILE_v6.json')

  def test_manifest_and_all_ten_cases_are_stable
    manifest = JSON.parse(File.read(PROFILE_PATH, encoding: 'UTF-8'))
    assert BasicSharp::MeaningProfile.validate_manifest!(manifest, root: ROOT)
    assert_equal 'bsharp.meaning.v6', manifest.fetch('profile')
    assert_equal 10, manifest.fetch('cases').length
    manifest.fetch('cases').each do |entry|
      expected = JSON.parse(File.read(File.join(ROOT, entry.fetch('expected')), encoding: 'UTF-8'))
      observed = BasicSharp::MeaningProfile.observe_case(entry, root: ROOT, profile: BasicSharp::MeaningProfile::PROFILE_6)
      assert_equal expected, observed, entry.fetch('id')
    end
  end
end
