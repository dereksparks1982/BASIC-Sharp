# frozen_string_literal: true

require 'json'
require 'minitest/autorun'
require 'tmpdir'
require_relative '../compiler/parser'
require_relative '../compiler/resolver'
require_relative '../compiler/ir_emitter'
require_relative '../compiler/runtime'

class TestMultipleSelection < Minitest::Test
  def resolve(source)
    parser = BasicSharp::Parser.new(source)
    program = parser.parse
    BasicSharp::SemanticResolver.new(program, dictionary: parser.dictionary).resolve
  end

  def runtime(source)
    document = resolve(source)
    errors = document.diagnostics.select { |diagnostic| diagnostic.severity == 'error' }
    raise errors.map(&:to_s).join("\n") unless errors.empty?

    BasicSharp::Runtime.new(document)
  end

  def thing(snapshot, name)
    snapshot.find { |entry| entry.fetch('name') == name }
  end

  def base_source(actions: ['(damage every guard'])
    actions = actions.map do |line|
      line.gsub(/every (guard|key|door)/, 'every #\\1')
          .gsub(/\b(henry|mara|otto|brass bell|brass key|iron key|north door|south door)\b/, '@\\1')
    end
    <<~BS
      KINDS
      [
          #captain is a #guard
      ].

      DEFINE
      [
          @henry is a #guard
          @mara is a #captain
          @otto is a #guard
          @brass bell is a #device
          @brass key is a #key
          @iron key is a #key
          @north door is a #door
          @south door is a #door
      ].

      START
      [
          @henry is calm
          @mara is calm
          @otto is calm
          @north door is locked
          @south door is locked
      ].

      WHEN PLAYER sounds @brass bell
      [
          #{actions.map { |action| "|then #{action}" }.join("\n")}
      ].
    BS
  end

  def test_every_kind_selects_direct_and_inherited_things_in_definition_order
    machine = runtime(base_source)
    result = machine.run_event('player sounds brass bell')

    assert_equal ['henry', 'mara', 'otto'], result.fetch('selections').first.fetch('targets')
    assert_equal 3, result.fetch('selections').first.fetch('count')
    assert_equal ['(damage henry', '(damage mara', '(damage otto'], result.fetch('ran')
    assert_equal 1, thing(result.fetch('state'), 'henry').fetch('damage')
    assert_equal 1, thing(result.fetch('state'), 'mara').fetch('damage')
    assert_equal 1, thing(result.fetch('state'), 'otto').fetch('damage')
    refute thing(result.fetch('state'), 'brass bell').key?('damage')
  end

  def test_action_line_order_finishes_one_set_before_the_next
    machine = runtime(base_source(actions: ['(damage every guard', '(change every guard to angry']))
    result = machine.run_event('player sounds brass bell')

    assert_equal(
      ['(damage henry', '(damage mara', '(damage otto', '(change henry to angry', '(change mara to angry', '(change otto to angry'],
      result.fetch('ran')
    )
    assert_equal 2, result.fetch('selections').length
    result.fetch('selections').each do |selection|
      assert_equal ['henry', 'mara', 'otto'], selection.fetch('targets')
    end
  end

  def test_change_carry_and_unlock_apply_to_every_selected_thing
    source = base_source(actions: ['(change every guard to angry', '(carry every key', '(unlock every door'])
    result = runtime(source).run_event('player sounds brass bell')
    state = result.fetch('state')

    %w[henry mara otto].each { |name| assert_equal ['angry'], thing(state, name).fetch('states') }
    ['brass key', 'iron key'].each do |name|
      assert_equal({ 'carried by' => 'player' }, thing(state, name).fetch('relations'))
    end
    ['north door', 'south door'].each { |name| assert_equal ['unlocked'], thing(state, name).fetch('states') }
  end

  def test_plural_action_never_overwrites_singular_that_kind_context
    source = <<~BS
      KINDS
      [
          #captain is a #guard
      ].

      DEFINE
      [
          @henry is a #guard
          @mara is a #captain
          @otto is a #guard
      ].

      WHEN PLAYER attacks a #guard
      [
          |then (damage every #guard
          |then (change it to angry
      ].
    BS

    result = runtime(source).run_event('player attacks henry')
    state = result.fetch('state')

    assert_equal({ 'guard' => 'henry' }, result.fetch('context'))
    assert_equal ['a guard means henry', 'that guard means henry'], result.fetch('understood')
    assert_equal ['angry'], thing(state, 'henry').fetch('states')
    assert_empty thing(state, 'mara').fetch('states')
    assert_empty thing(state, 'otto').fetch('states')
    %w[henry mara otto].each { |name| assert_equal 1, thing(state, name).fetch('damage') }
  end

  def test_named_and_definite_single_targets_keep_existing_meaning
    source = <<~BS
      DEFINE
      [
          @henry is a #guard
          @north door is a #door
      ].

      WHEN PLAYER attacks @henry
      [
          |then (damage @henry
          |then (unlock the #door
      ].
    BS

    result = runtime(source).run_event('player attacks henry')
    assert_equal ['(damage henry', '(unlock north door'], result.fetch('ran')
    assert_empty result.fetch('selections')
  end

  def test_known_empty_set_is_nonfatal_and_explained
    source = <<~BS
      DEFINE
      [
          @brass bell is a #device
      ].

      WHEN PLAYER sounds @brass bell
      [
          |then (damage every #guard
          |then (change @brass bell to on
      ].
    BS

    machine = runtime(source)
    result = machine.run_event('player sounds brass bell')
    report = machine.report(result)

    assert_equal true, result.fetch('matched')
    assert_equal [], result.fetch('selections').first.fetch('targets')
    assert_equal '(damage every guard', result.fetch('steps').first.fetch('word')
    assert_equal ['every guard found no Things', '(damage had nothing to act on'], result.fetch('steps').first.fetch('notice_lines')
    assert_equal ['on'], thing(result.fetch('state'), 'brass bell').fetch('states')
    assert_includes report, 'every guard found no Things'
    assert_includes report, '(damage had nothing to act on'
  end

  def test_unknown_set_kind_remains_a_compiler_error
    document = resolve(<<~BS)
      DEFINE
      [
          @brass bell is a #device
      ].

      WHEN PLAYER sounds @brass bell
      [
          |then (damage every #martian
      ].
    BS

    messages = document.diagnostics.select { |diagnostic| diagnostic.severity == 'error' }.map(&:message)
    assert_includes messages, "unknown Kind '#martian'"
  end

  def test_every_is_rejected_in_when_trigger_with_plain_guidance
    document = resolve(<<~BS)
      DEFINE
      [
          @henry is a #guard
      ].

      WHEN PLAYER attacks every #guard
      [
          |then (damage @henry
      ].
    BS

    message = document.diagnostics.map(&:message).find { |item| item.include?('WHEN still describes one event Thing') }
    refute_nil message
    assert_includes message, "'every guard' can be used as an action target after |then."
  end

  def test_every_is_rejected_in_start_with_plain_guidance
    document = resolve(<<~BS)
      DEFINE
      [
          @henry is a #guard
      ].

      START
      [
          every #guard is calm
      ].
    BS

    message = document.diagnostics.map(&:message).find { |item| item.include?('START still describes one Thing at a time') }
    refute_nil message
  end

  def test_every_is_rejected_in_if_condition_without_guessing_all_or_any
    document = resolve(<<~BS)
      DEFINE
      [
          @henry is a #guard
      ].

      IF every #guard is calm
      [
          |then (damage @henry
      ].
    BS

    message = document.diagnostics.map(&:message).find { |item| item.include?('not yet supported inside an IF condition') }
    refute_nil message
    assert_includes message, 'whether you mean every guard or any guard'
  end

  def test_unbound_a_kind_action_target_gets_plain_correction
    document = resolve(<<~BS)
      DEFINE
      [
          @henry is a #guard
          @brass bell is a #device
      ].

      WHEN PLAYER sounds @brass bell
      [
          |then (damage a #guard
      ].
    BS

    message = document.diagnostics.map(&:message).find { |item| item.include?('cannot choose one guard here') }
    refute_nil message
    assert_includes message, "use 'every guard'"
  end

  def test_if_action_can_target_every_kind
    source = <<~BS
      DEFINE
      [
          @henry is a #guard
          @otto is a #guard
          @alarm is a #device
      ].

      START
      [
          @alarm is on
      ].

      IF @alarm is on
      [
          |then (damage every #guard
      ].
    BS

    machine = runtime(source)
    state = machine.snapshot
    entry = machine.startup_if_rules.first

    assert_equal 1, thing(state, 'henry').fetch('damage')
    assert_equal 1, thing(state, 'otto').fetch('damage')
    assert_equal ['henry', 'otto'], entry.fetch('selections').first.fetch('targets')
  end

  def test_saved_bsir_ignores_stale_candidates_and_recalculates_from_loaded_things
    document = resolve(base_source).to_h
    target = document.fetch(:events).first.fetch('then').first.fetch('target')
    target['candidates'] = ['not real', 'otto']

    result = BasicSharp::Runtime.new(document).run_event('player sounds brass bell')
    assert_equal ['henry', 'mara', 'otto'], result.fetch('selections').first.fetch('targets')
  end

  def test_source_and_saved_bsir_set_execution_are_identical
    document = resolve(base_source(actions: ['(damage every guard', '(change every guard to angry']))
    source_machine = BasicSharp::Runtime.new(document)

    Dir.mktmpdir do |dir|
      path = File.join(dir, 'every_guard.bsir.json')
      File.write(path, "#{BasicSharp::IREmitter.new(document).to_json}\n")
      saved_machine = BasicSharp::Runtime.load(path)

      source_result = source_machine.run_event('player sounds brass bell')
      saved_result = saved_machine.run_event('player sounds brass bell')
      assert_equal source_result, saved_result
    end
  end

  def test_separate_runtimes_do_not_share_set_mutations
    first = runtime(base_source)
    second = runtime(base_source)

    first.run_event('player sounds brass bell')

    assert_equal 1, thing(first.snapshot, 'henry').fetch('damage')
    refute thing(second.snapshot, 'henry').key?('damage')
  end

  def test_large_human_report_is_bounded_while_structured_results_are_complete
    guards = (1..20).map { |index| "@guard #{index} is a #guard" }.join("\n")
    source = <<~BS
      DEFINE
      [
          #{guards}
          @brass bell is a #device
      ].

      WHEN PLAYER sounds @brass bell
      [
          |then (damage every #guard
      ].
    BS

    machine = runtime(source)
    result = machine.run_event('player sounds brass bell')
    report = machine.report(result)

    assert_equal 20, result.fetch('selections').first.fetch('targets').length
    assert_equal 20, result.fetch('steps').length
    assert_includes report, 'every guard selected 20 Things:'
    assert_includes report, 'and 8 more'
    assert_includes report, 'and 8 more action results'
    refute_includes report, 'guard 20 damage is now 1'
    assert_equal 1, thing(result.fetch('state'), 'guard 20').fetch('damage')
  end

  def test_saved_bsir_rejects_missing_nontext_empty_unknown_and_wrong_selector_set_references
    mutations = {
      'Set reference is missing its Kind name' => ->(target) { target.delete('kind_name') },
      'Set reference has a Kind name that is not text' => ->(target) { target['kind_name'] = 7 },
      'Set reference has an empty Kind name' => ->(target) { target['kind_name'] = '  ' },
      "Set reference uses unknown Kind 'martian'" => ->(target) { target['kind_name'] = 'martian' },
      "Set reference selector 'all' is not supported; use 'every'" => ->(target) { target['selector'] = 'all' }
    }

    mutations.each do |expected, mutate|
      document = JSON.parse(BasicSharp::IREmitter.new(resolve(base_source)).to_json)
      target = document.fetch('events').first.fetch('then').first.fetch('target')
      mutate.call(target)

      error = assert_raises(ArgumentError) { BasicSharp::Runtime.new(document) }
      assert_equal expected, error.message
    end
  end

  def test_saved_bsir_rejects_set_reference_outside_action_position_before_start_mutation
    document = JSON.parse(BasicSharp::IREmitter.new(resolve(base_source)).to_json)
    document.fetch('facts') << {
      'subject' => {
        'type' => 'kind_set', 'text' => 'every guard', 'selector' => 'every', 'kind_name' => 'guard'
      },
      'relation' => 'is',
      'value' => { 'kind' => 'state', 'name' => 'angry' }
    }

    error = assert_raises(ArgumentError) { BasicSharp::Runtime.new(document) }
    assert_includes error.message, 'START still describes one Thing at a time'
  end

  def test_saved_bsir_rejects_unbound_single_kind_action_target_plainly
    document = JSON.parse(BasicSharp::IREmitter.new(resolve(base_source)).to_json)
    document.fetch('events').first.fetch('then').first['target'] = {
      'type' => 'kind_one',
      'text' => 'a guard',
      'selector' => 'a',
      'kind_name' => 'guard'
    }

    error = assert_raises(ArgumentError) { BasicSharp::Runtime.new(document) }
    assert_includes error.message, 'cannot choose one guard here'
    assert_includes error.message, "use 'every guard'"
  end
end
