# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../tools/trial_by_fire_support'

class TestTrialByFireGenerator < Minitest::Test
  def test_profile_cycle_covers_profiles_one_through_seven
    assert_equal [1, 2, 3, 4, 5, 6, 7], 7.times.map { |index| BasicSharp::TrialByFire.generated_profile(index) }
  end

  def test_same_seed_produces_byte_identical_source
    first = BasicSharp::TrialByFire.generated_source(137)
    assert_equal first, BasicSharp::TrialByFire.generated_source(137)
  end

  def test_one_generated_program_per_profile_has_complete_parity
    results = 7.times.map { |index| BasicSharp::TrialByFire.verify_generated_program(index) }
    assert_equal 7, results.map { |entry| entry.fetch('meaning_profile') }.uniq.length
  end
end
