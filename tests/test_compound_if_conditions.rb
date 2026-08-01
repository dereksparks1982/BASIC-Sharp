# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../compiler/parser'
require_relative '../compiler/resolver'
require_relative '../compiler/runtime'
require_relative '../compiler/bytecode_emitter'
require_relative '../compiler/bytecode_loader'
require_relative '../compiler/bytecode_virtual_machine'
require_relative '../compiler/world_save'

class TestCompoundIfConditions < Minitest::Test
  def source(and_condition: 'PLAYER has at least 100 score and @boss is dead',
             or_condition: 'PLAYER has less than 1 health or @bridge is broken')
    <<~BS
      DEFINE
      [
          @boss is a #creature
          @bridge is a #thing
          @coin is a #thing
      ].

      START
      [
          PLAYER has 0 score
          PLAYER has 10 health
          PLAYER has 0 victories
          @boss is alive
          @bridge is whole
      ].

      WHEN PLAYER takes @coin
      [
          |then (increase score of PLAYER by 100
      ].

      WHEN PLAYER attacks @boss
      [
          |then (change @boss to dead
      ].

      WHEN PLAYER speaks @boss
      [
          |then (change @boss to alive
      ].

      WHEN PLAYER attacks @bridge
      [
          |then (change @bridge to broken
      ].

      WHEN PLAYER speaks @bridge
      [
          |then (change @bridge to whole
      ].

      IF #{and_condition}
      [
          |then (increase victories of PLAYER by 1
      ].

      IF #{or_condition}
      [
          |then (change PLAYER to dead
      ].
    BS
  end

  def resolve(text)
    parser = BasicSharp::Parser.new(text)
    BasicSharp::SemanticResolver.new(parser.parse, dictionary: parser.dictionary).resolve
  end

  def runtime(text = source)
    document = resolve(text)
    errors = document.diagnostics.select { |entry| entry.severity == 'error' }
    raise errors.map(&:message).join("\n") unless errors.empty?
    BasicSharp::Runtime.new(document)
  end

  def player(snapshot)
    snapshot.find { |entry| entry.fetch('name') == 'player' }
  end

  def test_resolves_compound_bsir_as_profile_6
    document = resolve(source)
    assert_empty document.diagnostics
    assert_equal 'bsharp.meaning.v6', document.meaning_profile
    condition = document.if_rules.first.fetch('if')
    assert_equal 'and', condition.fetch('connector')
    assert_equal 2, condition.fetch('clauses').length
    assert_equal %w[has is], condition.fetch('clauses').map { |clause| clause.fetch('relation') }
  end

  def test_and_requires_every_clause
    machine = runtime
    score = machine.run_event('player takes coin')
    assert_empty score.fetch('if_rules')
    boss = machine.run_event('player attacks boss')
    assert_equal 1, boss.fetch('if_rules').length
    assert_equal 1, player(boss.fetch('state')).dig('values', 'victories')
  end

  def test_or_requires_at_least_one_clause
    machine = runtime
    result = machine.run_event('player attacks bridge')
    assert_equal 'player has less than 1 health or bridge is broken', result.fetch('if_rules').first.fetch('condition')
    assert_includes player(result.fetch('state')).fetch('states'), 'dead'
  end

  def test_complete_condition_rearms_only_after_becoming_false
    machine = runtime
    machine.run_event('player takes coin')
    first = machine.run_event('player attacks boss')
    assert_equal 1, player(first.fetch('state')).dig('values', 'victories')
    machine.run_event('player speaks boss')
    second = machine.run_event('player attacks boss')
    assert_equal 2, player(second.fetch('state')).dig('values', 'victories')
  end

  def test_startup_truth_uses_the_whole_compound_condition
    machine = runtime(source(and_condition: 'PLAYER has 0 score and @boss is alive'))
    assert_equal 1, player(machine.snapshot).dig('values', 'victories')
    assert_equal 'player has 0 score and boss is alive', machine.startup_if_rules.first.fetch('condition')
  end

  def test_state_relation_text_exact_and_threshold_clauses_can_combine
    text = <<~BS
      DEFINE
      [
          @boss is a #creature
          @key is a #key
          @table is a #table
      ].
      START
      [
          @boss is alive
          @key is on @table
          PLAYER has "ready and willing" motto
          PLAYER has 10 health
      ].
      IF @boss is alive and @key is on @table
      [
          |then (change PLAYER to friendly
      ].
      IF PLAYER has "ready and willing" motto and PLAYER has 10 health
      [
          |then (change PLAYER to on
      ].
      IF PLAYER has at least 10 health or PLAYER has less than 1 health
      [
          |then (change PLAYER to visible
      ].
    BS
    machine = runtime(text)
    assert_equal %w[friendly on visible], player(machine.snapshot).fetch('states')
    assert_equal 3, machine.startup_if_rules.length
  end

  def test_operator_words_inside_text_are_not_split
    document = resolve(source(and_condition: 'PLAYER has "ready and willing" motto and @boss is alive').sub('PLAYER has 0 victories', "PLAYER has 0 victories\n    PLAYER has \"ready and willing\" motto"))
    assert_empty document.diagnostics
    clauses = document.if_rules.first.dig('if', 'clauses')
    assert_equal 2, clauses.length
    assert_equal 'ready and willing', clauses.first.fetch('text_value')
  end

  def test_mixed_and_or_is_rejected_in_plain_english
    document = resolve(source(and_condition: 'PLAYER has 0 score and @boss is alive or @bridge is whole'))
    messages = document.diagnostics.map(&:message)
    assert messages.any? { |message| message.include?('does not mix and and or in one IF yet') }
  end

  def test_incomplete_clause_is_rejected_in_plain_english
    document = resolve(source(and_condition: 'PLAYER has 0 score and'))
    messages = document.diagnostics.map(&:message)
    assert messages.any? { |message| message.include?('must have a complete condition on both sides') }
  end

  def test_profile_6_bytecode_executes_with_reference_parity
    document = resolve(source)
    emitter = BasicSharp::BytecodeEmitter.new(document)
    loader = BasicSharp::BytecodeLoader.new(emitter.binary)
    machine = BasicSharp::BytecodeVirtualMachine.new(loader)
    reference = BasicSharp::Runtime.new(document)
    %w[player\ takes\ coin player\ attacks\ boss player\ attacks\ bridge].each do |event|
      assert_equal reference.run_event(event), machine.run_event(event)
    end
    assert_equal 'bsharp.bytecode.v6', loader.model.fetch(:profile)
    assert_equal 'bsharp.meaning.v6', loader.model.fetch(:meaning_profile)
    assert_includes emitter.disassembly, 'ALL_CONDITIONS'
    assert_includes emitter.disassembly, 'ANY_CONDITIONS'
  end

  def test_save_format_6_restores_compound_rule_activity
    machine = runtime
    machine.run_event('player takes coin')
    machine.run_event('player attacks boss')
    save = BasicSharp::WorldSave.document_for(machine)
    restored = BasicSharp::Runtime.new(resolve(source), world_save: save)
    assert_equal 6, save.fetch('format_version')
    assert_equal 'sha256-bsir-meaning-v6', save.dig('program_fingerprint', 'algorithm')
    assert_equal machine.snapshot, restored.snapshot
    assert restored.ask_if_rules.first.fetch('active')
  end

  def test_single_condition_program_keeps_its_older_profile
    text = source.sub(' and @boss is dead', '').sub(' or @bridge is broken', '')
    assert_equal 'bsharp.meaning.v5', resolve(text).meaning_profile
  end
end
