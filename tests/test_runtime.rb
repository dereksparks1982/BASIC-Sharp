# frozen_string_literal: true

require 'json'
require 'minitest/autorun'
require 'tmpdir'
require_relative '../compiler/parser'
require_relative '../compiler/resolver'
require_relative '../compiler/ir_emitter'
require_relative '../compiler/runtime'

class TestRuntime < Minitest::Test
  def resolve(source)
    parser = DKScript::Parser.new(source)
    program = parser.parse
    DKScript::SemanticResolver.new(program, dictionary: parser.dictionary).resolve
  end

  def resolved_sample
    source = File.read(File.expand_path('../samples/first_room.dks', __dir__))
    resolve(source)
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

  def test_exact_attack_event_still_runs_damage_and_change
    machine = runtime
    result = machine.run_event('player attacks ember')
    ember = thing(result.fetch('state'), 'ember')

    assert_equal true, result.fetch('matched')
    assert_equal 'player attacks ember', result.fetch('matched_when')
    assert_equal ['(damage ember', '(change ember to angry'], result.fetch('ran')
    assert_equal(
      [
        { 'word' => '(damage ember', 'change' => 'ember damage is now 1' },
        { 'word' => '(change ember to angry', 'change' => 'ember is now angry' }
      ],
      result.fetch('steps')
    )
    assert_empty result.fetch('understood')
    assert_empty result.fetch('context')
    assert_nil result.fetch('error')
    assert_equal 1, ember.fetch('damage')
    assert_equal ['angry'], ember.fetch('states')
  end

  def test_kind_trigger_selects_henry_and_that_guard_uses_henry
    machine = runtime
    result = machine.run_event('player attacks henry')
    henry = thing(result.fetch('state'), 'henry')

    assert_equal true, result.fetch('matched')
    assert_equal 'player attacks a guard', result.fetch('matched_when')
    assert_equal({ 'guard' => 'henry' }, result.fetch('context'))
    assert_equal ['a guard means henry', 'that guard means henry'], result.fetch('understood')
    assert_equal ['(damage henry', '(change henry to angry'], result.fetch('ran')
    assert_equal(
      [
        { 'word' => '(damage henry', 'change' => 'henry damage is now 1' },
        { 'word' => '(change henry to angry', 'change' => 'henry is now angry' }
      ],
      result.fetch('steps')
    )
    assert_nil result.fetch('error')
    assert_equal 1, henry.fetch('damage')
    assert_equal ['angry'], henry.fetch('states')
  end

  def test_kind_trigger_reports_unknown_thing
    machine = runtime
    result = machine.run_event('player attacks ghost')

    assert_equal false, result.fetch('matched')
    assert_equal "event Thing 'ghost' is not defined", result.fetch('error')
    assert_nil result.fetch('matched_when')
    assert_empty result.fetch('understood')
    assert_empty result.fetch('steps')
    assert_empty result.fetch('ran')
  end

  def test_kind_trigger_reports_wrong_kind
    machine = DKScript::Runtime.new(resolve(<<~DKS))
      KINDS
      [dragon is a creature].

      DEFINE
      [a guard named henry
      a dragon named ember].

      WHEN
      [player attacks a guard
      <then> (damage that guard].
    DKS

    result = machine.run_event('player attacks ember')

    assert_equal false, result.fetch('matched')
    assert_equal 'ember is a dragon, not a guard', result.fetch('error')
    assert_empty result.fetch('ran')
  end

  def test_take_event_runs_carry
    machine = runtime
    result = machine.run_event('player takes brass key')
    key = thing(result.fetch('state'), 'brass key')

    assert_equal true, result.fetch('matched')
    assert_equal ['(carry brass key'], result.fetch('ran')
    assert_equal(
      [{ 'word' => '(carry brass key', 'change' => 'brass key is now carried by player' }],
      result.fetch('steps')
    )
    assert_equal({ 'carried by' => 'player' }, key.fetch('relations'))
  end

  def test_unknown_event_does_not_change_state
    machine = runtime
    before = machine.snapshot
    result = machine.run_event('player sings to ember')

    assert_equal false, result.fetch('matched')
    assert_empty result.fetch('ran')
    assert_nil result.fetch('error')
    assert_equal before, result.fetch('state')
  end

  def test_loads_existing_dkir_json_and_keeps_trigger_context
    Dir.mktmpdir do |dir|
      path = File.join(dir, 'first_room.ir.json')
      File.write(path, "#{DKScript::IREmitter.new(resolved_sample).to_json}\n")
      machine = DKScript::Runtime.load(path)
      result = machine.run_event('player attacks henry')

      assert_equal true, result.fetch('matched')
      assert_equal 'player attacks a guard', result.fetch('matched_when')
      assert_equal({ 'guard' => 'henry' }, result.fetch('context'))
      assert_equal ['a guard means henry', 'that guard means henry'], result.fetch('understood')
      assert_equal(
        [
          { 'word' => '(damage henry', 'change' => 'henry damage is now 1' },
          { 'word' => '(change henry to angry', 'change' => 'henry is now angry' }
        ],
        result.fetch('steps')
      )
      assert_equal 1, thing(result.fetch('state'), 'henry').fetch('damage')
    end
  end
  def test_plain_language_report_explains_kind_match_and_changes
    machine = runtime
    result = machine.run_event('player attacks henry')
    report = machine.report(result)

    assert_includes report, 'what matched:'
    assert_includes report, '  player attacks a guard'
    assert_includes report, 'what I understood:'
    assert_includes report, '  a guard means henry'
    assert_includes report, '  that guard means henry'
    assert_includes report, 'what happened:'
    assert_includes report, '  (damage henry'
    assert_includes report, '  henry damage is now 1'
    assert_includes report, '  (change henry to angry'
    assert_includes report, '  henry is now angry'
  end

end
