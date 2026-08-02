# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../tools/trial_by_fire_support'

class TestTrialByFireGauntlet < Minitest::Test
  def test_reduced_event_paths_are_deterministic
    result = BasicSharp::TrialByFire.verify_event_paths!(16)
    assert_equal result.fetch('vm_sha256'), result.fetch('repeated_vm_sha256')
  end

  def test_reduced_platform_campaign
    assert_equal 200, BasicSharp::TrialByFire.verify_platform_frames!(200).fetch('frames')
  end

  def test_reduced_ask_campaign
    assert_equal 260, BasicSharp::TrialByFire.verify_ask_questions!(260).fetch('questions')
  end

  def test_reduced_save_campaign
    assert_equal 12, BasicSharp::TrialByFire.verify_save_checkpoints!(12).fetch('checkpoints')
  end

  def test_reduced_isolation_campaign
    assert_equal 8, BasicSharp::TrialByFire.verify_isolated_worlds!(8).fetch('simultaneous_worlds')
  end
end
