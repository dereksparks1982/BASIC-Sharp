# frozen_string_literal: true

require 'json'
require 'minitest/autorun'
require_relative '../compiler/ast_nodes'

class TestInputDeviceContract < Minitest::Test
  ROOT = File.expand_path('..', __dir__)

  def spec
    JSON.parse(File.read(File.join(ROOT, 'spec/input/BASIC_SHARP_INPUT_DEVICE_MAPPING_v1.json')))
  end

  def test_contract_tracks_current_version_and_supported_devices
    assert_equal '0.1.51', BasicSharp::VERSION
    assert_equal BasicSharp::VERSION, spec.fetch('target_version')
    assert_equal %w[generic_gamepad keyboard mouse_keyboard ps5 xbox], spec.fetch('supported_inputs').keys.sort
  end

  def test_contract_preserves_core_exclusions
    exclusions = spec.fetch('explicit_exclusions')
    assert_includes exclusions, 'no new BASIC# source syntax'
    assert_includes exclusions, 'no controller remapping UI'
    assert_includes exclusions, 'no platform-specific driver layer'
    assert_includes exclusions, 'no engine bridge'
    assert_includes exclusions, 'no Profile 8'
    assert_includes exclusions, 'no Ruby replacement'
  end
end
