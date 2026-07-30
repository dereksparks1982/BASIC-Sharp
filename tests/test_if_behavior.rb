# frozen_string_literal: true

require 'json'
require 'minitest/autorun'
require 'tmpdir'
require_relative '../compiler/parser'
require_relative '../compiler/resolver'
require_relative '../compiler/ir_emitter'
require_relative '../compiler/runtime'

class TestIfBehavior < Minitest::Test
  def resolve(source)
    parser = BasicSharp::Parser.new(source)
    program = parser.parse
    document = BasicSharp::SemanticResolver.new(program, dictionary: parser.dictionary).resolve
    errors = document.diagnostics.select { |diagnostic| diagnostic.severity == 'error' }
    raise errors.map(&:message).join("\n") unless errors.empty?

    document
  end

  def runtime(source)
    BasicSharp::Runtime.new(resolve(source))
  end

  def thing(snapshot, name)
    snapshot.find { |entry| entry.fetch('name') == name }
  end

  def test_startup_true_if_wakes_once_and_records_reason
    machine = runtime(<<~BASIC_SHARP)
      DEFINE
      [a door named north door].

      START
      [north door is locked].

      IF
      [north door is locked
      <then> (unlock north door].
    BASIC_SHARP

    assert_equal ['(unlock north door'], machine.startup_ran
    assert_equal 1, machine.startup_if_rules.length
    assert_equal 'north door is locked', machine.startup_if_rules.first.fetch('condition')
    assert_equal 'was true after START', machine.startup_if_rules.first.fetch('reason')
    assert_nil machine.startup_if_error
    assert_equal ['unlocked'], thing(machine.snapshot, 'north door').fetch('states')
  end

  def test_startup_false_if_stays_asleep
    machine = runtime(<<~BASIC_SHARP)
      DEFINE
      [a person named henry].

      START
      [henry is calm].

      IF
      [henry is angry
      <then> (damage player].
    BASIC_SHARP

    assert_empty machine.startup_if_rules
    assert_empty machine.startup_ran
    refute thing(machine.snapshot, 'player').key?('damage')
  end

  def test_when_can_make_if_true_after_complete_action_list
    machine = runtime(<<~BASIC_SHARP)
      DEFINE
      [a creature named ember].

      START
      [ember is calm].

      WHEN
      [player attacks ember
      <then> (change ember to angry].

      IF
      [ember is angry
      <then> (damage player].
    BASIC_SHARP

    result = machine.run_event('player attacks ember')

    assert_equal 1, result.fetch('if_rules').length
    assert_equal 'became true after the event', result.fetch('if_rules').first.fetch('reason')
    assert_equal ['(damage player'], result.fetch('if_rules').first.fetch('steps').map { |step| step.fetch('word') }
    assert_equal 1, thing(result.fetch('state'), 'player').fetch('damage')
  end

  def test_true_if_does_not_repeat_for_unrelated_events
    machine = runtime(reactivation_source)

    first = machine.run_event('player attacks ember')
    second = machine.run_event('player gives brass key')

    assert_equal 1, thing(first.fetch('state'), 'player').fetch('damage')
    assert_empty second.fetch('if_rules')
    assert_equal 1, thing(second.fetch('state'), 'player').fetch('damage')
  end

  def test_false_condition_rearms_and_may_wake_again
    machine = runtime(reactivation_source)

    first = machine.run_event('player attacks ember')
    calm = machine.run_event('player speaks ember')
    second = machine.run_event('player attacks ember')

    assert_equal 1, thing(first.fetch('state'), 'player').fetch('damage')
    assert_empty calm.fetch('if_rules')
    assert_equal 2, thing(second.fetch('state'), 'player').fetch('damage')
    assert_equal 1, second.fetch('if_rules').length
  end

  def test_mid_when_state_does_not_wake_if_final_state_is_false
    machine = runtime(<<~BASIC_SHARP)
      DEFINE
      [a creature named ember].

      START
      [ember is calm].

      WHEN
      [player attacks ember
      <then> (change ember to angry
      <then> (change ember to calm].

      IF
      [ember is angry
      <then> (damage player].
    BASIC_SHARP

    result = machine.run_event('player attacks ember')

    assert_empty result.fetch('if_rules')
    refute thing(result.fetch('state'), 'player').key?('damage')
    assert_equal ['calm'], thing(result.fetch('state'), 'ember').fetch('states')
  end

  def test_isnt_condition_wakes_after_unlock
    machine = runtime(<<~BASIC_SHARP)
      DEFINE
      [a creature named ember
      a door named north door
      a person named henry].

      START
      [ember is calm
      north door is locked
      henry is calm].

      WHEN
      [player attacks ember
      <then> (unlock north door].

      IF
      [north door isnt locked
      <then> (change henry to friendly].
    BASIC_SHARP

    result = machine.run_event('player attacks ember')

    assert_equal ['calm', 'friendly'], thing(result.fetch('state'), 'henry').fetch('states')
    assert_equal 'north door isnt locked', result.fetch('if_rules').first.fetch('condition')
  end

  def test_relationship_condition_wakes_at_startup
    machine = runtime(<<~BASIC_SHARP)
      DEFINE
      [a key named brass key
      a table named oak table
      a door named north door].

      START
      [brass key is on oak table
      north door is locked].

      IF
      [brass key is on oak table
      <then> (unlock north door].
    BASIC_SHARP

    assert_equal ['unlocked'], thing(machine.snapshot, 'north door').fetch('states')
    assert_equal 'brass key is on oak table', machine.startup_if_rules.first.fetch('condition')
  end

  def test_if_rules_run_in_source_order
    machine = runtime(<<~BASIC_SHARP)
      DEFINE
      [a creature named ember
      a door named north door
      a person named henry].

      START
      [ember is angry
      north door is locked
      henry is calm].

      IF
      [ember is angry
      <then> (unlock north door].

      IF
      [ember is angry
      <then> (change henry to friendly].
    BASIC_SHARP

    assert_equal ['(unlock north door', '(change henry to friendly'], machine.startup_ran
  end

  def test_later_rule_can_wake_earlier_rule_on_next_pass
    machine = runtime(<<~BASIC_SHARP)
      DEFINE
      [a creature named ember
      a door named north door
      a person named henry].

      START
      [ember is calm
      north door is locked
      henry is calm].

      WHEN
      [player attacks ember
      <then> (change ember to angry].

      IF
      [north door is unlocked
      <then> (change henry to friendly].

      IF
      [ember is angry
      <then> (unlock north door].
    BASIC_SHARP

    result = machine.run_event('player attacks ember')

    assert_equal ['ember is angry', 'north door is unlocked'], result.fetch('if_rules').map { |entry| entry.fetch('condition') }
    assert_equal ['calm', 'friendly'], thing(result.fetch('state'), 'henry').fetch('states')
  end

  def test_startup_if_cascade_settles
    machine = runtime(<<~BASIC_SHARP)
      DEFINE
      [a creature named ember
      a door named north door
      a person named henry].

      START
      [ember is angry
      north door is locked
      henry is calm].

      IF
      [ember is angry
      <then> (unlock north door].

      IF
      [north door is unlocked
      <then> (change henry to friendly].
    BASIC_SHARP

    assert_equal ['ember is angry', 'north door is unlocked'], machine.startup_if_rules.map { |entry| entry.fetch('condition') }
    assert_equal ['calm', 'friendly'], thing(machine.snapshot, 'henry').fetch('states')
  end

  def test_runtime_instances_keep_separate_if_memory
    document = resolve(reactivation_source)
    first = BasicSharp::Runtime.new(document)
    second = BasicSharp::Runtime.new(document)

    first.run_event('player attacks ember')
    second_result = second.run_event('player attacks ember')

    assert_equal 1, thing(first.snapshot, 'player').fetch('damage')
    assert_equal 1, thing(second_result.fetch('state'), 'player').fetch('damage')
    assert_equal 1, second_result.fetch('if_rules').length
  end

  def test_source_and_saved_bsir_keep_if_trace_and_world_parity
    document = resolve(reactivation_source)
    source_machine = BasicSharp::Runtime.new(document)
    source_result = source_machine.run_event('player attacks ember')

    Dir.mktmpdir do |dir|
      path = File.join(dir, 'reactive_if.bsir.json')
      File.write(path, "#{BasicSharp::IREmitter.new(document).to_json}\n")
      saved_machine = BasicSharp::Runtime.load(path)
      saved_result = saved_machine.run_event('player attacks ember')

      assert_equal source_result.fetch('if_rules'), saved_result.fetch('if_rules')
      assert_equal source_result.fetch('state'), saved_result.fetch('state')
      assert_equal source_machine.startup_if_rules, saved_machine.startup_if_rules
    end
  end

  def test_startup_loop_is_stopped_without_raising
    machine = runtime(<<~BASIC_SHARP)
      DEFINE
      [a creature named ember].

      START
      [ember is calm].

      IF
      [ember is calm
      <then> (change ember to angry].

      IF
      [ember is angry
      <then> (change ember to calm].
    BASIC_SHARP

    assert_includes machine.startup_if_error, 'IF rules kept waking each other.'
    assert_includes machine.startup_if_error, 'BASIC# stopped this chain so it would not run forever.'
    assert_equal ['calm'], thing(machine.snapshot, 'ember').fetch('states')
    assert_equal 2, machine.startup_if_rules.length
  end

  def test_event_time_loop_is_stopped_and_world_remains_visible
    machine = runtime(<<~BASIC_SHARP)
      DEFINE
      [a creature named ember].

      START
      [ember is friendly].

      WHEN
      [player attacks ember
      <then> (change ember to calm].

      IF
      [ember is calm
      <then> (change ember to angry].

      IF
      [ember is angry
      <then> (change ember to calm].
    BASIC_SHARP

    result = machine.run_event('player attacks ember')

    assert_equal true, result.fetch('matched')
    assert_includes result.fetch('error'), 'IF rules kept waking each other.'
    assert_equal ['calm', 'friendly'], thing(result.fetch('state'), 'ember').fetch('states')
    assert_equal 2, result.fetch('if_rules').length
  end

  def test_report_shows_reactive_if_reason_actions_and_change
    machine = runtime(reactivation_source)
    report = machine.report(machine.run_event('player attacks ember'))

    assert_includes report, 'IF rules:'
    assert_includes report, '  ember is angry became true after the event'
    assert_includes report, '  ran:'
    assert_includes report, '    (damage player'
    assert_includes report, '    player damage is now 1'
  end

  private

  def reactivation_source
    <<~BASIC_SHARP
      DEFINE
      [a creature named ember
      a key named brass key].

      START
      [ember is calm].

      WHEN
      [player attacks ember
      <then> (change ember to angry].

      WHEN
      [player speaks ember
      <then> (change ember to calm].

      WHEN
      [player gives brass key
      <then> (carry brass key].

      IF
      [ember is angry
      <then> (damage player].
    BASIC_SHARP
  end
end
