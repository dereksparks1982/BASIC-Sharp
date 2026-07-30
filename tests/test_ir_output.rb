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
    assert_equal '0.1.13', @ir.fetch('version')
    assert_equal 'dkir.debug.json', @ir.fetch('format')
  end

  def test_emits_user_defined_kinds
    dragon = @ir.fetch('kinds').first

    assert_equal 'dragon', dragon.fetch('name')
    assert_equal 'creature', dragon.fetch('parent')
  end

  def test_emits_objects_facts_and_rules
    assert_equal 6, @ir.fetch('objects').length
    assert_equal 4, @ir.fetch('facts').length
    assert_equal 3, @ir.fetch('events').length
    assert_equal 1, @ir.fetch('if_rules').length
  end

  def test_definite_kind_relation_target_resolves_to_single_object
    table_fact = @ir.fetch('facts').find { |fact| fact.fetch('relation') == 'on' }
    target = table_fact.fetch('target')

    assert_equal 'object', target.fetch('type')
    assert_equal 'the table', target.fetch('text')
    assert_equal 'oak table', target.fetch('name')
    assert_equal true, target.fetch('matched_by_kind')
  end

  def test_change_action_emits_target_and_state
    event = @ir.fetch('events').find { |item| item.dig('when', 'raw') == 'player attacks ember' }
    change_action = event.fetch('then').last

    assert_equal 'change', change_action.fetch('action')
    assert_equal 'ember', change_action.fetch('target').fetch('name')
    assert_equal 'state', change_action.fetch('to').fetch('kind')
    assert_equal 'angry', change_action.fetch('to').fetch('name')
  end
  def test_contextual_guard_reference_is_preserved_in_ir
    event = @ir.fetch('events').find { |item| item.dig('when', 'raw') == 'player attacks a guard' }
    trigger_target = event.dig('when', 'target')
    damage_target = event.fetch('then').first.fetch('target')

    assert_equal 'kind_one', trigger_target.fetch('type')
    assert_equal 'guard', trigger_target.fetch('kind_name')
    assert_equal ['henry'], trigger_target.fetch('candidates')
    assert_equal 'previous', damage_target.fetch('type')
    assert_equal 'guard', damage_target.fetch('kind_name')
  end

end
