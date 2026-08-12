# frozen_string_literal: true

require 'json'
require 'minitest/autorun'
require 'tmpdir'
require_relative '../compiler/parser'
require_relative '../compiler/resolver'
require_relative '../compiler/runtime'
require_relative '../compiler/world_save'
require_relative '../compiler/ask'
require_relative '../compiler/runtime_transition'

module RuntimeTransitionReferenceSabotage
  def new(*arguments, **keywords, &block)
    if Thread.current[:basic_sharp_transition_disable_reference]
      raise 'reference runtime was constructed'
    end

    super
  end
end

BasicSharp::Runtime.singleton_class.prepend(RuntimeTransitionReferenceSabotage)

class TestRuntimeTransition < Minitest::Test
  ROOT = File.expand_path('..', __dir__)
  FIXTURE = JSON.parse(
    File.read(File.join(ROOT, 'spec/runtime_v1/BASIC_SHARP_PREFERRED_RUNTIME_FIXTURES_v1.json'), encoding: 'UTF-8')
  ).freeze

  def resolve(path)
    parser = BasicSharp::Parser.new(File.read(path, encoding: 'UTF-8'))
    BasicSharp::SemanticResolver.new(parser.parse, dictionary: parser.dictionary).resolve
  end

  def source_document(name)
    resolve(File.join(ROOT, "samples/#{name}.bsharp"))
  end

  def bsir_document(name)
    JSON.parse(File.read(File.join(ROOT, "samples/#{name}.bsir.json"), encoding: 'UTF-8'))
  end

  def transition(name, mode: :preferred, document: nil, world_save: nil)
    BasicSharp::RuntimeTransition.new(
      document || source_document(name),
      mode: mode,
      world_save: world_save
    )
  end

  def test_source_defaults_to_preferred_bsharp_vm
    machine = transition('first_room')
    result = machine.run_event('player attacks cinder')

    assert machine.preferred?
    refute machine.reference?
    refute machine.verifying?
    assert_instance_of BasicSharp::BytecodeLoader, machine.loader
    assert machine.loader.model.frozen?
    assert result.fetch('matched')
    assert_includes machine.report(result), 'BSharp Virtual Machine v0.1.79'
  end

  def test_bsir_defaults_to_preferred_bsharp_vm
    machine = transition('first_room', document: bsir_document('first_room'))
    result = machine.run_event('player attacks henry')

    assert result.fetch('matched')
    assert_equal 1, machine.snapshot.find { |thing| thing['name'] == 'henry' }.fetch('damage')
    assert_includes machine.report(result), 'BSharp Virtual Machine v0.1.79'
  end

  def test_reference_runtime_requires_explicit_mode
    machine = transition('first_room', mode: :reference)
    result = machine.run_event('player attacks cinder')

    assert machine.reference?
    refute machine.preferred?
    assert_nil machine.loader
    assert_includes machine.report(result), 'BASIC# Runtime v0.1.79'
  end

  def test_standalone_runtime_transition_audit_uses_the_live_version
    audit_source = File.read(File.join(ROOT, 'tools/runtime_transition.rb'), encoding: 'UTF-8')

    assert_includes audit_source, 'BSharp Virtual Machine v#{BasicSharp::VERSION}'
    assert_includes audit_source, 'BASIC# Runtime v#{BasicSharp::VERSION}'
    refute_match(/(?:BSharp Virtual Machine|BASIC# Runtime) v0\.\d+\.\d+/, audit_source)
  end

  def test_default_path_does_not_construct_reference_runtime
    Thread.current[:basic_sharp_transition_disable_reference] = true
    machine = transition('first_room')
    result = machine.run_event('player attacks cinder')
    assert result.fetch('matched')
  ensure
    Thread.current[:basic_sharp_transition_disable_reference] = false
  end

  def test_in_memory_pipeline_leaves_no_bytecode_files
    Dir.mktmpdir do |dir|
      before = Dir.children(dir)
      Dir.chdir(dir) do
        machine = transition('first_room')
        machine.run_event('player attacks cinder')
      end
      assert_equal before, Dir.children(dir)
    end
  end

  def test_verify_mode_checks_all_sample_event_sequences
    FIXTURE.fetch('samples').each do |entry|
      machine = transition(entry.fetch('name'), mode: :verify)
      entry.fetch('events').each do |event|
        result = machine.run_event(event)
        assert result.fetch('matched'), "#{entry.fetch('name')}: #{event}"
      end
      assert machine.verifying?
      assert machine.save_ready?
    end
  end

  def test_verify_mode_checks_ask_answers_without_mutation
    machine = transition('ask_demo', mode: :verify)
    machine.run_event('player attacks henry')
    before = machine.snapshot
    ready = machine.save_ready?
    answers = BasicSharp::Ask.new(machine).answer_many(FIXTURE.fetch('ask_questions'))

    assert_equal FIXTURE.fetch('ask_questions').length, answers.length
    assert_equal before, machine.snapshot
    assert_equal ready, machine.save_ready?
  end

  def test_verify_mode_checks_save_restore_and_replay
    machine = transition('world_save_demo', mode: :verify)
    machine.run_event('player attacks henry')
    document = BasicSharp::WorldSave.document_for(machine)
    before = machine.snapshot

    restored = transition('world_save_demo', mode: :verify, world_save: document)
    assert_equal before, restored.snapshot
    assert_empty restored.startup_ran
    assert restored.save_ready?

    expected = transition('world_save_demo', mode: :verify)
    expected.run_event('player attacks henry')
    expected.run_event('player attacks henry')
    restored.run_event('player attacks henry')
    assert_equal expected.snapshot, restored.snapshot
  end

  def test_verify_restore_failure_does_not_replace_current_world
    machine = transition('world_save_demo', mode: :verify)
    machine.run_event('player attacks henry')
    before = machine.snapshot
    broken = BasicSharp::WorldSave.document_for(machine)
    broken['program_fingerprint']['value'] = '0' * 64

    assert_raises(BasicSharp::WorldSaveError) { machine.restore_world_save!(broken) }
    assert_equal before, machine.snapshot
  end

  def test_shadow_mismatch_stops_with_plain_explanation
    machine = transition('first_room', mode: :verify)
    reference = machine.instance_variable_get(:@reference_machine)
    original_snapshot = reference.method(:snapshot)
    reference.define_singleton_method(:snapshot) do
      original_snapshot.call + [{ 'name' => 'parity intruder' }]
    end

    error = assert_raises(BasicSharp::RuntimeTransitionError) { machine.snapshot }
    assert_includes error.message, 'BSharp VM and reference runtime disagreed'
    assert_includes error.message, 'Area: world snapshot'
    assert_includes error.message, 'not allowed to continue'
  end

  def test_all_twelve_valid_meaning_cases_start_in_shadow_parity
    FIXTURE.fetch('meaning_cases').each do |case_name|
      path = File.join(ROOT, 'spec/meaning_v1/cases', case_name, 'source.bsharp')
      machine = BasicSharp::RuntimeTransition.new(resolve(path), mode: :verify)
      assert_nil machine.startup_if_error, case_name
      assert machine.loader.model.frozen?, case_name
    end
  end

  def test_repeated_preferred_execution_is_deterministic
    first = transition('first_room')
    second = transition('first_room')
    100.times do
      first.run_event('player attacks cinder')
      second.run_event('player attacks cinder')
    end

    assert_equal first.snapshot, second.snapshot
    assert_equal first.ask_if_rules, second.ask_if_rules
    assert_equal BasicSharp::WorldSave.document_for(first), BasicSharp::WorldSave.document_for(second)
  end

  def test_unknown_runtime_mode_is_rejected
    error = assert_raises(BasicSharp::RuntimeTransitionError) do
      transition('first_room', mode: :imaginary)
    end
    assert_includes error.message, 'Unknown BASIC# runtime mode'
  end

  def test_profile_2_runs_in_preferred_reference_and_shadow_modes
    path = File.join(ROOT, 'samples/text_values.bsharp')
    preferred = BasicSharp::RuntimeTransition.new(resolve(path))
    reference = BasicSharp::RuntimeTransition.new(resolve(path), mode: :reference)
    shadow = BasicSharp::RuntimeTransition.new(resolve(path), mode: :verify)
    [preferred, reference, shadow].each { |machine| machine.run_event('player sounds brass bell') }
    assert_equal preferred.snapshot, reference.snapshot
    assert_equal preferred.snapshot, shadow.snapshot
    assert_equal 'bsharp.meaning.v2', shadow.meaning_profile
    assert_equal 'bsharp.bytecode.v2', shadow.loader.model.fetch(:profile)
  end

  def test_profile_5_number_changes_run_in_all_runtime_modes
    path = File.join(ROOT, 'samples/number_changes.bsharp')
    preferred = BasicSharp::RuntimeTransition.new(resolve(path))
    reference = BasicSharp::RuntimeTransition.new(resolve(path), mode: :reference)
    shadow = BasicSharp::RuntimeTransition.new(resolve(path), mode: :verify)
    ['player takes gold coin', 'player attacks spikes', 'player attacks bow'].each do |event|
      [preferred, reference, shadow].each { |machine| machine.run_event(event) }
    end
    assert_equal preferred.snapshot, reference.snapshot
    assert_equal preferred.snapshot, shadow.snapshot
    assert_equal 'bsharp.meaning.v5', shadow.meaning_profile
    assert_equal 'bsharp.bytecode.v5', shadow.loader.model.fetch(:profile)
    assert_equal 5, BasicSharp::WorldSave.document_for(shadow).fetch('format_version')
  end

  def test_profile_6_compound_conditions_run_in_all_runtime_modes
    path = File.join(ROOT, 'samples/compound_if_conditions.bsharp')
    preferred = BasicSharp::RuntimeTransition.new(resolve(path))
    reference = BasicSharp::RuntimeTransition.new(resolve(path), mode: :reference)
    shadow = BasicSharp::RuntimeTransition.new(resolve(path), mode: :verify)
    ['player takes coin', 'player takes coin', 'player attacks boss', 'player speaks boss', 'player attacks boss', 'player attacks bridge'].each do |event|
      [preferred, reference, shadow].each { |machine| machine.run_event(event) }
    end
    assert_equal preferred.snapshot, reference.snapshot
    assert_equal preferred.snapshot, shadow.snapshot
    assert_equal 'bsharp.meaning.v6', shadow.meaning_profile
    assert_equal 'bsharp.bytecode.v6', shadow.loader.model.fetch(:profile)
    assert_equal 6, BasicSharp::WorldSave.document_for(shadow).fetch('format_version')
    assert_equal 2, shadow.ask_if_rules.count { |entry| entry.fetch('active') }
  end
end
