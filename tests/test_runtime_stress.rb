# frozen_string_literal: true

require 'json'
require 'minitest/autorun'
require 'tmpdir'
require_relative '../compiler/parser'
require_relative '../compiler/resolver'
require_relative '../compiler/ir_emitter'
require_relative '../compiler/runtime'

class TestRuntimeStress < Minitest::Test
  GUARD_COUNT = 300
  DRAGON_COUNT = 200
  REPEATED_EVENT_COUNT = 2_000

  def resolve(source)
    parser = BasicSharp::Parser.new(source)
    program = parser.parse
    resolved = BasicSharp::SemanticResolver.new(program, dictionary: parser.dictionary).resolve
    errors = resolved.diagnostics.select { |diagnostic| diagnostic.severity == 'error' }
    raise "stress source did not resolve: #{errors.map(&:message).join('; ')}" unless errors.empty?

    resolved
  end

  def stress_source(guards: GUARD_COUNT, dragons: DRAGON_COUNT)
    definitions = []
    guards.times { |index| definitions << "a guard named guard #{index + 1}" }
    dragons.times { |index| definitions << "a wyrm named dragon #{index + 1}" }
    definitions << 'a key named stress key'
    definitions << 'a table named stress table'
    definitions << 'a door named stress door'

    exact_rule = if guards >= 250
                   <<~RULE
                     WHEN
                     [player attacks guard 250
                     <then> (change guard 250 to hostile].

                   RULE
                 else
                   ''
                 end

    <<~DKS
      KINDS
      [creature is a thing
      dragon is a creature
      wyrm is a dragon].

      DEFINE
      [#{definitions.join("\n")}].

      START
      [guard 1 is calm
      dragon 1 is calm
      stress key is on stress table
      stress door is locked].

      IF
      [stress door is locked
      <then> (unlock stress door].

      #{exact_rule}WHEN
      [player attacks a guard
      <then> (damage that guard
      <then> (change that guard to angry].

      WHEN
      [player attacks dragon 1
      <then> (damage dragon 1
      <then> (change dragon 1 to angry].

      WHEN
      [player attacks a creature
      <then> (damage that creature
      <then> (change that creature to angry].

      WHEN
      [player takes stress key
      <then> (carry stress key].
    DKS
  end

  def runtime_from_source(guards: GUARD_COUNT, dragons: DRAGON_COUNT)
    BasicSharp::Runtime.new(resolve(stress_source(guards: guards, dragons: dragons)))
  end

  def thing(snapshot, name)
    snapshot.find { |entry| entry.fetch('name') == name }
  end

  def run_sequence(machine, events)
    events.each { |event| machine.run_event(event) }
    machine.snapshot
  end

  def test_hundreds_of_things_compile_and_context_selects_named_guard
    machine = runtime_from_source
    result = machine.run_event('player attacks guard 299')
    guard = thing(result.fetch('state'), 'guard 299')

    assert_equal GUARD_COUNT + DRAGON_COUNT + 4, result.fetch('state').length
    assert_equal true, result.fetch('matched')
    assert_equal 'player attacks a guard', result.fetch('matched_when')
    assert_equal({ 'guard' => 'guard 299' }, result.fetch('context'))
    assert_equal ['a guard means guard 299', 'that guard means guard 299'], result.fetch('understood')
    assert_equal 1, guard.fetch('damage')
    assert_equal ['angry'], guard.fetch('states')
  end


  def test_hundreds_of_descendants_match_ancestor_kind_under_load
    machine = runtime_from_source
    result = machine.run_event('player attacks dragon 199')
    descendant = thing(result.fetch('state'), 'dragon 199')

    assert_equal true, result.fetch('matched')
    assert_equal 'player attacks a creature', result.fetch('matched_when')
    assert_equal({ 'creature' => 'dragon 199' }, result.fetch('context'))
    assert_equal ['a creature means dragon 199', 'that creature means dragon 199'], result.fetch('understood')
    assert_equal 1, descendant.fetch('damage')
    assert_equal ['angry'], descendant.fetch('states')
  end

  def test_exact_trigger_wins_before_kind_trigger
    machine = runtime_from_source
    result = machine.run_event('player attacks guard 250')
    guard = thing(result.fetch('state'), 'guard 250')

    assert_equal true, result.fetch('matched')
    assert_equal 'player attacks guard 250', result.fetch('matched_when')
    assert_empty result.fetch('context')
    assert_empty result.fetch('understood')
    assert_equal ['(change guard 250 to hostile'], result.fetch('ran')
    refute guard.key?('damage')
    assert_equal ['hostile'], guard.fetch('states')
  end

  def test_two_thousand_repeated_events_keep_context_local_and_counts_exact
    machine = runtime_from_source(guards: 30, dragons: 5)
    counts = Hash.new(0)

    REPEATED_EVENT_COUNT.times do |index|
      guard_number = (index % 30) + 1
      next if guard_number == 250

      name = "guard #{guard_number}"
      result = machine.run_event("player attacks #{name}")
      counts[name] += 1

      assert_equal({ 'guard' => name }, result.fetch('context'))
      assert_equal "that guard means #{name}", result.fetch('understood').last
    end

    snapshot = machine.snapshot
    counts.each do |name, expected|
      assert_equal expected, thing(snapshot, name).fetch('damage')
    end
  end

  def test_context_does_not_leak_into_later_exact_or_unknown_events
    machine = runtime_from_source(guards: 10, dragons: 2)
    first = machine.run_event('player attacks guard 7')
    exact = machine.run_event('player attacks dragon 1')
    unknown = machine.run_event('player sings to guard 7')

    assert_equal({ 'guard' => 'guard 7' }, first.fetch('context'))
    assert_empty exact.fetch('context')
    assert_empty exact.fetch('understood')
    assert_empty unknown.fetch('context')
    assert_empty unknown.fetch('understood')
    assert_empty unknown.fetch('ran')
  end

  def test_separate_runtime_sessions_never_share_state
    first = runtime_from_source(guards: 10, dragons: 2)
    second = runtime_from_source(guards: 10, dragons: 2)

    20.times { first.run_event('player attacks guard 3') }

    assert_equal 20, thing(first.snapshot, 'guard 3').fetch('damage')
    refute thing(second.snapshot, 'guard 3').key?('damage')
    assert_equal ['calm'], thing(second.snapshot, 'guard 1').fetch('states')
  end

  def test_source_and_saved_dkir_remain_identical_after_long_sequence
    source = stress_source(guards: 40, dragons: 10)
    resolved = resolve(source)
    source_machine = BasicSharp::Runtime.new(resolved)

    Dir.mktmpdir do |dir|
      path = File.join(dir, 'stress.ir.json')
      File.write(path, "#{BasicSharp::IREmitter.new(resolved).to_json}\n")
      ir_machine = BasicSharp::Runtime.load(path)

      events = []
      500.times do |index|
        events << "player attacks guard #{(index % 40) + 1}"
        events << 'player attacks dragon 1' if (index % 25).zero?
      end
      events << 'player takes stress key'

      assert_equal run_sequence(source_machine, events), run_sequence(ir_machine, events)
    end
  end

  def test_same_world_and_same_events_are_deterministic
    events = Array.new(300) { |index| "player attacks guard #{(index % 25) + 1}" }
    first = runtime_from_source(guards: 25, dragons: 5)
    second = runtime_from_source(guards: 25, dragons: 5)

    assert_equal run_sequence(first, events), run_sequence(second, events)
  end

  def test_unknown_thing_and_wrong_kind_remain_plain_under_load
    machine = runtime_from_source

    unknown = machine.run_event('player attacks missing guard')
    inherited = machine.run_event('player attacks dragon 2')
    wrong_kind = machine.run_event('player attacks stress door')

    assert_equal false, unknown.fetch('matched')
    assert_equal "event Thing 'missing guard' is not defined", unknown.fetch('error')
    assert_equal true, inherited.fetch('matched')
    assert_equal 'player attacks a creature', inherited.fetch('matched_when')
    assert_equal({ 'creature' => 'dragon 2' }, inherited.fetch('context'))
    assert_equal false, wrong_kind.fetch('matched')
    assert_equal 'stress door is a door, not a guard', wrong_kind.fetch('error')
  end

  def test_carry_and_starting_if_remain_correct_in_large_world
    machine = runtime_from_source
    key_before = thing(machine.snapshot, 'stress key')
    door = thing(machine.snapshot, 'stress door')

    assert_equal({ 'on' => 'stress table' }, key_before.fetch('relations'))
    assert_equal ['unlocked'], door.fetch('states')

    result = machine.run_event('player takes stress key')
    key_after = thing(result.fetch('state'), 'stress key')

    assert_equal({ 'carried by' => 'player' }, key_after.fetch('relations'))
    assert_equal 'stress key is now carried by player', result.fetch('steps').first.fetch('change')
  end

  def test_trace_damage_number_stays_truthful_after_repeated_runs
    machine = runtime_from_source(guards: 10, dragons: 2)
    result = nil
    75.times { result = machine.run_event('player attacks guard 8') }

    report = machine.report(result)
    assert_includes report, 'guard 8 damage is now 75'
    assert_includes report, 'guard 8: kind=guard; states=angry; damage=75'
  end

  def test_duplicate_dkir_thing_names_are_rejected_instead_of_overwritten
    document = resolve(stress_source(guards: 2, dragons: 1)).to_h
    duplicate = document.fetch(:objects).find { |object| object.fetch('name') == 'guard 1' }.dup
    document.fetch(:objects) << duplicate

    error = assert_raises(ArgumentError) { BasicSharp::Runtime.new(document) }
    assert_equal "DKIR has more than one Thing named 'guard 1'", error.message
  end

  def test_missing_or_wrong_dkir_format_is_rejected
    document = resolve(stress_source(guards: 2, dragons: 1)).to_h
    document.delete(:format)

    error = assert_raises(ArgumentError) { BasicSharp::Runtime.new(document) }
    assert_equal "DKIR format '(missing)' is not supported", error.message
  end
end
