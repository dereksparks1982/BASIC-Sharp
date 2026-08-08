# frozen_string_literal: true

require 'json'
require 'minitest/autorun'
require_relative '../compiler/parser'
require_relative '../compiler/resolver'
require_relative '../compiler/game_input'

class TestDemonKillerInput < Minitest::Test
  ROOT = File.expand_path('..', __dir__)

  def setup
    parser = BasicSharp::Parser.new(File.read(File.join(ROOT, 'samples/demon_killer_controls.bsharp'), encoding: 'UTF-8'))
    @document = BasicSharp::SemanticResolver.new(parser.parse, dictionary: parser.dictionary).resolve
    @input = BasicSharp::GameInput.new(@document)
  end

  def test_diagonal_is_normalized_and_opposites_cancel
    @input.process('type' => 'key_down', 'key' => 'W')
    @input.process('type' => 'key_down', 'key' => 'D')
    command = @input.process('type' => 'frame', 'time_ms' => 10).fetch(0)
    assert_in_delta 0.707106781187, command.fetch('x'), 0.000000000001
    assert_in_delta(-0.707106781187, command.fetch('y'), 0.000000000001)

    @input.process('type' => 'key_down', 'key' => 'S')
    command = @input.process('type' => 'frame', 'time_ms' => 20).fetch(0)
    assert_equal 0.0, command.fetch('y')
  end

  def test_arrow_keys_and_gamepads_drive_same_top_down_meaning
    @input.process('type' => 'key_down', 'key' => 'ArrowUp')
    @input.process('type' => 'key_down', 'key' => 'ArrowRight')
    command = @input.process('type' => 'frame', 'time_ms' => 10).fetch(0)
    assert_in_delta 0.707106781187, command.fetch('x'), 0.000000000001
    assert_in_delta(-0.707106781187, command.fetch('y'), 0.000000000001)

    @input.process('type' => 'key_up', 'key' => 'ArrowUp')
    @input.process('type' => 'key_up', 'key' => 'ArrowRight')
    @input.process('type' => 'button_down', 'device' => 'ps5', 'button' => 'dpad_left')
    assert_equal(-1.0, @input.process('type' => 'frame', 'time_ms' => 20).fetch(0).fetch('x'))
    @input.process('type' => 'button_up', 'device' => 'ps5', 'button' => 'dpad_left')

    @input.process('type' => 'axis', 'device' => 'xbox', 'axis' => 'left_y', 'value' => 0.75)
    assert_equal 1.0, @input.process('type' => 'frame', 'time_ms' => 30).fetch(0).fetch('y')
    @input.process('type' => 'axis', 'device' => 'generic_gamepad', 'axis' => 'left_y', 'value' => 0.0)
    @input.process('type' => 'axis', 'device' => 'xbox', 'axis' => 'left_y', 'value' => 0.0)
  end

  def test_mouse_hold_over_empty_ground_overrides_keys
    @input.process('type' => 'key_down', 'key' => 'W')
    @input.process('type' => 'pointer_move', 'x' => 50, 'y' => 0, 'distance' => 25, 'maximum_distance' => 100)
    @input.process('type' => 'right_mouse_down', 'time_ms' => 100)
    assert_equal 'move', @input.process('type' => 'frame', 'time_ms' => 299).fetch(0).fetch('command')
    command = @input.process('type' => 'frame', 'time_ms' => 300).fetch(0)
    assert_equal 'move_toward_pointer', command.fetch('command')
    assert_equal 0.25, command.fetch('speed_scale')
  end

  def test_object_click_wins_and_quick_empty_click_does_nothing
    commands = @input.process('type' => 'right_mouse_down', 'time_ms' => 0, 'object' => 'north gate')
    assert_equal [{ 'command' => 'open_context', 'object' => 'north gate' }], commands
    assert_equal [], @input.process('type' => 'right_mouse_up', 'time_ms' => 20)
    assert_equal [], @input.process('type' => 'right_mouse_down', 'time_ms' => 30)
    assert_equal [], @input.process('type' => 'right_mouse_up', 'time_ms' => 50)
  end

  def test_controls_require_positive_player_speed
    document = JSON.parse(JSON.generate(@document.to_h))
    document.fetch('facts').reject! { |fact| fact['value_name'] == 'speed' }
    error = assert_raises(BasicSharp::GameInputError) { BasicSharp::GameInput.new(document) }
    assert_includes error.message, 'PLAYER must possess a positive numeric speed'
  end
end
