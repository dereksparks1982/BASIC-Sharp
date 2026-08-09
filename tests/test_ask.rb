# frozen_string_literal: true

require 'json'
require 'minitest/autorun'
require 'open3'
require 'rbconfig'
require 'tmpdir'
require_relative '../compiler/parser'
require_relative '../compiler/resolver'
require_relative '../compiler/ir_emitter'
require_relative '../compiler/runtime'
require_relative '../compiler/world_save'
require_relative '../compiler/ask'

class TestAsk < Minitest::Test
  ROOT = File.expand_path('..', __dir__)
  RUBY = RbConfig.ruby

  def resolve(source)
    parser = BasicSharp::Parser.new(source)
    BasicSharp::SemanticResolver.new(parser.parse, dictionary: parser.dictionary).resolve
  end

  def runtime(source = demo_source, world_save: nil)
    BasicSharp::Runtime.new(resolve(source), world_save: world_save)
  end

  def demo_source
    File.read(File.join(ROOT, 'samples/ask_demo.bsharp'), encoding: 'UTF-8')
  end

  def answer(machine, question)
    BasicSharp::Ask.new(machine).answer_many([question]).first
  end

  def test_describes_a_thing
    entry = answer(runtime, 'what is henry')

    assert_equal 'thing', entry.fetch('type')
    assert_equal 'henry', entry.dig('answer', 'name')
    assert_equal 'guard', entry.dig('answer', 'kind')
    assert_equal ['calm'], entry.dig('answer', 'states')
    assert_equal 10, entry.dig('answer', 'values', 'health')
  end

  def test_explicit_thing_and_kind_questions
    machine = runtime

    assert_equal 'thing', answer(machine, 'what is Thing henry').fetch('type')
    kind = answer(machine, 'what is Kind guard')
    assert_equal 'kind', kind.fetch('type')
    assert_equal 'guard', kind.dig('answer', 'name')
    assert_equal 2, kind.dig('answer', 'thing_count')
  end

  def test_ambiguous_thing_and_kind_name_is_not_guessed
    source = <<~BSHARP
      KINDS
      [
          #guard is a #thing
      ].

      DEFINE
      [
          @guard is a #guard
      ].
    BSHARP
    error = assert_raises(BasicSharp::AskError) { answer(runtime(source), 'what is guard') }

    assert_includes error.message, "'guard' names both a Thing and a Kind."
    assert_includes error.message, 'what is Thing guard'
    assert_includes error.message, 'what is Kind guard'
  end

  def test_thing_part_questions
    machine = runtime

    assert_equal 'guard', answer(machine, 'what Kind is henry').dig('answer', 'kind')
    assert_equal ['calm'], answer(machine, 'what states does henry have').dig('answer', 'states')
    assert_equal({ 'damage' => 0, 'health' => 10 }, answer(machine, 'what values does henry have').dig('answer', 'values'))
    assert_equal({ 'on' => 'oak table' }, answer(machine, 'what relationships does brass key have').dig('answer', 'relationships'))
  end

  def test_kind_membership_includes_inherited_things_in_definition_order
    entry = answer(runtime, 'what Things are guards')
    members = entry.dig('answer', 'things')

    assert_equal %w[henry mara], members.map { |member| member.fetch('name') }
    assert_equal false, members[0].fetch('inherited')
    assert_equal true, members[1].fetch('inherited')
    assert_equal 'captain', members[1].fetch('kind')
  end

  def test_event_inspection_uses_runtime_matching_without_running_actions
    machine = runtime
    before = machine.snapshot
    save_ready = machine.save_ready?
    entry = answer(machine, 'what happens when player attacks henry')

    assert_equal true, entry.dig('answer', 'matched')
    assert_equal 'player attacks a guard', entry.dig('answer', 'matched_when')
    assert_equal ['a guard means henry', 'that guard means henry'], entry.dig('answer', 'understood')
    assert_equal ['(damage that guard by 3', '(cause that guard attacks player', '(change that guard to angry'], entry.dig('answer', 'actions')
    assert_equal before, machine.snapshot
    assert_equal save_ready, machine.save_ready?
  end

  def test_event_inspection_preserves_exact_thing_priority
    source = <<~BSHARP
      DEFINE
      [
          @henry is a #guard
      ].

      WHEN PLAYER attacks a #guard
      [
          |then (damage it
      ].

      WHEN PLAYER attacks @henry
      [
          |then (change @henry to angry
      ].
    BSHARP
    entry = answer(runtime(source), 'what happens when player attacks henry')

    assert_equal 'player attacks henry', entry.dig('answer', 'matched_when')
    assert_equal ['(change henry to angry'], entry.dig('answer', 'actions')
  end

  def test_event_inspection_preserves_nearest_kind_priority
    source = <<~BSHARP
      KINDS
      [
          #creature is a #thing
          #dragon is a #creature
          #wyrm is a #dragon
      ].

      DEFINE
      [
          @ember is a #wyrm
      ].

      WHEN PLAYER attacks a #creature
      [
          |then (damage it
      ].

      WHEN PLAYER attacks a #dragon
      [
          |then (change it to angry
      ].
    BSHARP
    entry = answer(runtime(source), 'what happens when player attacks ember')

    assert_equal 'player attacks a dragon', entry.dig('answer', 'matched_when')
  end

  def test_event_inspection_preserves_source_order_for_equal_kind_distance
    source = <<~BSHARP
      DEFINE
      [
          @henry is a #guard
      ].

      WHEN PLAYER attacks a #guard
      [
          |then (damage it
      ].

      WHEN PLAYER attacks a #guard
      [
          |then (change it to angry
      ].
    BSHARP
    entry = answer(runtime(source), 'what happens when player attacks henry')

    assert_equal ['(damage that guard'], entry.dig('answer', 'actions')
  end

  def test_unmatched_event_inspection_does_not_fail_or_mutate
    machine = runtime
    before = machine.snapshot
    entry = answer(machine, 'what happens when player dances')

    assert_equal false, entry.dig('answer', 'matched')
    assert_equal before, machine.snapshot
  end

  def test_true_if_rule_answers_include_truth_and_active_state
    machine = runtime
    machine.run_event('player attacks henry')
    entry = answer(machine, 'what IF rules are true')

    assert_equal 1, entry.dig('answer', 'true_count')
    assert_equal 1, entry.dig('answer', 'total_count')
    assert_equal true, entry.dig('answer', 'rules', 0, 'true')
    assert_equal true, entry.dig('answer', 'rules', 0, 'active')
  end

  def test_world_summary_reports_start_origin
    summary = answer(runtime, 'what is the world').fetch('answer')

    assert_equal 'START', summary.fetch('origin')
    assert_equal true, summary.fetch('settled')
    assert_equal 6, summary.fetch('things')
    assert_equal 1, summary.fetch('if_rules')
  end

  def test_save_question_without_loaded_save_explains_start_origin
    summary = answer(runtime, 'what is the save').fetch('answer')

    assert_equal false, summary.fetch('loaded')
    assert_equal true, summary.fetch('settled')
  end

  def test_loaded_save_answers_report_save_origin_and_header
    original = runtime
    original.run_event('player attacks henry')
    document = BasicSharp::WorldSave.document_for(original)
    restored = runtime(demo_source, world_save: document)

    world = answer(restored, 'what is the world').fetch('answer')
    save = answer(restored, 'what is the save').fetch('answer')
    assert_equal 'BSharp Save', world.fetch('origin')
    assert_equal true, save.fetch('loaded')
    assert_equal 1, save.fetch('format_version')
    assert_equal 6, save.fetch('things')
    assert_equal true, save.fetch('fingerprint_matched')
  end

  def test_questions_are_case_insensitive
    lower = answer(runtime, 'what is henry').fetch('answer')
    upper = answer(runtime, 'WHAT IS HENRY').fetch('answer')

    assert_equal lower, upper
  end

  def test_unknown_name_has_plain_explanation
    error = assert_raises(BasicSharp::AskError) { answer(runtime, 'what is henri') }

    assert_equal "BASIC# ASK does not know a Thing or Kind named 'henri'.", error.message
  end

  def test_unsupported_question_lists_supported_shapes
    error = assert_raises(BasicSharp::AskError) { answer(runtime, 'why is henry angry') }

    assert_includes error.message, 'BASIC# ASK does not understand that question yet.'
    assert_includes error.message, 'what happens when player attacks henry'
  end

  def test_repeated_questions_keep_command_order
    inspector = BasicSharp::Ask.new(runtime)
    answers = inspector.answer_many(['what is henry', 'what is the world', 'what is the save'])

    assert_equal ['what is henry', 'what is the world', 'what is the save'], answers.map { |entry| entry.fetch('question') }
  end

  def test_game_system_inspection_is_structured_and_read_only
    parser = BasicSharp::Parser.new(File.read(File.join(ROOT, 'samples/demon_killer_controls.bsharp'), encoding: 'UTF-8'))
    document = BasicSharp::SemanticResolver.new(parser.parse, dictionary: parser.dictionary).resolve
    machine = BasicSharp::Runtime.new(document)
    before = machine.snapshot
    entry = BasicSharp::Ask.new(machine).answer_many(['what game systems are declared']).first

    assert_equal 'game_declarations', entry.fetch('type')
    assert_equal 1, entry.dig('answer', 'control_count')
    assert_equal 1, entry.dig('answer', 'hover_count')
    assert_equal 1, entry.dig('answer', 'context_count')
    assert_equal before, machine.snapshot
  end

  def test_256_question_boundary
    inspector = BasicSharp::Ask.new(runtime)
    assert_equal 256, inspector.answer_many(Array.new(256, 'what is henry')).length

    error = assert_raises(BasicSharp::AskError) do
      inspector.answer_many(Array.new(257, 'what is henry'))
    end
    assert_equal 'BASIC# ASK accepts at most 256 questions per command.', error.message
  end

  def test_human_kind_output_is_bounded_but_json_is_complete
    definitions = (1..75).map { |index| "    @guard #{index} is a #guard" }.join("\n")
    source = "DEFINE\n[\n#{definitions}\n].\n"
    inspector = BasicSharp::Ask.new(runtime(source))
    answers = inspector.answer_many(['what Things are guards'])
    report = inspector.report(answers)
    document = inspector.document(answers)

    assert_includes report, '...and 25 more Things.'
    assert_includes report, 'Use --ask-json for the complete result.'
    assert_equal 75, document.dig('answers', 0, 'answer', 'things').length
  end

  def test_human_if_output_is_bounded_but_json_is_complete
    conditions = (1..60).map do |index|
      "IF PLAYER has #{index} value#{index}\n[\n    |then (damage PLAYER\n]."
    end.join("\n\n")
    facts = (1..60).map { |index| "    PLAYER has #{index} value#{index}" }.join("\n")
    source = "START\n[\n#{facts}\n].\n\n#{conditions}\n"
    inspector = BasicSharp::Ask.new(runtime(source))
    answers = inspector.answer_many(['what IF rules are true'])
    report = inspector.report(answers)

    assert_includes report, '...and 10 more IF rules.'
    assert_equal 60, answers.dig(0, 'answer', 'rules').length
  end

  def test_source_and_saved_bsir_answers_match
    resolved = resolve(demo_source)
    bsir = JSON.parse(BasicSharp::IREmitter.new(resolved).to_json)
    source_runtime = BasicSharp::Runtime.new(resolved)
    bsir_runtime = BasicSharp::Runtime.new(bsir)
    questions = ['what is henry', 'what Things are guards', 'what happens when player attacks henry', 'what is the world']

    source_answers = BasicSharp::Ask.new(source_runtime).answer_many(questions)
    bsir_answers = BasicSharp::Ask.new(bsir_runtime).answer_many(questions)
    assert_equal source_answers, bsir_answers
  end

  def test_source_and_restored_save_answers_match_for_the_same_world
    source_runtime = runtime
    source_runtime.run_event('player attacks henry')
    save = BasicSharp::WorldSave.document_for(source_runtime)
    restored = runtime(demo_source, world_save: save)
    questions = ['what is henry', 'what IF rules are true']

    source_answers = BasicSharp::Ask.new(source_runtime).answer_many(questions)
    restored_answers = BasicSharp::Ask.new(restored).answer_many(questions)
    assert_equal source_answers, restored_answers
  end

  def test_ask_json_is_byte_identical_for_identical_worlds
    questions = ['what is henry', 'what Things are guards', 'what is the world']
    first = BasicSharp::Ask.new(runtime)
    second = BasicSharp::Ask.new(runtime)

    assert_equal first.to_json(first.answer_many(questions)), second.to_json(second.answer_many(questions))
  end

  def test_ask_does_not_change_world_if_activity_or_save_readiness
    machine = runtime
    before_snapshot = machine.snapshot
    before_if = machine.ask_if_rules
    before_ready = machine.save_ready?
    inspector = BasicSharp::Ask.new(machine)
    inspector.answer_many([
      'what is henry',
      'what Things are guards',
      'what happens when player attacks henry',
      'what IF rules are true',
      'what is the world',
      'what is the save'
    ])

    assert_equal before_snapshot, machine.snapshot
    assert_equal before_if, machine.ask_if_rules
    assert_equal before_ready, machine.save_ready?
  end

  def test_separate_runtime_isolation
    first = runtime
    second = runtime
    first.run_event('player attacks henry')

    refute_equal answer(first, 'what is henry').fetch('answer'), answer(second, 'what is henry').fetch('answer')
  end

  def test_cli_repeated_ask_and_json_output
    stdout, stderr, status = Open3.capture3(
      RUBY,
      File.join(ROOT, 'compiler/basic_sharp.rb'),
      File.join(ROOT, 'samples/ask_demo.bsharp'),
      '--ask', 'what is henry',
      '--ask', 'what is the world',
      '--ask-json',
      chdir: ROOT
    )

    assert status.success?, stderr
    assert_empty stderr
    document = JSON.parse(stdout)
    assert_equal 'bsharp.ask.json', document.fetch('format')
    assert_equal '0.1.68', document.fetch('created_by_basic_sharp')
    assert_equal ['what is henry', 'what is the world'], document.fetch('answers').map { |entry| entry.fetch('question') }
  end

  def test_cli_ask_json_requires_a_question
    _stdout, stderr, status = Open3.capture3(
      RUBY,
      File.join(ROOT, 'compiler/basic_sharp.rb'),
      File.join(ROOT, 'samples/ask_demo.bsharp'),
      '--ask-json',
      chdir: ROOT
    )

    refute status.success?
    assert_equal 64, status.exitstatus
    assert_includes stderr, '--ask-json requires at least one --ask question'
  end

  def test_failed_ask_does_not_write_save
    Dir.mktmpdir do |dir|
      save_path = File.join(dir, 'should_not_exist.bsave.json')
      _stdout, stderr, status = Open3.capture3(
        RUBY,
        File.join(ROOT, 'compiler/basic_sharp.rb'),
        File.join(ROOT, 'samples/ask_demo.bsharp'),
        '--ask', 'why is henry angry',
        '--save-world', save_path,
        chdir: ROOT
      )

      refute status.success?
      assert_includes stderr, 'does not understand that question yet'
      refute File.exist?(save_path)
    end
  end

  def test_unmatched_run_does_not_answer_or_write_save
    Dir.mktmpdir do |dir|
      save_path = File.join(dir, 'should_not_exist.bsave.json')
      stdout, stderr, status = Open3.capture3(
        RUBY,
        File.join(ROOT, 'compiler/basic_sharp.rb'),
        File.join(ROOT, 'samples/ask_demo.bsharp'),
        '--run', 'player dances',
        '--ask', 'what is henry',
        '--save-world', save_path,
        chdir: ROOT
      )

      refute status.success?
      assert_empty stderr
      refute_includes stdout, 'ASK:'
      refute File.exist?(save_path)
    end
  end

  def test_profile_2_ask_preserves_text_and_counts_value_types
    text = File.read(File.join(ROOT, 'samples/text_values.bsharp'), encoding: 'UTF-8')
    machine = runtime(text)
    answers = BasicSharp::Ask.new(machine).answer_many(['what is north gate', 'what is the world'])
    assert_equal 'North  Gate!', answers.first.dig('answer', 'values', 'title')
    assert_equal 2, answers.last.dig('answer', 'text_values')
    assert_equal 4, answers.last.dig('answer', 'whole_number_values')
    report = BasicSharp::Ask.new(machine).report(answers)
    assert_includes report, 'title: "North  Gate!"'
    assert_includes report, 'text values: 2'
  end
end
