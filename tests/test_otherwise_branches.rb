# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../compiler/parser'
require_relative '../compiler/resolver'
require_relative '../compiler/runtime'
require_relative '../compiler/bytecode_emitter'
require_relative '../compiler/bytecode_loader'
require_relative '../compiler/bytecode_virtual_machine'
require_relative '../compiler/world_save'
require_relative '../compiler/ask'

class TestOtherwiseBranches < Minitest::Test
  def source(condition: '@lamp is on', start_state: 'off')
    <<~BS
      DEFINE
      [
          @lamp is a #thing
          @switch is a #thing
      ].

      START
      [
          @lamp is #{start_state}
          PLAYER has 0 ifruns
          PLAYER has 0 otherwiseruns
      ].

      WHEN PLAYER attacks @switch
      [
          |then (change @lamp to on
      ].

      WHEN PLAYER speaks @switch
      [
          |then (change @lamp to off
      ].

      IF #{condition}
      [
          |then (increase ifruns of PLAYER by 1
      ].
      OTHERWISE
      [
          |then (increase otherwiseruns of PLAYER by 1
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

  def player(machine)
    machine.snapshot.find { |entry| entry.fetch('name') == 'player' }
  end

  def value(machine, name)
    player(machine).dig('values', name)
  end

  def test_resolves_otherwise_as_profile_7
    document = resolve(source)
    assert_empty document.diagnostics
    assert_equal 'bsharp.meaning.v7', document.meaning_profile
    rule = document.if_rules.first
    assert_equal 1, rule.fetch('then').length
    assert_equal 1, rule.fetch('otherwise').length
  end

  def test_false_startup_runs_otherwise_once
    machine = runtime
    assert_equal 0, value(machine, 'ifruns')
    assert_equal 1, value(machine, 'otherwiseruns')
    assert_equal 'OTHERWISE', machine.startup_if_rules.first.fetch('branch')
    assert_equal 'OTHERWISE', machine.ask_if_rules.first.fetch('branch')
  end

  def test_true_startup_runs_if_once
    machine = runtime(source(start_state: 'on'))
    assert_equal 1, value(machine, 'ifruns')
    assert_equal 0, value(machine, 'otherwiseruns')
    assert_equal 'IF', machine.startup_if_rules.first.fetch('branch')
  end

  def test_truth_transitions_run_alternating_branches_and_unchanged_truth_stays_quiet
    machine = runtime
    first = machine.run_event('player attacks switch')
    assert_equal 'IF', first.fetch('if_rules').first.fetch('branch')
    assert_equal 1, value(machine, 'ifruns')

    quiet = machine.run_event('player attacks switch')
    assert_empty quiet.fetch('if_rules')
    assert_equal 1, value(machine, 'ifruns')

    second = machine.run_event('player speaks switch')
    assert_equal 'OTHERWISE', second.fetch('if_rules').first.fetch('branch')
    assert_equal 2, value(machine, 'otherwiseruns')
  end

  def test_compound_condition_can_own_otherwise
    text = source(condition: '@lamp is on and PLAYER has at least 0 ifruns')
    document = resolve(text)
    assert_empty document.diagnostics
    assert_equal 'bsharp.meaning.v7', document.meaning_profile
    assert_equal 'and', document.if_rules.first.dig('if', 'connector')
  end

  def test_bytecode_profile_7_executes_with_reference_parity
    document = resolve(source)
    emitter = BasicSharp::BytecodeEmitter.new(document)
    loader = BasicSharp::BytecodeLoader.new(emitter.binary)
    machine = BasicSharp::BytecodeVirtualMachine.new(loader)
    reference = BasicSharp::Runtime.new(document)
    assert_equal 'bsharp.bytecode.v7', loader.model.fetch(:profile)
    assert_includes emitter.disassembly, 'OTHERWISE BLOCK'
    ['player attacks switch', 'player attacks switch', 'player speaks switch'].each do |event|
      assert_equal reference.run_event(event), machine.run_event(event)
    end
    assert_equal reference.ask_if_rules, machine.ask_if_rules
  end

  def test_save_format_7_preserves_last_settled_branch
    machine = runtime
    machine.run_event('player attacks switch')
    save = BasicSharp::WorldSave.document_for(machine)
    restored = BasicSharp::Runtime.new(resolve(source), world_save: save)
    assert_equal 7, save.fetch('format_version')
    assert_equal 'sha256-bsir-meaning-v7', save.dig('program_fingerprint', 'algorithm')
    assert_equal 'IF', save.dig('world', 'if_rules', 0, 'branch')
    assert_equal machine.snapshot, restored.snapshot
    assert_empty restored.run_event('player attacks switch').fetch('if_rules')
  end

  def test_ask_reports_the_otherwise_branch_without_mutation
    machine = runtime
    before = machine.snapshot
    answer = BasicSharp::Ask.new(machine).answer_many(['what IF rules are false']).first
    assert_equal 'if_rules_false', answer.fetch('type')
    assert_equal 'OTHERWISE', answer.dig('answer', 'rules', 0, 'branch')
    assert_equal before, machine.snapshot
  end

  def test_comments_and_blank_lines_may_separate_if_and_otherwise
    text = source.sub("].\n      OTHERWISE", "].\n\n      // the other branch\n      OTHERWISE")
    assert_empty resolve(text).diagnostics
  end

  def test_another_head_between_if_and_otherwise_is_rejected
    inserted = <<~BS
      START
      [
          PLAYER is alive
      ].
      OTHERWISE
    BS
    text = source.sub('OTHERWISE', inserted)
    messages = resolve(text).diagnostics.map(&:message)
    assert messages.any? { |message| message.include?('must directly follow the IF Body') }
  end

  def test_standalone_otherwise_is_rejected
    text = "OTHERWISE\n[\n    |then (change PLAYER to alive\n].\n"
    messages = resolve(text).diagnostics.map(&:message)
    assert messages.any? { |message| message.include?('must directly follow the IF Body') }
  end

  def test_repeated_otherwise_is_rejected
    extra = "OTHERWISE\n[\n    |then (change PLAYER to alive\n].\n"
    messages = resolve("#{source}\n#{extra}").diagnostics.map(&:message)
    assert messages.any? { |message| message.include?('only one OTHERWISE Body') }
  end

  def test_else_is_rejected_with_otherwise_guidance
    text = source.sub('OTHERWISE', 'ELSE')
    messages = resolve(text).diagnostics.map(&:message)
    assert messages.any? { |message| message.include?('uses OTHERWISE instead of ELSE') }
  end

  def test_otherwise_condition_is_rejected
    text = source.sub('OTHERWISE', 'OTHERWISE PLAYER is alive')
    messages = resolve(text).diagnostics.map(&:message)
    assert messages.any? { |message| message.include?('stands alone on its Head line') }
  end
end
