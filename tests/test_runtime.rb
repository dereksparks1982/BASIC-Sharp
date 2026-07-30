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
    parser = BasicSharp::Parser.new(source)
    program = parser.parse
    BasicSharp::SemanticResolver.new(program, dictionary: parser.dictionary).resolve
  end

  def resolved_sample
    source = File.read(File.expand_path('../samples/first_room.bsharp', __dir__))
    resolve(source)
  end

  def runtime
    BasicSharp::Runtime.new(resolved_sample)
  end

  def thing(snapshot, name)
    snapshot.find { |entry| entry.fetch('name') == name }
  end

  def test_creates_things_applies_start_facts_and_runs_starting_if
    machine = runtime
    state = machine.snapshot

    assert_equal 7, state.length
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
    machine = BasicSharp::Runtime.new(resolve(<<~DKS))
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
      File.write(path, "#{BasicSharp::IREmitter.new(resolved_sample).to_json}\n")
      machine = BasicSharp::Runtime.load(path)
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


  def test_wyrm_matches_parent_grandparent_and_root_triggers
    source = <<~DKS
      KINDS
      [creature is a thing
      dragon is a creature
      wyrm is a dragon].

      DEFINE
      [a wyrm named ember].

      WHEN
      [player takes a wyrm
      <then> (damage that wyrm].

      WHEN
      [player attacks a dragon
      <then> (damage that dragon].

      WHEN
      [player speaks a creature
      <then> (damage that creature].

      WHEN
      [player gives a thing
      <then> (damage that thing].
    DKS
    machine = BasicSharp::Runtime.new(resolve(source))

    direct = machine.run_event('player takes ember')
    parent = machine.run_event('player attacks ember')
    grandparent = machine.run_event('player speaks ember')
    root = machine.run_event('player gives ember')

    assert_equal 'player takes a wyrm', direct.fetch('matched_when')
    assert_equal({ 'wyrm' => 'ember' }, direct.fetch('context'))
    assert_equal 'player attacks a dragon', parent.fetch('matched_when')
    assert_equal({ 'dragon' => 'ember' }, parent.fetch('context'))
    assert_equal 'player speaks a creature', grandparent.fetch('matched_when')
    assert_equal({ 'creature' => 'ember' }, grandparent.fetch('context'))
    assert_equal 'player gives a thing', root.fetch('matched_when')
    assert_equal({ 'thing' => 'ember' }, root.fetch('context'))
    assert_equal 4, thing(root.fetch('state'), 'ember').fetch('damage')
  end

  def test_nearest_kind_trigger_wins_over_more_distant_ancestor
    machine = BasicSharp::Runtime.new(resolve(<<~DKS))
      KINDS
      [creature is a thing
      dragon is a creature
      wyrm is a dragon].

      DEFINE
      [a wyrm named ember].

      WHEN
      [player attacks a creature
      <then> (change that creature to hostile].

      WHEN
      [player attacks a dragon
      <then> (change that dragon to angry].
    DKS

    result = machine.run_event('player attacks ember')
    ember = thing(result.fetch('state'), 'ember')

    assert_equal 'player attacks a dragon', result.fetch('matched_when')
    assert_equal({ 'dragon' => 'ember' }, result.fetch('context'))
    assert_equal ['angry'], ember.fetch('states')
  end

  def test_exact_trigger_still_wins_over_inherited_kind_trigger
    machine = runtime
    result = machine.run_event('player attacks ember')

    assert_equal 'player attacks ember', result.fetch('matched_when')
    assert_empty result.fetch('context')
  end

  def test_saved_dkir_rejects_unknown_kind_parent_plainly
    document = resolved_sample.to_h
    document.fetch(:kinds) << { 'name' => 'shade', 'parent' => 'missing kind', 'line_number' => 1 }

    error = assert_raises(ArgumentError) { BasicSharp::Runtime.new(document) }
    assert_equal 'Kind family is broken: shade has unknown parent missing kind', error.message
  end

  def test_saved_dkir_rejects_kind_family_loop_with_path
    document = resolved_sample.to_h
    document.fetch(:kinds) << { 'name' => 'thing', 'parent' => 'wyrm', 'line_number' => 1 }

    error = assert_raises(ArgumentError) { BasicSharp::Runtime.new(document) }
    assert_equal 'Kind family has a loop: creature -> thing -> wyrm -> dragon -> creature', error.message
  end

end
