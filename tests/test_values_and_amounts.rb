# frozen_string_literal: true

require 'json'
require 'minitest/autorun'
require 'tmpdir'
require_relative '../compiler/parser'
require_relative '../compiler/resolver'
require_relative '../compiler/ir_emitter'
require_relative '../compiler/runtime'

class TestValuesAndAmounts < Minitest::Test
  MAX = 2_147_483_647

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

  def messages(source)
    resolve(source).diagnostics.select { |diagnostic| diagnostic.severity == 'error' }.map(&:message)
  end

  def base_source(actions:, start_lines: ['henry has 10 health', 'mara has 10 health'])
    actions = actions.map do |line|
      line.gsub(/every guard/, 'every #guard')
          .gsub(/\b(henry|mara|brass bell)\b/, '@\\1')
    end
    start_lines = start_lines.map { |line| line.gsub(/\b(henry|mara|brass bell)\b/, '@\\1') }
    <<~BS
      KINDS
      [
          #captain is a #guard
      ].

      DEFINE
      [
          @henry is a #guard
          @mara is a #captain
          @brass bell is a #device
      ].

      START
      [
          #{start_lines.join("\n")}
      ].

      WHEN PLAYER sounds @brass bell
      [
          #{actions.map { |action| "|then #{action}" }.join("\n")}
      ].
    BS
  end

  def test_start_accepts_whole_number_values_and_world_state_reports_them
    machine = runtime(base_source(actions: ['(change brass bell to on'], start_lines: [
      'henry has 10 health',
      'mara has 7 courage',
      'brass bell has 3 charges'
    ]))

    state = machine.snapshot
    assert_equal({ 'damage' => 0, 'health' => 10 }, thing(state, 'henry').fetch('values'))
    assert_equal({ 'courage' => 7, 'damage' => 0 }, thing(state, 'mara').fetch('values'))
    assert_equal({ 'charges' => 3, 'damage' => 0 }, thing(state, 'brass bell').fetch('values'))
    report = machine.report(machine.run_event('player sounds brass bell'))
    assert_includes report, 'henry: kind=guard; health=10'
    assert_includes report, 'mara: kind=captain; courage=7'
    assert_includes report, 'brass bell: kind=device; states=on; charges=3'
  end

  def test_damage_without_amount_still_means_one
    result = runtime(base_source(actions: ['(damage henry'])).run_event('player sounds brass bell')
    henry = thing(result.fetch('state'), 'henry')

    assert_equal 1, henry.fetch('damage')
    assert_equal 10, henry.fetch('values').fetch('health')
    assert_equal({ 'word' => '(damage henry', 'change' => 'henry damage is now 1' }, result.fetch('steps').first)
  end

  def test_explicit_damage_amount_adds_to_damage_without_subtracting_health
    machine = runtime(base_source(actions: ['(damage henry by 3']))
    first = machine.run_event('player sounds brass bell')
    second = machine.run_event('player sounds brass bell')

    assert_equal 3, thing(first.fetch('state'), 'henry').fetch('damage')
    assert_equal 6, thing(second.fetch('state'), 'henry').fetch('damage')
    assert_equal 10, thing(second.fetch('state'), 'henry').fetch('values').fetch('health')
    assert_equal '(damage henry by 3', first.fetch('steps').first.fetch('word')
    assert_equal 'henry damage changed from 0 to 3', first.fetch('steps').first.fetch('change')
    assert_equal(
      { 'value_name' => 'damage', 'old_amount' => 0, 'new_amount' => 3, 'action_amount' => 3 },
      first.fetch('steps').first.fetch('value_change')
    )
  end

  def test_exact_value_change_replaces_instead_of_adds
    result = runtime(base_source(actions: ['(change health of henry to 7'])).run_event('player sounds brass bell')
    henry = thing(result.fetch('state'), 'henry')

    assert_equal 7, henry.fetch('values').fetch('health')
    assert_equal '(change health of henry to 7', result.fetch('steps').first.fetch('word')
    assert_equal 'henry health changed from 10 to 7', result.fetch('steps').first.fetch('change')
    assert_equal(
      { 'value_name' => 'health', 'old_amount' => 10, 'new_amount' => 7 },
      result.fetch('steps').first.fetch('value_change')
    )
  end

  def test_existing_state_change_meaning_is_unchanged
    result = runtime(base_source(actions: ['(change henry to angry'])).run_event('player sounds brass bell')

    assert_equal ['angry'], thing(result.fetch('state'), 'henry').fetch('states')
    assert_equal({ 'word' => '(change henry to angry', 'change' => 'henry is now angry' }, result.fetch('steps').first)
  end

  def test_damage_every_kind_by_amount_uses_direct_and_inherited_selection_order
    result = runtime(base_source(actions: ['(damage every guard by 3'])).run_event('player sounds brass bell')

    assert_equal ['henry', 'mara'], result.fetch('selections').first.fetch('targets')
    assert_equal ['(damage henry by 3', '(damage mara by 3'], result.fetch('ran')
    assert_equal 3, thing(result.fetch('state'), 'henry').fetch('damage')
    assert_equal 3, thing(result.fetch('state'), 'mara').fetch('damage')
  end

  def test_exact_value_change_across_set_is_atomic_when_one_thing_lacks_value
    machine = runtime(base_source(
      actions: ['(change health of every guard to 7'],
      start_lines: ['henry has 10 health']
    ))
    result = machine.run_event('player sounds brass bell')

    assert_equal 'mara does not have a value named health.', result.fetch('error')
    assert_equal 10, thing(result.fetch('state'), 'henry').fetch('values').fetch('health')
    refute thing(result.fetch('state'), 'mara').fetch('values').key?('health')
    assert_equal ['mara does not have a value named health.', 'Nothing in this action line was changed.'], result.fetch('steps').first.fetch('notice_lines')
  end

  def test_damage_across_set_is_atomic_when_one_target_would_overflow
    machine = runtime(base_source(
      actions: ['(damage every guard by 10'],
      start_lines: ["henry has #{MAX - 5} damage", 'mara has 2 damage']
    ))
    result = machine.run_event('player sounds brass bell')

    assert_equal "henry damage would be greater than #{MAX}", result.fetch('error')
    assert_equal MAX - 5, thing(result.fetch('state'), 'henry').fetch('damage')
    assert_equal 2, thing(result.fetch('state'), 'mara').fetch('damage')
    assert_equal 'Nothing in this action line was changed.', result.fetch('steps').first.fetch('notice_lines').last
  end

  def test_exact_value_if_wakes_stays_quiet_and_rearms
    source = <<~BS
      DEFINE
      [
          @henry is a #guard
          @brass bell is a #device
      ].

      START
      [
          @henry has 0 courage
      ].

      WHEN PLAYER sounds @brass bell
      [
          |then (change courage of @henry to 3
      ].

      WHEN PLAYER speaks @brass bell
      [
          |then (change courage of @henry to 0
      ].

      IF @henry has 3 courage
      [
          |then (damage PLAYER
      ].
    BS

    machine = runtime(source)
    first = machine.run_event('player sounds brass bell')
    second = machine.run_event('player sounds brass bell')
    reset = machine.run_event('player speaks brass bell')
    third = machine.run_event('player sounds brass bell')

    assert_equal 1, thing(first.fetch('state'), 'player').fetch('damage')
    assert_empty second.fetch('if_rules')
    assert_empty reset.fetch('if_rules')
    assert_equal 2, thing(third.fetch('state'), 'player').fetch('damage')
    assert_equal 'henry has 3 courage', third.fetch('if_rules').first.fetch('condition')
  end

  def test_complete_when_body_finishes_before_exact_value_if_settles
    source = <<~BS
      DEFINE
      [
          @henry is a #guard
          @brass bell is a #device
      ].

      START
      [
          @henry has 0 courage
      ].

      WHEN PLAYER sounds @brass bell
      [
          |then (change courage of @henry to 3
          |then (change courage of @henry to 2
      ].

      IF @henry has 3 courage
      [
          |then (damage PLAYER
      ].
    BS

    result = runtime(source).run_event('player sounds brass bell')
    assert_empty result.fetch('if_rules')
    assert_equal 2, thing(result.fetch('state'), 'henry').fetch('values').fetch('courage')
    refute thing(result.fetch('state'), 'player').key?('damage')
  end

  def test_zero_is_allowed_for_start_and_exact_assignment
    result = runtime(base_source(
      actions: ['(change health of henry to 0'],
      start_lines: ['henry has 0 health', 'mara has 0 health']
    )).run_event('player sounds brass bell')

    assert_equal 0, thing(result.fetch('state'), 'henry').fetch('values').fetch('health')
  end

  def test_damage_by_zero_is_rejected_plainly
    found = messages(base_source(actions: ['(damage henry by 0'])).find { |message| message.include?('Damage amount must be at least 1') }
    refute_nil found
  end

  def test_invalid_number_forms_are_rejected_plainly
    cases = {
      '-3' => 'Value cannot be negative',
      '2.5' => 'Value must be a whole number',
      '1,000' => 'Value must use digits without commas',
      'three' => 'Value must use digits',
      (MAX + 1).to_s => "Value cannot be greater than #{MAX}"
    }

    cases.each do |amount, expected|
      source = <<~BS
        DEFINE
        [
            @henry is a #guard
        ].

        START
        [
            @henry has #{amount} @health
        ].
      BS
      assert messages(source).any? { |message| message.include?(expected) }, "expected #{expected.inspect} for #{amount}"
    end
  end

  def test_value_name_must_be_one_plain_word
    source = <<~BS
      DEFINE
      [
          @henry is a #guard
      ].

      START
      [
          @henry has 10 hit points
      ].
    BS
    assert messages(source).any? { |message| message.include?("Value must look like '10 health'") }
  end

  def test_duplicate_starting_value_is_rejected
    source = <<~BS
      DEFINE
      [
          @henry is a #guard
      ].

      START
      [
          @henry has 10 health
          @henry has 20 health
      ].
    BS
    assert messages(source).any? { |message| message.include?('henry already has a starting health value') }
  end

  def test_safe_maximum_is_accepted
    machine = runtime(<<~BS)
      DEFINE
      [
          @henry is a #guard
      ].

      START
      [
          @henry has #{MAX} score
      ].
    BS
    assert_equal MAX, thing(machine.snapshot, 'henry').fetch('values').fetch('score')
  end

  def test_source_and_saved_bsir_value_execution_are_identical
    source = base_source(actions: ['(damage every guard by 3', '(change health of every guard to 7'])
    document = resolve(source)
    source_machine = BasicSharp::Runtime.new(document)

    Dir.mktmpdir do |dir|
      path = File.join(dir, 'values.bsir.json')
      File.write(path, "#{BasicSharp::IREmitter.new(document).to_json}\n")
      saved_machine = BasicSharp::Runtime.load(path)

      assert_equal source_machine.run_event('player sounds brass bell'), saved_machine.run_event('player sounds brass bell')
    end
  end

  def test_separate_runtimes_do_not_share_values
    source = base_source(actions: ['(damage henry by 3', '(change health of henry to 7'])
    first = runtime(source)
    second = runtime(source)

    first.run_event('player sounds brass bell')

    assert_equal 3, thing(first.snapshot, 'henry').fetch('damage')
    assert_equal 7, thing(first.snapshot, 'henry').fetch('values').fetch('health')
    refute thing(second.snapshot, 'henry').key?('damage')
    assert_equal 10, thing(second.snapshot, 'henry').fetch('values').fetch('health')
  end

  def test_old_saved_damage_action_without_amount_still_means_one
    document = JSON.parse(File.read(File.expand_path('fixtures/first_room_v0_1_17.bsir.json', __dir__), encoding: 'UTF-8'))
    damage = document.fetch('events').find { |rule| rule.dig('when', 'raw') == 'player attacks a guard' }.fetch('then').first
    refute damage.key?('amount')

    result = BasicSharp::Runtime.new(document).run_event('player attacks henry')
    assert_equal 1, thing(result.fetch('state'), 'henry').fetch('damage')
  end

  def test_saved_bsir_rejects_malformed_numeric_shapes_before_start
    base = JSON.parse(BasicSharp::IREmitter.new(resolve(base_source(actions: ['(damage henry by 3']))).to_json)
    mutations = {
      'Damage amount must be a whole number' => ->(doc) { doc.fetch('events').first.fetch('then').first['amount'] = '3' },
      'Damage amount must be at least 1' => ->(doc) { doc.fetch('events').first.fetch('then').first['amount'] = 0 },
      "Damage amount cannot be greater than #{MAX}" => ->(doc) { doc.fetch('events').first.fetch('then').first['amount'] = MAX + 1 },
      'START value entry 1 is missing its value name' => ->(doc) { doc.fetch('facts').first.delete('value_name') },
      'START health amount must be a whole number' => ->(doc) { doc.fetch('facts').first['amount'] = 10.5 }
    }

    mutations.each do |expected, mutate|
      document = Marshal.load(Marshal.dump(base))
      mutate.call(document)
      error = assert_raises(ArgumentError) { BasicSharp::Runtime.new(document) }
      assert_equal expected, error.message
    end
  end

  def test_saved_bsir_rejects_duplicate_starting_values
    document = JSON.parse(BasicSharp::IREmitter.new(resolve(base_source(actions: ['(damage henry']))).to_json)
    document.fetch('facts') << Marshal.load(Marshal.dump(document.fetch('facts').first))

    error = assert_raises(ArgumentError) { BasicSharp::Runtime.new(document) }
    assert_includes error.message, 'henry already has a starting health value'
  end
end
