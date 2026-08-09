# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../compiler/parser'
require_relative '../compiler/resolver'
require_relative '../compiler/game_input'
require_relative '../compiler/bytecode_emitter'
require_relative '../compiler/bytecode_loader'

class TestPlainEnglishInputMapping < Minitest::Test
  ROOT = File.expand_path('..', __dir__)

  def setup
    source = File.read(File.join(ROOT, 'samples/plain_english_input_mapping.bsharp'), encoding: 'UTF-8')
    parser = BasicSharp::Parser.new(source)
    @document = BasicSharp::SemanticResolver.new(parser.parse, dictionary: parser.dictionary).resolve
    @input = BasicSharp::GameInput.new(@document)
  end

  def test_declared_actions_resolve_inside_controls
    assert_equal 'bsharp.meaning.v4', @document.meaning_profile
    assert_equal 0, @document.error_count
    assert_equal 0, @document.warning_count
    actions = @document.controls.fetch(0).fetch('instructions').select { |entry| entry.fetch('type') == 'input_action' }
    assert_equal %w[jump attack interact pause], actions.map { |entry| entry.fetch('action') }
  end

  def test_keyboard_actions_emit_engine_neutral_input_action_commands
    assert_equal({ 'command' => 'input_action', 'subject' => 'player', 'action' => 'jump', 'source' => 'keyboard:SPACE' }, @input.process('type' => 'key_down', 'key' => 'Space').fetch(0))
    assert_equal({ 'command' => 'input_action', 'subject' => 'player', 'action' => 'interact', 'source' => 'keyboard:E' }, @input.process('type' => 'key_down', 'key' => 'E').fetch(0))
    assert_equal({ 'command' => 'input_action', 'subject' => 'player', 'action' => 'attack', 'source' => 'keyboard:J' }, @input.process('type' => 'key_down', 'key' => 'J').fetch(0))
    assert_equal({ 'command' => 'input_action', 'subject' => 'player', 'action' => 'pause', 'source' => 'keyboard:ESCAPE' }, @input.process('type' => 'key_down', 'key' => 'Escape').fetch(0))
  end

  def test_mouse_and_controller_actions_share_the_same_action_meaning
    assert_equal({ 'command' => 'input_action', 'subject' => 'player', 'action' => 'attack', 'source' => 'mouse:LEFT' }, @input.process('type' => 'mouse_down', 'button' => 'left').fetch(0))

    ps5 = BasicSharp::GameInput.new(@document)
    assert_equal 'jump', ps5.process('type' => 'button_down', 'device' => 'ps5', 'button' => 'cross').fetch(0).fetch('action')
    assert_equal 'attack', ps5.process('type' => 'button_down', 'device' => 'ps5', 'button' => 'square').fetch(0).fetch('action')
    assert_equal 'interact', ps5.process('type' => 'button_down', 'device' => 'ps5', 'button' => 'triangle').fetch(0).fetch('action')
    assert_equal 'pause', ps5.process('type' => 'button_down', 'device' => 'ps5', 'button' => 'options').fetch(0).fetch('action')

    xbox = BasicSharp::GameInput.new(@document)
    assert_equal 'jump', xbox.process('type' => 'button_down', 'device' => 'xbox', 'button' => 'a').fetch(0).fetch('action')
    assert_equal 'attack', xbox.process('type' => 'button_down', 'device' => 'xbox', 'button' => 'x').fetch(0).fetch('action')
    assert_equal 'interact', xbox.process('type' => 'button_down', 'device' => 'xbox', 'button' => 'y').fetch(0).fetch('action')
    assert_equal 'pause', xbox.process('type' => 'button_down', 'device' => 'xbox', 'button' => 'menu').fetch(0).fetch('action')
  end

  def test_undeclared_actions_do_not_emit_input_action_commands
    source = <<~BS
      CONTROLS for PLAYER
      [
          W moves PLAYER forward at 6 speed
          S moves PLAYER backward at 6 speed
          A moves PLAYER left at 6 speed
          D moves PLAYER right at 6 speed
      ].
    BS
    parser = BasicSharp::Parser.new(source)
    document = BasicSharp::SemanticResolver.new(parser.parse, dictionary: parser.dictionary).resolve
    input = BasicSharp::GameInput.new(document)
    assert_equal [], input.process('type' => 'key_down', 'key' => 'Space')
  end

  def test_source_and_loaded_bsbc_emit_identical_action_commands
    loader = BasicSharp::BytecodeLoader.new(BasicSharp::BytecodeEmitter.new(@document).binary)
    source_input = BasicSharp::GameInput.new(@document)
    bytecode_input = BasicSharp::GameInput.new(loader.model)
    events = [
      { 'type' => 'key_down', 'key' => 'Space' },
      { 'type' => 'mouse_down', 'button' => 'left' },
      { 'type' => 'button_down', 'device' => 'xbox', 'button' => 'y' },
      { 'type' => 'button_down', 'device' => 'generic_gamepad', 'button' => 'start' }
    ]
    assert_equal events.flat_map { |event| source_input.process(event) }, events.flat_map { |event| bytecode_input.process(event) }
    assert_equal 'bsharp.bytecode.v4', loader.model.fetch(:profile)
  end

  def test_duplicate_input_action_is_reported_plainly
    source = <<~BS
      CONTROLS for PLAYER
      [
          W moves PLAYER forward at 6 speed
          S moves PLAYER backward at 6 speed
          A moves PLAYER left at 6 speed
          D moves PLAYER right at 6 speed
          PLAYER can attack
          PLAYER can attack
      ].
    BS
    parser = BasicSharp::Parser.new(source)
    document = BasicSharp::SemanticResolver.new(parser.parse, dictionary: parser.dictionary).resolve
    assert_includes document.diagnostics.map(&:message).join("\n"), 'PLAYER already has attack input action.'
  end
end
