# frozen_string_literal: true

require 'json'
require 'minitest/autorun'
require_relative '../compiler/parser'
require_relative '../compiler/resolver'
require_relative '../compiler/ir_emitter'

class TestIROutput < Minitest::Test
  def setup
    source = File.read(File.expand_path('../samples/first_room.dks', __dir__))
    parser = DKScript::Parser.new(source)
    program = parser.parse
    document = DKScript::SemanticResolver.new(program, dictionary: parser.dictionary).resolve
    @json = DKScript::IREmitter.new(document).to_json
    @ir = JSON.parse(@json)
  end

  def test_emits_versioned_ir
    assert_equal '0.1.04', @ir.fetch('version')
    assert_equal 'dkir.debug.json', @ir.fetch('format')
  end

  def test_emits_objects_facts_and_rules
    assert_equal 4, @ir.fetch('objects').length
    assert_equal 3, @ir.fetch('facts').length
    assert_equal 2, @ir.fetch('events').length
    assert_equal 1, @ir.fetch('if_rules').length
  end

  def test_change_action_emits_target_and_state
    change_action = @ir.fetch('events').last.fetch('then').last

    assert_equal 'change', change_action.fetch('action')
    assert_equal 'henry', change_action.fetch('target').fetch('name')
    assert_equal 'state', change_action.fetch('to').fetch('kind')
    assert_equal 'angry', change_action.fetch('to').fetch('name')
  end
end
