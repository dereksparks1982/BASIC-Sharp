# frozen_string_literal: true

require 'json'
require 'minitest/autorun'
require 'open3'
require 'tmpdir'
require_relative '../compiler/parser'
require_relative '../compiler/resolver'
require_relative '../compiler/runtime'
require_relative '../compiler/world_save'
require_relative '../compiler/ask'
require_relative '../compiler/bytecode_emitter'
require_relative '../compiler/bytecode_loader'
require_relative '../compiler/bytecode_virtual_machine'

class TestBytecodeVMIntegration < Minitest::Test
  ROOT = File.expand_path('..', __dir__)
  SAMPLE_EVENTS = {
    'ask_demo' => ['player attacks henry'],
    'every_guard' => ['player sounds brass bell', 'player attacks mara'],
    'first_room' => ['player attacks cinder', 'player takes brass key', 'player attacks henry'],
    'follow_up_events' => ['player attacks henry'],
    'values_and_amounts' => ['player sounds brass bell'],
    'world_save_demo' => ['player attacks henry']
  }.freeze
  ASK_QUESTIONS = [
    'what is henry',
    'what Kind is henry',
    'what Things are guards',
    'what happens when player attacks henry',
    'what IF rules are true',
    'what is the world',
    'what is the save'
  ].freeze

  def resolve_file(path)
    parser = BasicSharp::Parser.new(File.read(path))
    BasicSharp::SemanticResolver.new(parser.parse, dictionary: parser.dictionary).resolve
  end

  def source_runtime(name)
    BasicSharp::Runtime.new(resolve_file(File.join(ROOT, "samples/#{name}.bsharp")))
  end

  def bsir_runtime(name)
    BasicSharp::Runtime.load(File.join(ROOT, "samples/#{name}.bsir.json"))
  end

  def loader(name)
    BasicSharp::BytecodeLoader.read(File.join(ROOT, "samples/#{name}.bsbc"))
  end

  def vm(name, world_save: nil)
    BasicSharp::BytecodeVirtualMachine.new(loader(name), world_save: world_save)
  end

  def ask(machine, questions = ASK_QUESTIONS)
    BasicSharp::Ask.new(machine).answer_many(questions)
  end

  def test_source_bsir_and_bsbc_event_sequences_have_three_way_world_parity
    SAMPLE_EVENTS.each do |name, events|
      source = source_runtime(name)
      bsir = bsir_runtime(name)
      bytecode = vm(name)
      events.each do |event|
        source.run_event(event)
        bsir.run_event(event)
        bytecode.run_event(event)
      end
      assert_equal source.snapshot, bsir.snapshot, "source/BSIR #{name}"
      assert_equal source.snapshot, bytecode.snapshot, "source/BSBC #{name}"
    end
  end

  def test_vm_ask_answers_match_reference_runtime_and_do_not_mutate
    reference = source_runtime('ask_demo')
    bytecode = vm('ask_demo')
    before = bytecode.snapshot
    ready = bytecode.save_ready?

    assert_equal ask(reference), ask(bytecode)
    assert_equal before, bytecode.snapshot
    assert_equal ready, bytecode.save_ready?
  end

  def test_vm_save_document_matches_reference_runtime_after_same_event
    reference = source_runtime('world_save_demo')
    bytecode = vm('world_save_demo')
    reference.run_event('player attacks henry')
    bytecode.run_event('player attacks henry')

    assert_equal BasicSharp::WorldSave.document_for(reference), BasicSharp::WorldSave.document_for(bytecode)
  end

  def test_vm_restores_save_without_rerunning_start_or_startup_if
    original = vm('world_save_demo')
    original.run_event('player attacks henry')
    document = BasicSharp::WorldSave.document_for(original)
    restored = vm('world_save_demo', world_save: document)

    assert_equal original.snapshot, restored.snapshot
    assert_empty restored.startup_ran
    assert_empty restored.startup_if_rules
    assert_empty restored.startup_follow_up_events
    assert_nil restored.startup_if_error
    assert restored.save_ready?
    assert_equal 'BSharp Save', restored.ask_world_summary.fetch('origin')
    assert_equal true, restored.ask_save_summary.fetch('loaded')
  end

  def test_vm_save_restore_replay_matches_uninterrupted_execution
    uninterrupted = vm('world_save_demo')
    restored = vm('world_save_demo')

    25.times do
      uninterrupted.run_event('player attacks henry')
      restored.run_event('player attacks henry')
      document = BasicSharp::WorldSave.document_for(restored)
      restored = vm('world_save_demo', world_save: document)
    end

    assert_equal uninterrupted.snapshot, restored.snapshot
    assert_equal uninterrupted.ask_if_rules, restored.ask_if_rules
  end

  def test_failed_restore_does_not_mutate_existing_vm
    machine = vm('world_save_demo')
    machine.run_event('player attacks henry')
    before = machine.snapshot
    document = BasicSharp::WorldSave.document_for(machine)
    document['program_fingerprint']['value'] = '0' * 64

    assert_raises(BasicSharp::WorldSaveError) { machine.restore_world_save!(document) }
    assert_equal before, machine.snapshot
  end

  def test_many_vms_from_one_loader_are_isolated
    shared = loader('first_room')
    machines = Array.new(64) { BasicSharp::BytecodeVirtualMachine.new(shared) }
    machines.first.run_event('player attacks cinder')

    assert_equal 1, machines.first.snapshot.find { |entry| entry['name'] == 'cinder' }.fetch('damage')
    machines.drop(1).each do |machine|
      assert_equal 0, machine.snapshot.find { |entry| entry['name'] == 'cinder' }.fetch('values').fetch('damage')
    end
    assert shared.model.frozen?
  end

  def test_vm_save_output_is_byte_identical_when_world_is_unchanged
    machine = vm('ask_demo')
    machine.run_event('player attacks henry')

    Dir.mktmpdir do |dir|
      first = File.join(dir, 'first.bsave.json')
      second = File.join(dir, 'second.bsave.json')
      machine.write_world_save(first)
      machine.write_world_save(second)
      assert_equal File.binread(first), File.binread(second)
    end
  end

  def test_cli_runs_asks_saves_and_restores_bsbc_world
    Dir.mktmpdir do |dir|
      save = File.join(dir, 'world.bsave.json')
      command = [
        'ruby', File.join(ROOT, 'compiler/basic_sharp.rb'), File.join(ROOT, 'samples/ask_demo.bsbc'),
        '--run', 'player attacks henry', '--ask', 'what is the world', '--save-world', save
      ]
      out, err, status = Open3.capture3(*command)
      assert status.success?, err
      assert_includes out, 'BSharp Virtual Machine'
      assert_includes out, 'saved world:'
      assert File.file?(save)

      out, err, status = Open3.capture3(
        'ruby', File.join(ROOT, 'compiler/basic_sharp.rb'), File.join(ROOT, 'samples/ask_demo.bsbc'),
        '--load-world', save, '--ask', 'what is the save'
      )
      assert status.success?, err
      assert_includes out, 'format: BSharp Save'
      assert_includes out, 'program fingerprint: matched'
    end
  end

  def test_cli_ask_json_on_bsbc_is_deterministic_and_complete
    command = [
      'ruby', File.join(ROOT, 'compiler/basic_sharp.rb'), File.join(ROOT, 'samples/ask_demo.bsbc'),
      '--ask', 'what is henry', '--ask', 'what is the world', '--ask-json'
    ]
    first, first_err, first_status = Open3.capture3(*command)
    second, second_err, second_status = Open3.capture3(*command)
    assert first_status.success?, first_err
    assert second_status.success?, second_err
    assert_equal first, second
    document = JSON.parse(first)
    assert_equal 2, document.fetch('answers').length
  end

  def test_profile_2_vm_save_ask_and_restore_are_typed_and_exact
    loader = BasicSharp::BytecodeLoader.read(File.join(ROOT, 'samples/text_values.bsbc'))
    vm = BasicSharp::BytecodeVirtualMachine.new(loader)
    vm.run_event('player sounds brass bell')
    answers = BasicSharp::Ask.new(vm).answer_many(['what is north gate', 'what is the world'])
    assert_equal 'OPEN — RubyVM!', answers.first.dig('answer', 'values', 'title')
    assert_equal 2, answers.last.dig('answer', 'text_values')

    save = BasicSharp::WorldSave.document_for(vm)
    assert_equal 2, save.fetch('format_version')
    restored = BasicSharp::BytecodeVirtualMachine.new(loader, world_save: save)
    assert_equal vm.snapshot, restored.snapshot
    assert_empty restored.startup_ran
  end
end
