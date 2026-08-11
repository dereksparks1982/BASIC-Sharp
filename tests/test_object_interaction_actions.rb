# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../compiler/parser'
require_relative '../compiler/resolver'
require_relative '../compiler/runtime'
require_relative '../compiler/bytecode_emitter'
require_relative '../compiler/bytecode_loader'
require_relative '../compiler/bytecode_virtual_machine'
require_relative '../compiler/game_interaction'

class TestObjectInteractionActions < Minitest::Test
  ROOT = File.expand_path('..', __dir__)

  def resolve(source)
    parser = BasicSharp::Parser.new(source)
    BasicSharp::SemanticResolver.new(parser.parse, dictionary: parser.dictionary).resolve
  end

  def sample_document
    resolve(File.read(File.join(ROOT, 'samples/object_interaction_actions.bsharp'), encoding: 'UTF-8'))
  end

  def test_plain_english_object_words_canonicalize_to_existing_runtime_primitives
    document = sample_document
    assert_equal 0, document.error_count, document.diagnostics.map(&:to_s).join("\n")
    assert_equal 0, document.warning_count, document.diagnostics.map(&:to_s).join("\n")

    actions = document.events.first.fetch('then')
    assert_equal %w[change change change carry], actions.map { |entry| entry.fetch('action') }
    assert_equal %w[open closed locked], actions.first(3).map { |entry| entry.dig('to', 'name') }
    assert_equal 'brass key', actions.last.dig('target', 'name')
  end

  def test_reference_runtime_executes_open_close_lock_and_take
    document = sample_document
    machine = BasicSharp::Runtime.new(document)
    result = machine.run_event('player examines north gate')

    assert_nil result['error']
    assert_equal %w[closed locked], machine.ask_thing('north gate').fetch('states').sort
    key = machine.ask_thing('brass key')
    assert_equal 'player', key.dig('relations', 'carried by')
  end

  def test_bsharp_vm_matches_reference_runtime_for_plain_english_object_words
    document = sample_document
    reference = BasicSharp::Runtime.new(document)
    reference_result = reference.run_event('player examines north gate')
    assert_nil reference_result['error']

    emitter = BasicSharp::BytecodeEmitter.new(document)
    loader = BasicSharp::BytecodeLoader.new(emitter.binary)
    vm = BasicSharp::BytecodeVirtualMachine.new(loader)
    vm_result = vm.run_event('player examines north gate')

    assert_nil vm_result['error']
    assert_equal reference.snapshot, vm.snapshot
  end

  def test_context_can_use_open_close_and_take_directly
    document = sample_document
    reference = BasicSharp::Runtime.new(document)
    interaction = BasicSharp::GameInteraction.new(document, machine: reference)

    assert_equal %w[Open], interaction.context_for('north gate').map { |entry| entry['label'] }
    open_result = interaction.execute('north gate', 'Open')
    assert_nil open_result['error']
    assert_equal ['open'], reference.ask_thing('north gate').fetch('states')
    assert_equal %w[Close], interaction.context_for('north gate').map { |entry| entry['label'] }

    close_result = interaction.execute('north gate', 'Close')
    assert_nil close_result['error']
    assert_equal ['closed'], reference.ask_thing('north gate').fetch('states')

    take_result = interaction.execute('brass key', 'Take')
    assert_nil take_result['error']
    assert_equal 'player', reference.ask_thing('brass key').dig('relations', 'carried by')
  end

  def test_it_and_every_kind_keep_existing_selector_meaning
    document = resolve(<<~BS)
      DEFINE
      [
          @north gate is a #door
          @south gate is a #door
      ].

      START
      [
          @north gate is closed
          @south gate is closed
      ].

      WHEN PLAYER opens @north gate
      [
          |then (open it
          |then (lock every #door
      ].
    BS

    assert_equal 0, document.error_count, document.diagnostics.map(&:to_s).join("\n")
    actions = document.events.first.fetch('then')
    assert_equal 'north gate', actions.first.dig('target', 'name')
    assert_equal 'kind_set', actions.last.dig('target', 'type')
    assert_equal 'door', actions.last.dig('target', 'kind_name')

    machine = BasicSharp::Runtime.new(document)
    result = machine.run_event('player opens north gate')
    assert_nil result['error']
    assert_equal %w[locked open], machine.ask_thing('north gate').fetch('states').sort
    assert_equal %w[closed locked], machine.ask_thing('south gate').fetch('states').sort
  end

  def test_object_words_require_one_target_and_no_tail
    document = resolve(<<~BS)
      DEFINE
      [
          @north gate is a #door
      ].

      WHEN PLAYER opens @north gate
      [
          |then (open
          |then (close @north gate to open
      ].
    BS

    messages = document.diagnostics.select { |entry| entry.severity == 'error' }.map(&:message)
    assert_includes messages, '(open must name what to open.'
    assert_includes messages, '(close takes one target and no extra words in this build.'
  end
end
