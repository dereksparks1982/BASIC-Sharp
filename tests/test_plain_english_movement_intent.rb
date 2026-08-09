# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../compiler/parser'
require_relative '../compiler/resolver'
require_relative '../compiler/game_input'
require_relative '../compiler/bytecode_emitter'
require_relative '../compiler/bytecode_loader'
require_relative '../compiler/runtime'
require_relative '../compiler/bytecode_virtual_machine'

class TestPlainEnglishMovementIntent < Minitest::Test
  ROOT = File.expand_path('..', __dir__)

  def setup
    source = File.read(File.join(ROOT, 'samples/movement_intent_3d.bsharp'), encoding: 'UTF-8')
    parser = BasicSharp::Parser.new(source)
    @document = BasicSharp::SemanticResolver.new(parser.parse, dictionary: parser.dictionary).resolve
    @input = BasicSharp::GameInput.new(@document)
  end

  def command(event)
    @input.process(event).fetch(0)
  end

  def test_3d_controls_resolve_as_profile_4_world_movement
    assert_equal 'bsharp.meaning.v4', @document.meaning_profile
    assert_equal 0, @document.error_count
    assert_equal 0, @document.warning_count

    instructions = @document.controls.fetch(0).fetch('instructions')
    assert_equal %w[world_move world_move world_move world_move], instructions.map { |entry| entry.fetch('type') }
    assert_equal %w[forward backward left right], instructions.map { |entry| entry.fetch('direction') }
    assert_equal [6, 6, 6, 6], instructions.map { |entry| entry.fetch('speed') }
  end

  def test_wasd_uses_forward_backward_left_right_for_3d
    @input.process('type' => 'key_down', 'key' => 'W')
    forward = command('type' => 'frame', 'time_ms' => 0)
    assert_equal 'move_3d', forward.fetch('command')
    assert_equal 0.0, forward.fetch('velocity_x')
    assert_equal 6.0, forward.fetch('velocity_z')

    @input.process('type' => 'key_down', 'key' => 'D')
    diagonal = command('type' => 'frame', 'time_ms' => 16)
    assert_in_delta 4.242640687119, diagonal.fetch('velocity_x'), 0.000000000001
    assert_in_delta 4.242640687119, diagonal.fetch('velocity_z'), 0.000000000001

    @input.process('type' => 'key_down', 'key' => 'S')
    opposed = command('type' => 'frame', 'time_ms' => 32)
    assert_equal 6.0, opposed.fetch('velocity_x')
    assert_equal 0.0, opposed.fetch('velocity_z')
  end

  def test_gamepad_up_means_forward_in_3d_context
    @input.process('type' => 'button_down', 'device' => 'ps5', 'button' => 'dpad_up')
    ps5 = command('type' => 'frame', 'time_ms' => 0)
    assert_equal 'move_3d', ps5.fetch('command')
    assert_equal 6.0, ps5.fetch('velocity_z')

    xbox_input = BasicSharp::GameInput.new(@document)
    xbox_input.process('type' => 'axis', 'device' => 'xbox', 'axis' => 'left_y', 'value' => -0.75)
    xbox = xbox_input.process('type' => 'frame', 'time_ms' => 0).fetch(0)
    assert_equal 'move_3d', xbox.fetch('command')
    assert_equal 6.0, xbox.fetch('velocity_z')
  end

  def test_source_and_loaded_bsbc_emit_identical_3d_movement_commands
    loader = BasicSharp::BytecodeLoader.new(BasicSharp::BytecodeEmitter.new(@document).binary)
    source_input = BasicSharp::GameInput.new(@document)
    bytecode_input = BasicSharp::GameInput.new(loader.model)
    events = [
      { 'type' => 'key_down', 'key' => 'W' },
      { 'type' => 'key_down', 'key' => 'D' },
      { 'type' => 'frame', 'time_ms' => 0 }
    ]
    assert_equal events.flat_map { |event| source_input.process(event) }, events.flat_map { |event| bytecode_input.process(event) }
    assert_equal 'bsharp.bytecode.v4', loader.model.fetch(:profile)
  end

  def test_reference_runtime_and_bsharp_vm_preserve_3d_declaration
    reference = BasicSharp::Runtime.new(@document)
    vm = BasicSharp::BytecodeVirtualMachine.new(BasicSharp::BytecodeLoader.new(BasicSharp::BytecodeEmitter.new(@document).binary))
    assert_equal reference.game_declarations, vm.game_declarations
    assert_equal 'world_move', reference.game_declarations.fetch('controls').fetch(0).fetch('instructions').fetch(0).fetch('type')
  end

  def test_3d_movement_rejects_missing_backward_declaration
    source = <<~BS
      CONTROLS for PLAYER
      [
          W moves PLAYER forward at 6 speed
          A moves PLAYER left at 6 speed
          D moves PLAYER right at 6 speed
      ].
    BS
    parser = BasicSharp::Parser.new(source)
    document = BasicSharp::SemanticResolver.new(parser.parse, dictionary: parser.dictionary).resolve
    messages = document.diagnostics.map(&:message).join("\n")
    assert_includes messages, '3D CONTROLS must declare PLAYER backward movement.'
  end
end
