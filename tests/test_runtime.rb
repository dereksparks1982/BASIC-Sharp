# frozen_string_literal: true

require 'json'
require 'minitest/autorun'
require 'tmpdir'
require_relative '../compiler/parser'
require_relative '../compiler/resolver'
require_relative '../compiler/ir_emitter'
require_relative '../compiler/runtime'

class TestRuntime < Minitest::Test
  def resolved_sample
    source = File.read(File.expand_path('../samples/first_room.dks', __dir__))
    parser = DKScript::Parser.new(source)
    program = parser.parse
    DKScript::SemanticResolver.new(program, dictionary: parser.dictionary).resolve
  end

  def runtime
    DKScript::Runtime.new(resolved_sample)
  end

  def thing(snapshot, name)
    snapshot.find { |entry| entry.fetch('name') == name }
  end

  def test_creates_things_applies_start_facts_and_runs_starting_if
    machine = runtime
    state = machine.snapshot

    assert_equal 6, state.length
    assert_equal ['calm'], thing(state, 'ember').fetch('states')
    assert_equal ['unlocked'], thing(state, 'north door').fetch('states')
    assert_equal({ 'on' => 'oak table' }, thing(state, 'brass key').fetch('relations'))
    assert_equal ['(unlock north door'], machine.startup_ran
  end

  def test_attack_event_runs_damage_and_change
    machine = runtime
    result = machine.run_event('player attacks ember')
    ember = thing(result.fetch('state'), 'ember')

    assert_equal true, result.fetch('matched')
    assert_equal ['(damage ember', '(change ember to angry'], result.fetch('ran')
    assert_equal 1, ember.fetch('damage')
    assert_equal ['angry'], ember.fetch('states')
  end

  def test_take_event_runs_carry
    machine = runtime
    result = machine.run_event('player takes brass key')
    key = thing(result.fetch('state'), 'brass key')

    assert_equal true, result.fetch('matched')
    assert_equal ['(carry brass key'], result.fetch('ran')
    assert_equal({ 'carried by' => 'player' }, key.fetch('relations'))
  end

  def test_unknown_event_does_not_change_state
    machine = runtime
    before = machine.snapshot
    result = machine.run_event('player sings to ember')

    assert_equal false, result.fetch('matched')
    assert_empty result.fetch('ran')
    assert_equal before, result.fetch('state')
  end

  def test_loads_existing_dkir_json
    Dir.mktmpdir do |dir|
      path = File.join(dir, 'first_room.ir.json')
      File.write(path, "#{DKScript::IREmitter.new(resolved_sample).to_json}\n")
      machine = DKScript::Runtime.load(path)
      result = machine.run_event('player attacks ember')

      assert_equal true, result.fetch('matched')
      assert_equal 1, thing(result.fetch('state'), 'ember').fetch('damage')
    end
  end
end
