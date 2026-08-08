# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../compiler/parser'
require_relative '../compiler/resolver'
require_relative '../compiler/runtime'
require_relative '../compiler/bytecode_emitter'
require_relative '../compiler/bytecode_loader'
require_relative '../compiler/bytecode_virtual_machine'
require_relative '../compiler/game_interaction'

class TestContextInteractions < Minitest::Test
  ROOT = File.expand_path('..', __dir__)

  def setup
    parser = BasicSharp::Parser.new(File.read(File.join(ROOT, 'samples/demon_killer_controls.bsharp'), encoding: 'UTF-8'))
    @document = BasicSharp::SemanticResolver.new(parser.parse, dictionary: parser.dictionary).resolve
  end

  def test_valid_actions_filter_and_change_with_state
    machine = BasicSharp::Runtime.new(@document)
    interaction = BasicSharp::GameInteraction.new(@document, machine: machine)
    assert_equal %w[Open Examine], interaction.context_for('north gate').map { |entry| entry['label'] }
    result = interaction.execute('north gate', 'Open')
    assert_nil result['error']
    assert_equal ['open'], machine.ask_thing('north gate').fetch('states')
    assert_equal %w[Close Examine], interaction.context_for('north gate').map { |entry| entry['label'] }
  end

  def test_reference_runtime_and_bsharp_vm_context_actions_agree
    reference = BasicSharp::Runtime.new(@document)
    emitter = BasicSharp::BytecodeEmitter.new(@document)
    loader = BasicSharp::BytecodeLoader.new(emitter.binary)
    vm = BasicSharp::BytecodeVirtualMachine.new(loader)
    BasicSharp::GameInteraction.new(@document, machine: reference).execute('north gate', 'Open')
    BasicSharp::GameInteraction.new(loader.model, machine: vm).execute('north gate', 'Open')
    assert_equal reference.snapshot, vm.snapshot
  end

  def test_unavailable_action_is_rejected_plainly
    interaction = BasicSharp::GameInteraction.new(@document, machine: BasicSharp::Runtime.new(@document))
    error = assert_raises(BasicSharp::GameInteractionError) { interaction.execute('north gate', 'Close') }
    assert_includes error.message, "does not currently offer 'Close'"
  end
end
