# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../compiler/parser'
require_relative '../compiler/resolver'
require_relative '../compiler/game_input'
require_relative '../compiler/bytecode_emitter'
require_relative '../compiler/bytecode_loader'
require_relative '../compiler/runtime'
require_relative '../compiler/bytecode_virtual_machine'
require_relative '../compiler/world_save'
require_relative '../compiler/ask'

class TestPlatformMovement < Minitest::Test
  ROOT = File.expand_path('..', __dir__)

  def setup
    source = File.read(File.join(ROOT, 'samples/platform_movement.bsharp'))
    parser = BasicSharp::Parser.new(source)
    @document = BasicSharp::SemanticResolver.new(parser.parse, dictionary: parser.dictionary).resolve
    @input = BasicSharp::GameInput.new(@document)
  end

  def command(event)
    @input.process(event).fetch(0)
  end

  def test_plain_english_controls_resolve_as_profile_4
    assert_equal 'bsharp.meaning.v4', @document.meaning_profile
    assert_equal 0, @document.error_count
    assert_equal 0, @document.warning_count
    instructions = @document.controls.fetch(0).fetch('instructions')
    assert_equal %w[platform_move platform_move platform_jump], instructions.map { |entry| entry.fetch('type') }
    assert_equal [6, 6, 10], instructions.map { |entry| entry.fetch('speed') }
  end

  def test_left_right_and_opposing_keys
    @input.process('type' => 'key_down', 'key' => 'A')
    assert_equal(-6.0, command('type' => 'frame', 'time_ms' => 0, 'grounded' => true).fetch('velocity_x'))
    @input.process('type' => 'key_down', 'key' => 'D')
    assert_equal 0.0, command('type' => 'frame', 'time_ms' => 16, 'grounded' => true).fetch('velocity_x')
    @input.process('type' => 'key_up', 'key' => 'A')
    assert_equal 6.0, command('type' => 'frame', 'time_ms' => 32, 'grounded' => true).fetch('velocity_x')
  end

  def test_arrow_keys_drive_same_platform_meaning
    @input.process('type' => 'key_down', 'key' => 'ArrowLeft')
    assert_equal(-6.0, command('type' => 'frame', 'time_ms' => 0, 'grounded' => true).fetch('velocity_x'))
    @input.process('type' => 'key_up', 'key' => 'ArrowLeft')
    @input.process('type' => 'key_down', 'key' => 'RIGHT_ARROW')
    assert_equal 6.0, command('type' => 'frame', 'time_ms' => 16, 'grounded' => true).fetch('velocity_x')
  end

  def test_ps5_xbox_and_generic_gamepads_drive_same_platform_meaning
    @input.process('type' => 'button_down', 'device' => 'ps5', 'button' => 'dpad_left')
    assert_equal(-6.0, command('type' => 'frame', 'time_ms' => 0, 'grounded' => true).fetch('velocity_x'))
    @input.process('type' => 'button_up', 'device' => 'ps5', 'button' => 'dpad_left')

    xbox_input = BasicSharp::GameInput.new(@document)
    xbox_input.process('type' => 'button_down', 'device' => 'xbox', 'button' => 'a')
    assert_equal(-10.0, xbox_input.process('type' => 'frame', 'time_ms' => 0, 'grounded' => true).fetch(0).fetch('velocity_y'))
    xbox_input.process('type' => 'button_up', 'device' => 'xbox', 'button' => 'a')

    @input.process('type' => 'button_down', 'device' => 'generic_gamepad', 'button' => 'dpad_right')
    assert_equal 6.0, command('type' => 'frame', 'time_ms' => 32, 'grounded' => true).fetch('velocity_x')
  end

  def test_gamepad_axis_thresholds_drive_platform_movement
    @input.process('type' => 'axis', 'device' => 'xbox', 'axis' => 'left_x', 'value' => -0.75)
    assert_equal(-6.0, command('type' => 'frame', 'time_ms' => 0, 'grounded' => true).fetch('velocity_x'))
    @input.process('type' => 'axis', 'device' => 'xbox', 'axis' => 'left_x', 'value' => 0.25)
    assert_equal 0.0, command('type' => 'frame', 'time_ms' => 16, 'grounded' => true).fetch('velocity_x')
    @input.process('type' => 'axis', 'device' => 'ps5', 'axis' => 'left_x', 'value' => 0.75)
    assert_equal 6.0, command('type' => 'frame', 'time_ms' => 32, 'grounded' => true).fetch('velocity_x')
  end

  def test_jump_requires_ground_and_one_new_keypress
    @input.process('type' => 'key_down', 'key' => 'SPACE')
    first = command('type' => 'frame', 'time_ms' => 0, 'grounded' => true)
    assert_equal(-10.0, first.fetch('velocity_y'))

    @input.process('type' => 'key_down', 'key' => 'SPACE')
    airborne = command('type' => 'frame', 'time_ms' => 100, 'grounded' => false)
    assert_equal(-7.0, airborne.fetch('velocity_y'))

    @input.process('type' => 'key_up', 'key' => 'SPACE')
    @input.process('type' => 'key_down', 'key' => 'SPACE')
    still_airborne = command('type' => 'frame', 'time_ms' => 200, 'grounded' => false)
    assert_equal(-4.0, still_airborne.fetch('velocity_y'))

    landed = command('type' => 'frame', 'time_ms' => 300, 'grounded' => true)
    assert_equal 0.0, landed.fetch('velocity_y')
  end

  def test_wall_and_ceiling_collision_responses
    @input.process('type' => 'key_down', 'key' => 'A')
    wall = command('type' => 'frame', 'time_ms' => 0, 'grounded' => true, 'hit_left' => true)
    assert_equal 0.0, wall.fetch('velocity_x')

    @input.process('type' => 'key_down', 'key' => 'SPACE')
    command('type' => 'frame', 'time_ms' => 16, 'grounded' => true)
    ceiling = command('type' => 'frame', 'time_ms' => 32, 'grounded' => false, 'hit_ceiling' => true)
    assert_in_delta 0.48, ceiling.fetch('velocity_y'), 0.000000000001
  end

  def test_timing_is_derived_clamped_and_cannot_reverse
    first = command('type' => 'frame', 'time_ms' => 100, 'grounded' => false)
    assert_equal 0.0, first.fetch('delta_seconds')
    delayed = command('type' => 'frame', 'time_ms' => 1_000, 'grounded' => false)
    assert_equal 0.25, delayed.fetch('delta_seconds')
    error = assert_raises(BasicSharp::GameInputError) do
      @input.process('type' => 'frame', 'time_ms' => 999, 'grounded' => false)
    end
    assert_includes error.message, 'cannot move backward'
  end

  def test_source_bsir_and_loaded_bsbc_emit_identical_commands
    emitter = BasicSharp::BytecodeEmitter.new(@document)
    loader = BasicSharp::BytecodeLoader.new(emitter.binary)
    source_input = BasicSharp::GameInput.new(@document)
    bytecode_input = BasicSharp::GameInput.new(loader.model)
    events = [
      { 'type' => 'key_down', 'key' => 'D' },
      { 'type' => 'key_down', 'key' => 'SPACE' },
      { 'type' => 'frame', 'time_ms' => 0, 'grounded' => true },
      { 'type' => 'frame', 'time_ms' => 16, 'grounded' => false }
    ]
    assert_equal events.flat_map { |event| source_input.process(event) }, events.flat_map { |event| bytecode_input.process(event) }
    assert_equal 'bsharp.bytecode.v4', loader.model.fetch(:profile)
  end

  def test_reference_runtime_and_bsharp_vm_expose_same_platform_declaration
    reference = BasicSharp::Runtime.new(@document)
    loader = BasicSharp::BytecodeLoader.new(BasicSharp::BytecodeEmitter.new(@document).binary)
    vm = BasicSharp::BytecodeVirtualMachine.new(loader)
    assert_equal reference.game_declarations, vm.game_declarations
    assert_equal 'bsharp.meaning.v4', reference.meaning_profile
    assert_equal 'bsharp.meaning.v4', vm.meaning_profile
  end

  def test_profile_4_save_and_ask_preserve_platform_meaning
    reference = BasicSharp::Runtime.new(@document)
    save = BasicSharp::WorldSave.document_for(reference)
    assert_equal 4, save.fetch('format_version')
    assert_equal 'sha256-bsir-meaning-v4', save.dig('program_fingerprint', 'algorithm')
    restored = BasicSharp::Runtime.new(@document, world_save: save)
    assert_equal reference.snapshot, restored.snapshot

    loader = BasicSharp::BytecodeLoader.new(BasicSharp::BytecodeEmitter.new(@document).binary)
    vm = BasicSharp::BytecodeVirtualMachine.new(loader)
    source_answer = BasicSharp::Ask.new(reference).answer_many(['what game systems are declared']).fetch(0)
    bytecode_answer = BasicSharp::Ask.new(vm).answer_many(['what game systems are declared']).fetch(0)
    assert_equal source_answer, bytecode_answer
    assert_equal 1, source_answer.dig('answer', 'control_count')
  end

  def test_invalid_platform_declarations_receive_plain_diagnostics
    source = <<~BS
      CONTROLS for PLAYER
      [
          A moves PLAYER left at zero speed
          D moves PLAYER right at 6 speed
          D makes PLAYER jump at 10 speed
      ].
    BS
    parser = BasicSharp::Parser.new(source)
    document = BasicSharp::SemanticResolver.new(parser.parse, dictionary: parser.dictionary).resolve
    messages = document.diagnostics.map(&:message).join("\n")
    assert_includes messages, 'Movement speed must use digits'
    assert_includes messages, 'D already has a platform movement job'
  end
end
