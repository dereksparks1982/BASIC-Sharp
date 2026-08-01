# frozen_string_literal: true

require 'json'
require 'minitest/autorun'
require 'tmpdir'
require_relative '../compiler/parser'
require_relative '../compiler/resolver'
require_relative '../compiler/ir_emitter'
require_relative '../compiler/runtime'

class TestFollowUpEvents < Minitest::Test
  LIMIT_MESSAGE = <<~TEXT.chomp
    Events kept causing more events.

    BASIC# stopped this chain after 1,024 follow-up events so it would not run forever.
  TEXT

  def resolve(source)
    parser = BasicSharp::Parser.new(source)
    program = parser.parse
    BasicSharp::SemanticResolver.new(program, dictionary: parser.dictionary).resolve
  end

  def runtime(source)
    BasicSharp::Runtime.new(resolve(source))
  end

  def thing(snapshot, name)
    snapshot.find { |entry| entry.fetch('name') == name }
  end

  def chain_source
    <<~BSHARP
      DEFINE
      [
          @henry is a #guard
          @mara is a #guard
          @brass bell is a #device
          @brass key is a #key
      ].

      START
      [
          @henry is calm
          @mara is calm
      ].

      WHEN PLAYER sounds @brass bell
      [
          |then (cause @henry attacks PLAYER
          |then (change @henry to angry
          |then (cause PLAYER takes @brass key
      ].

      IF @henry is angry
      [
          |then (cause @mara sounds @brass bell
      ].

      WHEN @henry attacks PLAYER
      [
          |then (cause @henry sounds @brass bell
      ].

      WHEN PLAYER takes @brass key
      [
          |then (damage PLAYER
      ].

      WHEN @mara sounds @brass bell
      [
          |then (damage @henry
      ].

      WHEN @henry sounds @brass bell
      [
          |then (damage @mara
      ].
    BSHARP
  end

  def test_cause_compiles_to_an_explicit_event_template
    document = resolve(<<~BSHARP).to_h
      DEFINE
      [
          @henry is a #guard
      ].

      WHEN PLAYER attacks a #guard
      [
          |then (cause it attacks PLAYER
      ].
    BSHARP

    assert_empty document.fetch(:diagnostics)
    cause = document.fetch(:events).first.fetch('then').first
    assert_equal 'cause', cause.fetch('action')
    assert_equal 'that guard attacks player', cause.dig('event', 'raw')
    assert_equal 'previous', cause.dig('event', 'actor', 'type')
    assert_equal 'guard', cause.dig('event', 'actor', 'kind_name')
    assert_equal 'attack', cause.dig('event', 'action')
    assert_equal 'player', cause.dig('event', 'target', 'name')
    refute cause.key?('target')
  end

  def test_parser_preserves_to_and_by_inside_caused_event_names
    document = resolve(<<~BSHARP).to_h
      DEFINE
      [
          @brass bell is a #device
          @road to town is a #place
          @guard by river is a #guard
      ].

      WHEN PLAYER sounds @brass bell
      [
          |then (cause PLAYER takes @road to town
          |then (cause PLAYER attacks @guard by river
      ].
    BSHARP

    assert_empty document.fetch(:diagnostics)
    causes = document.fetch(:events).first.fetch('then')
    assert_equal 'player takes road to town', causes[0].dig('event', 'raw')
    assert_equal 'road to town', causes[0].dig('event', 'target', 'name')
    assert_equal 'player attacks guard by river', causes[1].dig('event', 'raw')
    assert_equal 'guard by river', causes[1].dig('event', 'target', 'name')
  end

  def test_that_kind_is_captured_before_the_follow_up_event_runs
    machine = runtime(<<~BSHARP)
      DEFINE
      [
          @henry is a #guard
      ].

      WHEN PLAYER attacks a #guard
      [
          |then (damage it
          |then (cause it attacks PLAYER
      ].

      WHEN a #guard attacks PLAYER
      [
          |then (cause it sounds PLAYER
      ].

      WHEN a #guard sounds PLAYER
      [
          |then (damage PLAYER
      ].
    BSHARP

    result = machine.run_event('player attacks henry')
    events = result.fetch('follow_up_events')

    assert_equal %w[henry henry], events.map { |entry| entry.fetch('event').split.first }
    assert_equal ['henry attacks player', 'henry sounds player'], events.map { |entry| entry.fetch('event') }
    assert_equal({ 'guard' => 'henry' }, events.first.fetch('context'))
    assert_equal({ 'guard' => 'henry' }, events.last.fetch('context'))
    assert_equal 1, thing(result.fetch('state'), 'henry').fetch('damage')
    assert_equal 1, thing(result.fetch('state'), 'player').fetch('damage')
  end

  def test_whole_body_and_if_settlement_finish_before_fifo_follow_ups
    machine = runtime(chain_source)
    result = machine.run_event('player sounds brass bell')

    assert_equal [
      'henry attacks player',
      'player takes brass key',
      'mara sounds brass bell',
      'henry sounds brass bell'
    ], result.fetch('follow_up_events').map { |entry| entry.fetch('event') }
    assert_equal [
      '(cause henry attacks player',
      '(change henry to angry',
      '(cause player takes brass key'
    ], result.fetch('ran')
    assert_equal ['henry is angry'], result.fetch('if_rules').map { |entry| entry.fetch('condition') }
    assert_equal 1, thing(result.fetch('state'), 'player').fetch('damage')
    assert_equal 1, thing(result.fetch('state'), 'henry').fetch('damage')
    assert_equal 1, thing(result.fetch('state'), 'mara').fetch('damage')
  end

  def test_unmatched_follow_up_does_not_stop_later_events
    machine = runtime(<<~BSHARP)
      DEFINE
      [
          @henry is a #guard
          @brass bell is a #device
      ].

      WHEN PLAYER attacks @henry
      [
          |then (cause PLAYER speaks @henry
          |then (cause PLAYER sounds @brass bell
      ].

      WHEN PLAYER sounds @brass bell
      [
          |then (damage PLAYER
      ].
    BSHARP

    result = machine.run_event('player attacks henry')
    events = result.fetch('follow_up_events')

    assert_equal 2, events.length
    assert_equal false, events[0].fetch('matched')
    assert_nil events[0].fetch('error')
    assert_equal true, events[1].fetch('matched')
    assert_nil result.fetch('error')
    assert_equal 1, thing(result.fetch('state'), 'player').fetch('damage')
  end

  def test_failed_body_discards_its_staged_follow_ups
    machine = runtime(<<~BSHARP)
      DEFINE
      [
          @henry is a #guard
          @mara is a #guard
          @brass bell is a #device
      ].

      WHEN PLAYER sounds @brass bell
      [
          |then (damage @henry
          |then (cause @henry attacks PLAYER
          |then (change health of @mara to 7
      ].

      WHEN @henry attacks PLAYER
      [
          |then (damage PLAYER
      ].
    BSHARP

    result = machine.run_event('player sounds brass bell')
    cause_step = result.fetch('steps')[1]

    assert_equal 'mara does not have a value named health.', result.fetch('error')
    assert_empty result.fetch('follow_up_events')
    refute cause_step.key?('change')
    assert_equal ['henry attacks player will not happen because this action body did not finish.'], cause_step.fetch('notice_lines')
    assert_equal 1, thing(result.fetch('state'), 'henry').fetch('damage')
    assert_equal 0, thing(result.fetch('state'), 'player').fetch('values').fetch('damage')
  end

  def test_if_settlement_failure_discards_direct_and_if_caused_events
    machine = runtime(<<~BSHARP)
      DEFINE
      [
          @henry is a #guard
          @mara is a #guard
          @brass bell is a #device
      ].

      START
      [
          @henry is calm
      ].

      WHEN PLAYER sounds @brass bell
      [
          |then (cause @henry attacks PLAYER
          |then (change @henry to angry
      ].

      IF @henry is angry
      [
          |then (cause @mara sounds @brass bell
          |then (change health of @mara to 7
      ].

      WHEN @henry attacks PLAYER
      [
          |then (damage PLAYER
      ].
    BSHARP

    result = machine.run_event('player sounds brass bell')

    assert_equal 'mara does not have a value named health.', result.fetch('error')
    assert_empty result.fetch('follow_up_events')
    assert_equal ['IF rules did not finish, so this event will not happen.'], result.fetch('steps').first.fetch('notice_lines')
    if_cause = result.fetch('if_rules').first.fetch('steps').first
    assert_includes if_cause.fetch('notice_lines').join(' '), 'will not happen'
    assert_equal 0, thing(result.fetch('state'), 'player').fetch('values').fetch('damage')
  end

  def test_runtime_error_in_follow_up_stops_later_waiting_events
    document = resolve(<<~BSHARP).to_h
      DEFINE
      [
          @henry is a #guard
          @brass bell is a #device
      ].

      WHEN PLAYER attacks @henry
      [
          |then (cause @henry attacks PLAYER
          |then (cause PLAYER sounds @brass bell
      ].

      WHEN @henry attacks PLAYER
      [
          |then (damage PLAYER
      ].

      WHEN PLAYER sounds @brass bell
      [
          |then (damage PLAYER
      ].
    BSHARP
    bad_rule = document.fetch(:events).find { |rule| rule.dig('when', 'raw') == 'henry attacks player' }
    bad_rule.fetch('then').first['action'] = 'explode'

    result = BasicSharp::Runtime.new(document).run_event('player attacks henry')

    assert_equal 'runtime does not know how to run (explode', result.fetch('error')
    assert_equal ['henry attacks player'], result.fetch('follow_up_events').map { |entry| entry.fetch('event') }
    assert_equal 0, thing(result.fetch('state'), 'player').fetch('values').fetch('damage')
  end

  def test_event_chain_stops_after_1024_follow_ups_and_report_is_bounded
    machine = runtime(<<~BSHARP)
      DEFINE
      [
          @brass bell is a #device
      ].

      WHEN PLAYER sounds @brass bell
      [
          |then (cause PLAYER sounds @brass bell
      ].
    BSHARP

    result = machine.run_event('player sounds brass bell')
    report = machine.report(result)

    assert_equal LIMIT_MESSAGE, result.fetch('error')
    assert_equal 1_024, result.fetch('follow_up_events').length
    assert_equal ['player sounds brass bell'] * 3, result.fetch('event_trail')
    assert_includes report, 'event 1: player sounds brass bell'
    assert_includes report, 'event 1024: player sounds brass bell'
    assert_includes report, '... 1012 more follow-up events happened ...'
    assert_includes report, 'last events before BASIC# stopped:'
    assert_operator report.lines.length, :<, 150
  end

  def test_damage_and_change_do_not_create_hidden_events
    machine = runtime(<<~BSHARP)
      DEFINE
      [
          @henry is a #guard
      ].

      WHEN PLAYER attacks @henry
      [
          |then (damage @henry
          |then (change @henry to angry
      ].

      WHEN @henry sounds PLAYER
      [
          |then (damage PLAYER
      ].
    BSHARP

    result = machine.run_event('player attacks henry')

    assert_empty result.fetch('follow_up_events')
    assert_equal 0, thing(result.fetch('state'), 'player').fetch('values').fetch('damage')
    assert_equal 1, thing(result.fetch('state'), 'henry').fetch('damage')
    assert_equal ['angry'], thing(result.fetch('state'), 'henry').fetch('states')
  end

  def test_starting_if_can_cause_and_finish_a_follow_up_event
    machine = runtime(<<~BSHARP)
      DEFINE
      [
          @brass bell is a #device
      ].

      START
      [
          @brass bell is on
      ].

      IF @brass bell is on
      [
          |then (cause PLAYER sounds @brass bell
      ].

      WHEN PLAYER sounds @brass bell
      [
          |then (damage PLAYER
      ].
    BSHARP

    assert_equal ['player sounds brass bell'], machine.startup_follow_up_events.map { |entry| entry.fetch('event') }
    assert_nil machine.startup_if_error
    assert_equal 1, thing(machine.snapshot, 'player').fetch('damage')
  end

  def test_source_and_saved_bsir_have_identical_event_chains
    document = resolve(chain_source)
    source_result = BasicSharp::Runtime.new(document).run_event('player sounds brass bell')

    Dir.mktmpdir do |dir|
      path = File.join(dir, 'chain.bsir.json')
      File.write(path, "#{BasicSharp::IREmitter.new(document).to_json}\n")
      saved_result = BasicSharp::Runtime.load(path).run_event('player sounds brass bell')
      assert_equal source_result, saved_result
    end
  end

  def test_replay_is_deterministic_and_runtime_instances_are_isolated
    document = resolve(chain_source)
    first = BasicSharp::Runtime.new(document)
    second = BasicSharp::Runtime.new(document)

    first_result = first.run_event('player sounds brass bell')
    second_result = second.run_event('player sounds brass bell')

    assert_equal first_result, second_result
    first.run_event('player sounds brass bell')
    refute_equal first.snapshot, second.snapshot
  end

  def test_plain_report_explains_follow_up_origin_and_actions
    machine = runtime(<<~BSHARP)
      DEFINE
      [
          @henry is a #guard
      ].

      WHEN PLAYER attacks @henry
      [
          |then (cause @henry attacks PLAYER
      ].

      WHEN @henry attacks PLAYER
      [
          |then (damage PLAYER
      ].
    BSHARP
    report = machine.report(machine.run_event('player attacks henry'))

    assert_includes report, 'what happened next:'
    assert_includes report, 'event 1: henry attacks player'
    assert_includes report, 'caused by:'
    assert_includes report, '(cause henry attacks player'
    assert_includes report, 'henry attacks player will happen next'
    assert_includes report, 'player damage is now 1'
  end

  def test_cause_requires_a_concrete_event_thing
    vague = resolve(<<~BSHARP)
      DEFINE
      [
          @henry is a #guard
      ].
      WHEN PLAYER attacks @henry
      [
          |then (cause a #guard attacks PLAYER
      ].
    BSHARP
    every = resolve(<<~BSHARP)
      DEFINE
      [
          @henry is a #guard
      ].
      WHEN PLAYER attacks @henry
      [
          |then (cause every #guard attacks PLAYER
      ].
    BSHARP
    unbound = resolve(<<~BSHARP)
      DEFINE
      [
          @henry is a #guard
      ].
      WHEN PLAYER speaks
      [
          |then (cause it attacks PLAYER
      ].
    BSHARP

    assert_includes vague.diagnostics.map(&:message).join("\n"), 'cannot choose one guard for this caused event'
    assert_includes every.diagnostics.map(&:message).join("\n"), "'every guard' cannot be used inside (cause yet"
    assert_includes unbound.diagnostics.map(&:message).join("\n"), "'it' has no single object established in this scene"
  end

  def test_runtime_rejects_malformed_saved_cause_entry
    document = resolve(<<~BSHARP).to_h
      DEFINE
      [
          @henry is a #guard
      ].
      WHEN PLAYER attacks @henry
      [
          |then (cause @henry attacks PLAYER
      ].
    BSHARP
    document.fetch(:events).first.fetch('then').first.delete('event')

    error = assert_raises(ArgumentError) { BasicSharp::Runtime.new(document) }
    assert_equal '(cause is missing its event description', error.message
  end

  def test_cause_is_an_official_word_not_an_event_word
    document = resolve(<<~BSHARP)
      DEFINE
      [
          @brass bell is a #device
      ].
      WHEN PLAYER causes @brass bell
      [
          |then (damage PLAYER
      ].
    BSHARP

    assert_includes document.diagnostics.map(&:message).join("\n"), "event does not contain a known event word: 'PLAYER causes @brass bell'"
  end
end
