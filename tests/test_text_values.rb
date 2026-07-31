# frozen_string_literal: true

require 'json'
require 'minitest/autorun'
require_relative '../compiler/parser'
require_relative '../compiler/resolver'
require_relative '../compiler/runtime'
require_relative '../compiler/ask'
require_relative '../compiler/world_save'
require_relative '../compiler/bytecode_emitter'
require_relative '../compiler/bytecode_loader'
require_relative '../compiler/bytecode_virtual_machine'
require_relative '../compiler/runtime_transition'

class TestTextValues < Minitest::Test
  def source(start_text: 'North  Gate!', changed_text: 'OPEN — RubyVM!')
    <<~BS
      DEFINE
      [a door named north gate
      a device named brass bell].

      START
      [north gate has "#{start_text}" title].

      WHEN
      [player sounds brass bell
      <then> (change title of north gate to "#{changed_text}"].

      IF
      [north gate has "#{changed_text}" title
      <then> (damage player].
    BS
  end

  def resolve(text = source)
    parser = BasicSharp::Parser.new(text)
    program = parser.parse
    BasicSharp::SemanticResolver.new(program, dictionary: parser.dictionary).resolve
  end

  def errors(text)
    resolve(text).diagnostics.select { |entry| entry.severity == 'error' }.map(&:message)
  end

  def thing(snapshot, name)
    snapshot.find { |entry| entry.fetch('name') == name }
  end

  def test_source_preserves_creator_text_and_selects_meaning_profile_2
    document = resolve
    assert_empty document.diagnostics
    assert_equal 'bsharp.meaning.v2', document.to_h.fetch(:meaning_profile)
    assert_equal 'North  Gate!', document.facts.first.fetch('text_value')
    assert_equal 'OPEN — RubyVM!', document.events.first.fetch('then').first.fetch('to_text')
    assert_equal 'OPEN — RubyVM!', document.if_rules.first.fetch('if').fetch('text_value')
  end

  def test_reference_runtime_changes_text_and_reactive_if_compares_exactly
    machine = BasicSharp::Runtime.new(resolve)
    assert_equal 'North  Gate!', thing(machine.snapshot, 'north gate').fetch('values').fetch('title')

    result = machine.run_event('player sounds brass bell')
    assert_equal 'OPEN — RubyVM!', thing(result.fetch('state'), 'north gate').fetch('values').fetch('title')
    assert_equal 1, thing(result.fetch('state'), 'player').fetch('damage')
    assert_equal '(change title of north gate to "OPEN — RubyVM!"', result.fetch('steps').first.fetch('word')
    assert_equal 'north gate has "OPEN — RubyVM!" title', result.fetch('if_rules').first.fetch('condition')
  end

  def test_bytecode_profile_2_executes_without_normalizing_literal_text
    document = resolve
    emitter = BasicSharp::BytecodeEmitter.new(document)
    loader = BasicSharp::BytecodeLoader.new(emitter.binary)
    machine = BasicSharp::BytecodeVirtualMachine.new(loader)

    assert_equal 'bsharp.bytecode.v2', loader.model.fetch(:profile)
    assert_equal 'bsharp.meaning.v2', loader.model.fetch(:meaning_profile)
    assert_equal %w[START_TEXT_VALUE], loader.model.fetch(:start_records).map { |entry| entry.fetch(:name) }
    assert_includes loader.model.fetch(:blocks).first.fetch(:instructions).map { |entry| entry.fetch(:name) }, 'CHANGE_TEXT_VALUE'
    assert_equal 'TEXT_VALUE_EQUALS', loader.model.fetch(:if_rules).first.fetch(:condition).fetch(:name)

    result = machine.run_event('player sounds brass bell')
    assert_equal BasicSharp::Runtime.new(document).run_event('player sounds brass bell'), result
  end

  def test_profile_2_save_is_typed_and_round_trips_exact_text
    machine = BasicSharp::RuntimeTransition.new(resolve, mode: :verify)
    machine.run_event('player sounds brass bell')
    save = BasicSharp::WorldSave.document_for(machine)

    assert_equal 2, save.fetch('format_version')
    assert_equal 'sha256-bsir-meaning-v2', save.dig('program_fingerprint', 'algorithm')
    gate = save.dig('world', 'things').find { |entry| entry.fetch('name') == 'north gate' }
    assert_equal({ 'type' => 'text', 'value' => 'OPEN — RubyVM!' }, gate.dig('values', 'title'))
    assert_equal({ 'type' => 'whole_number', 'value' => 0 }, gate.dig('values', 'damage'))

    restored = BasicSharp::RuntimeTransition.new(resolve, world_save: save, mode: :verify)
    assert_equal machine.snapshot, restored.snapshot
  end

  def test_ask_counts_and_reports_text_separately
    machine = BasicSharp::Runtime.new(resolve)
    answers = BasicSharp::Ask.new(machine).answer_many(['what is north gate', 'what is the world'])
    world = answers.last.fetch('answer')
    assert_equal 1, world.fetch('text_values')
    assert_equal 3, world.fetch('whole_number_values')
    assert_includes BasicSharp::Ask.new(machine).report(answers), 'title: "North  Gate!"'
  end

  def test_text_comparison_is_case_space_and_punctuation_exact
    document = resolve(source(start_text: 'OPEN — RubyVM!', changed_text: 'open — RubyVM!'))
    machine = BasicSharp::Runtime.new(document)
    assert_empty machine.startup_if_rules
    result = machine.run_event('player sounds brass bell')
    assert_equal 1, thing(result.fetch('state'), 'player').fetch('damage')
  end

  def test_curly_quotes_are_valid_content_inside_straight_delimiters
    creator_text = 'Gate says “OPEN”.'
    document = resolve(source(start_text: creator_text, changed_text: creator_text))
    assert_empty document.diagnostics
    assert_equal creator_text, document.facts.first.fetch('text_value')
    assert_equal creator_text, BasicSharp::Runtime.new(document).snapshot.find { |entry| entry.fetch('name') == 'north gate' }.dig('values', 'title')
  end

  def test_invalid_text_boundaries_are_plain_and_deterministic
    curly = source.sub('"North  Gate!"', '“North Gate”')
    assert errors(curly).any? { |message| message.include?('straight double quotes') }

    concatenated = source.sub('"North  Gate!" title', '"North" + "Gate" title')
    assert errors(concatenated).any? { |message| message.include?('concatenation') }

    escaped = source.sub('"North  Gate!"', '"North\\nGate"')
    assert errors(escaped).any? { |message| message.include?('escape sequences') }

    interpolated = source.sub('"North  Gate!"', '"North #{gate}"')
    assert errors(interpolated).any? { |message| message.include?('interpolation') }

    embedded_quote = source.sub('"North  Gate!"', '"North "Gate""')
    assert errors(embedded_quote).any? { |message| message.include?('concatenation') || message.include?('follow a quoted text value') }
  end

  def test_text_and_whole_number_mixing_is_rejected
    text = source.sub('north gate has "OPEN — RubyVM!" title', 'north gate has 7 title')
    assert errors(text).any? { |message| message.include?('whole-number comparison cannot use title') }
  end

  def test_one_value_name_cannot_change_type_between_things
    text = <<~BS
      DEFINE
      [a door named north gate
      a door named south gate].

      START
      [north gate has "OPEN" title
      south gate has 7 title].
    BS
    assert errors(text).any? { |message| message.include?('Starting value cannot use title') }

    document = resolve.to_h
    numeric_event = Marshal.load(Marshal.dump(document.fetch(:events).first))
    numeric_action = numeric_event.fetch('then').first
    numeric_action.delete('to_text')
    numeric_action['to_amount'] = 7
    document.fetch(:events) << numeric_event
    error = assert_raises(ArgumentError) { BasicSharp::Runtime.new(document) }
    assert_includes error.message, 'Whole-number value change cannot use title'
  end

  def test_saved_bsir_requires_the_profile_2_identity_when_text_is_present
    document = resolve.to_h
    document.delete(:meaning_profile)
    error = assert_raises(ArgumentError) { BasicSharp::Runtime.new(document) }
    assert_includes error.message, 'require bsharp.meaning.v2'

    document[:meaning_profile] = 'bsharp.meaning.v9'
    error = assert_raises(ArgumentError) { BasicSharp::Runtime.new(document) }
    assert_includes error.message, 'is not supported'
  end

  def test_saved_bsir_rejects_text_and_number_type_conflicts
    document = resolve.to_h
    document[:if_rules][0]['if'].delete('text_value')
    document[:if_rules][0]['if']['amount'] = 7
    error = assert_raises(ArgumentError) { BasicSharp::Runtime.new(document) }
    assert_includes error.message, 'IF whole-number comparison'
    assert_includes error.message, 'because it is text'
  end

  def test_profile_2_save_rejects_wrong_type_without_mutating_the_world
    machine = BasicSharp::RuntimeTransition.new(resolve, mode: :verify)
    machine.run_event('player sounds brass bell')
    before = machine.snapshot
    save = BasicSharp::WorldSave.document_for(machine)
    gate = save.dig('world', 'things').find { |entry| entry.fetch('name') == 'north gate' }
    gate.dig('values', 'title')['type'] = 'whole_number'

    error = assert_raises(BasicSharp::WorldSaveError) { machine.restore_world_save!(save) }
    assert_includes error.message, 'wrong value type'
    assert_equal before, machine.snapshot
  end

  def test_profile_2_save_rejects_unsupported_text_content
    machine = BasicSharp::Runtime.new(resolve)
    machine.run_event('player sounds brass bell')
    save = BasicSharp::WorldSave.document_for(machine)
    gate = save.dig('world', 'things').find { |entry| entry.fetch('name') == 'north gate' }
    gate.dig('values', 'title')['value'] = 'bad\\escape'
    error = assert_raises(BasicSharp::WorldSaveError) { BasicSharp::Runtime.new(resolve, world_save: save) }
    assert_includes error.message, 'escape sequences'
  end
end
