# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../compiler/parser'
require_relative '../compiler/resolver'
require_relative '../compiler/runtime'
require_relative '../compiler/bytecode_emitter'
require_relative '../compiler/bytecode_loader'
require_relative '../compiler/bytecode_virtual_machine'
require_relative '../compiler/world_save'

class TestNumberChangesAndComparisons < Minitest::Test
  MAX = 2_147_483_647

  def source(start_score: 0, start_health: 10, actions: nil, condition: 'PLAYER has at least 10 score')
    actions ||= ['(increase score of PLAYER by 10', '(decrease health of PLAYER by 3']
    <<~BS
      DEFINE
      [
          @gold coin is a #thing
      ].

      START
      [
          PLAYER has #{start_score} score
          PLAYER has #{start_health} health
      ].

      WHEN PLAYER takes @gold coin
      [
          #{actions.map { |action| "|then #{action}" }.join("\n")}
      ].

      IF #{condition}
      [
          |then (change PLAYER to on
      ].
    BS
  end

  def resolve(text)
    parser = BasicSharp::Parser.new(text)
    BasicSharp::SemanticResolver.new(parser.parse, dictionary: parser.dictionary).resolve
  end

  def runtime(text)
    document = resolve(text)
    errors = document.diagnostics.select { |entry| entry.severity == 'error' }
    raise errors.map(&:message).join("\n") unless errors.empty?
    BasicSharp::Runtime.new(document)
  end

  def player(snapshot)
    snapshot.find { |entry| entry.fetch('name') == 'player' }
  end

  def test_source_resolves_profile_5_number_meaning
    document = resolve(source)
    assert_empty document.diagnostics
    assert_equal 'bsharp.meaning.v5', document.meaning_profile
    assert_equal 'increase', document.events.first.fetch('then').first.fetch('action')
    assert_equal 'decrease', document.events.first.fetch('then').last.fetch('action')
    assert_equal 'at_least', document.if_rules.first.fetch('if').fetch('comparison')
  end

  def test_increase_decrease_and_threshold_execute
    result = runtime(source).run_event('player takes gold coin')
    values = player(result.fetch('state')).fetch('values')
    assert_equal 10, values.fetch('score')
    assert_equal 7, values.fetch('health')
    assert_includes player(result.fetch('state')).fetch('states'), 'on'
    assert_equal %w[increase decrease], result.fetch('steps').map { |step| step.dig('value_change', 'operation') }
  end

  def test_all_comparisons_use_exact_boundaries
    cases = {
      'PLAYER has 10 score' => true,
      'PLAYER has at least 10 score' => true,
      'PLAYER has more than 10 score' => false,
      'PLAYER has at most 10 score' => true,
      'PLAYER has less than 10 score' => false
    }
    cases.each do |condition, expected|
      machine = runtime(source(start_score: 10, actions: ['(change health of PLAYER to 10'], condition: condition))
      assert_equal expected, player(machine.snapshot).fetch('states').include?('on'), condition
    end
  end

  def test_overflow_is_atomic
    machine = runtime(source(start_score: MAX, actions: ['(increase score of PLAYER by 1']))
    result = machine.run_event('player takes gold coin')
    assert_equal "player score would be greater than #{MAX}.", result.fetch('error')
    assert_equal MAX, player(result.fetch('state')).fetch('values').fetch('score')
  end

  def test_underflow_is_atomic
    machine = runtime(source(start_health: 2, actions: ['(decrease health of PLAYER by 3']))
    result = machine.run_event('player takes gold coin')
    assert_equal 'player health would be less than 0.', result.fetch('error')
    assert_equal 2, player(result.fetch('state')).fetch('values').fetch('health')
  end

  def test_set_change_is_all_or_nothing
    text = <<~BS
      KINDS
      [
          #guard is a #thing
      ].
      DEFINE
      [
          @henry is a #guard
          @mara is a #guard
          @bell is a #device
      ].
      START
      [
          @henry has 4 health
      ].
      WHEN PLAYER sounds @bell
      [
          |then (decrease health of every #guard by 1
      ].
    BS
    result = runtime(text).run_event('player sounds bell')
    assert_equal 'mara does not have a value named health.', result.fetch('error')
    assert_equal 4, result.fetch('state').find { |entry| entry['name'] == 'henry' }.dig('values', 'health')
  end

  def test_plain_english_errors_reject_invalid_amounts
    diagnostics = resolve(source(actions: ['(increase score of PLAYER by 0'])).diagnostics.map(&:message)
    assert diagnostics.any? { |message| message.include?('Increase amount must be at least 1') }
    diagnostics = resolve(source(actions: ['(decrease score PLAYER by 1'])).diagnostics.map(&:message)
    assert diagnostics.any? { |message| message.include?("Number change must look like '(decrease health of PLAYER by 3'") }
  end

  def test_bytecode_profile_5_executes_with_reference_parity
    document = resolve(source)
    emitter = BasicSharp::BytecodeEmitter.new(document)
    loader = BasicSharp::BytecodeLoader.new(emitter.binary)
    machine = BasicSharp::BytecodeVirtualMachine.new(loader)
    reference = BasicSharp::Runtime.new(document)
    actual = machine.run_event('player takes gold coin')
    expected = reference.run_event('player takes gold coin')
    assert_equal 'bsharp.bytecode.v5', loader.model.fetch(:profile)
    assert_equal 'bsharp.meaning.v5', loader.model.fetch(:meaning_profile)
    assert_equal expected, actual
    assert_includes emitter.disassembly, 'INCREASE_VALUE'
    assert_includes emitter.disassembly, 'VALUE_AT_LEAST'
  end

  def test_save_format_5_restores_threshold_state
    machine = runtime(source)
    machine.run_event('player takes gold coin')
    save = BasicSharp::WorldSave.document_for(machine)
    restored = BasicSharp::Runtime.new(resolve(source), world_save: save)
    assert_equal 5, save.fetch('format_version')
    assert_equal 'sha256-bsir-meaning-v5', save.dig('program_fingerprint', 'algorithm')
    assert_equal machine.snapshot, restored.snapshot
    assert restored.ask_if_rules.first.fetch('active')
  end

  def test_exact_equality_without_new_features_stays_profile_1
    text = source(actions: ['(change health of PLAYER to 7'], condition: 'PLAYER has 0 score')
    assert_equal 'bsharp.meaning.v1', resolve(text).meaning_profile
  end
end
