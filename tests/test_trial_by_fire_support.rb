# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../tools/trial_by_fire_support'

class TestTrialByFireSupport < Minitest::Test
  EXPECTED_ARTIFACTS = {
    'samples/first_room.bsbc' => 'c09c60886cdb341accc427d07a0ac68350b675b4f4e2d1571e02dac216870ee1',
    'samples/first_room.bsbc.txt' => '3034d2b9a76be2b4c67c603642707319f316c243fd110e647604588cd80a20d3',
    'samples/text_values.bsbc' => 'fd0d0315d76aa44c7a143af7c0e6b9a0b61508da1f63f435dab6dfebbbe50403',
    'samples/text_values.bsbc.txt' => '0e860ca11f208c906bdcbd83222f8a97c0911f244ce0dc54246e0825bef251d6',
    'samples/demon_killer_controls.bsbc' => 'd4e696046882060a9498570fa3c7be2c5b05431342a182aa712c837ec7807e9d',
    'samples/demon_killer_controls.bsbc.txt' => '2698471a3343f2dab4ceb434356ffd176b3f4a34843fee65f6af2d0d004c7d03',
    'samples/platform_movement.bsbc' => '41bcab1173735b3664db2d28e2ff0076212039cfeadaabb33021aef78fdfe902',
    'samples/platform_movement.bsbc.txt' => '2c8763cfb898e311f17fcd1e3464ee1f946dc74f174e61fdad86b17554963be8',
    'samples/number_changes.bsbc' => 'a4b48636650c6b01767e32a41cf705f8b25f3f47616aee088d5b77bec63fab7b',
    'samples/number_changes.bsbc.txt' => 'b969476c8d7ee4df3306ccc5cacb585e7c48c83c7040f7a105d5b02f36175e9f',
    'samples/compound_if_conditions.bsbc' => 'df14c0ce8c003e622ccebf5cd652bf7a9fde8c2b8eaa778e00e49dbde9fccfd5',
    'samples/compound_if_conditions.bsbc.txt' => '56aaf086235d6c62a5b4d60d53b7521729e50ce9f859662c3ff32500b8fcb512',
    'samples/otherwise_branches.bsbc' => '4af08d447c2bf4fc9e70d90c6dbb4098d441d67dbba012b9d245f51dc7b9a613',
    'samples/otherwise_branches.bsbc.txt' => '59623528ed600520ca6a3fcc5a6cb97115fa061c0ab323a981545a5aab22cc3e'
  }.freeze

  def test_independent_golden_trace
    assert BasicSharp::TrialByFire.verify_golden_trace!
  end

  def test_protected_profile_artifacts
    assert BasicSharp::TrialByFire.verify_profile_artifacts!(EXPECTED_ARTIFACTS)
  end

  def test_semantic_hash_ignores_packaging_metadata
    left = { 'version' => 'one', 'created_by_basic_sharp' => 'one', 'value' => 7 }
    right = { 'version' => 'two', 'created_by_basic_sharp' => 'two', 'value' => 7 }
    assert_equal BasicSharp::TrialByFire.semantic_sha256(left), BasicSharp::TrialByFire.semantic_sha256(right)
  end

  def test_principal_campaign_has_all_profiles_and_paths
    trace = BasicSharp::TrialByFire.campaign_trace
    assert trace.fetch('events').length == BasicSharp::TrialByFire::CAMPAIGN_EVENTS.length
  end
end
