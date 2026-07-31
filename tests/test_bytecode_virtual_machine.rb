# frozen_string_literal: true

require 'json'
require 'minitest/autorun'
require 'open3'
require_relative '../compiler/parser'
require_relative '../compiler/resolver'
require_relative '../compiler/runtime'
require_relative '../compiler/bytecode_emitter'
require_relative '../compiler/bytecode_loader'
require_relative '../compiler/bytecode_virtual_machine'

module BytecodeVMRuntimeSabotage
  def new(*arguments, **keywords, &block)
    raise 'reference runtime must not be called' if Thread.current[:basic_sharp_vm_disable_runtime]

    super
  end
end

BasicSharp::Runtime.singleton_class.prepend(BytecodeVMRuntimeSabotage)

class TestBytecodeVirtualMachine < Minitest::Test
  ROOT = File.expand_path('..', __dir__)
  SAMPLES = %w[ask_demo every_guard first_room follow_up_events values_and_amounts world_save_demo].freeze
  SAMPLE_EVENTS = {
    'ask_demo' => ['player attacks henry'],
    'every_guard' => ['player sounds brass bell', 'player attacks mara'],
    'first_room' => ['player attacks cinder', 'player takes brass key', 'player attacks henry', 'player attacks ghost'],
    'follow_up_events' => ['player attacks henry'],
    'values_and_amounts' => ['player sounds brass bell'],
    'world_save_demo' => ['player attacks henry']
  }.freeze

  def resolve(source)
    parser = BasicSharp::Parser.new(source)
    BasicSharp::SemanticResolver.new(parser.parse, dictionary: parser.dictionary).resolve
  end

  def resolve_file(path)
    resolve(File.read(path))
  end

  def machine_for_source(source)
    emitter = BasicSharp::BytecodeEmitter.new(resolve(source))
    loader = BasicSharp::BytecodeLoader.new(emitter.binary, expected_fingerprint: emitter.fingerprint)
    BasicSharp::BytecodeVirtualMachine.new(loader)
  end

  def sample_runtime(name)
    BasicSharp::Runtime.new(resolve_file(File.join(ROOT, "samples/#{name}.bsharp")))
  end

  def sample_vm(name)
    loader = BasicSharp::BytecodeLoader.read(File.join(ROOT, "samples/#{name}.bsbc"))
    BasicSharp::BytecodeVirtualMachine.new(loader)
  end

  def semantic_result(result)
    {
      'event' => result['event'],
      'matched' => result['matched'],
      'matched_when' => result['matched_when'],
      'understood' => result['understood'],
      'ran' => result['ran'],
      'steps' => result['steps'],
      'selections' => result['selections'],
      'context' => result['context'],
      'error' => result['error'],
      'if_conditions' => result.fetch('if_rules', []).map { |entry| entry['condition'] },
      'follow_up_events' => result.fetch('follow_up_events', []).map do |entry|
        [entry['event'], entry['matched'], entry['error']]
      end,
      'state' => result['state']
    }
  end

  def thing(snapshot, name)
    snapshot.find { |entry| entry.fetch('name') == name }
  end

  def test_requires_a_successfully_validated_loader
    error = assert_raises(BasicSharp::BytecodeVirtualMachineError) do
      BasicSharp::BytecodeVirtualMachine.new({})
    end
    assert_includes error.message, 'successfully validated BytecodeLoader'
  end

  def test_all_six_sample_startup_worlds_match_the_reference_runtime
    SAMPLES.each do |name|
      runtime = sample_runtime(name)
      vm = sample_vm(name)
      assert_equal runtime.snapshot, vm.snapshot, name
      assert_equal runtime.startup_ran, vm.startup_ran, name
      assert runtime.startup_if_error == vm.startup_if_error, name
      assert_equal runtime.program_fingerprint, vm.program_fingerprint, name
    end
  end

  def test_sample_event_sequences_match_the_reference_runtime
    SAMPLE_EVENTS.each do |name, events|
      runtime = sample_runtime(name)
      vm = sample_vm(name)
      events.each do |event|
        assert_equal semantic_result(runtime.run_event(event)), semantic_result(vm.run_event(event)), "#{name}: #{event}"
      end
    end
  end

  def test_exact_and_inherited_event_priority_match
    source = <<~BSHARP
      KINDS
      [creature is a thing
      dragon is a creature
      wyrm is a dragon].

      DEFINE
      [a wyrm named ember].

      WHEN
      [player attacks a creature
      <then> (damage that creature].

      WHEN
      [player attacks a dragon
      <then> (damage that dragon by 2].

      WHEN
      [player attacks ember
      <then> (damage ember by 4].
    BSHARP
    runtime = BasicSharp::Runtime.new(resolve(source))
    vm = machine_for_source(source)
    assert_equal semantic_result(runtime.run_event('player attacks ember')), semantic_result(vm.run_event('player attacks ember'))
    assert_equal 4, thing(vm.snapshot, 'ember').fetch('damage')
  end

  def test_definition_order_every_kind_selection_and_that_binding_match
    source = File.read(File.join(ROOT, 'samples/every_guard.bsharp'))
    runtime = BasicSharp::Runtime.new(resolve(source))
    vm = machine_for_source(source)
    expected = runtime.run_event('player attacks mara')
    actual = vm.run_event('player attacks mara')
    assert_equal semantic_result(expected), semantic_result(actual)
    assert_equal %w[henry mara otto], actual.fetch('selections').first.fetch('targets')
    assert_equal ['calm', 'hostile'], thing(actual.fetch('state'), 'mara').fetch('states')
  end

  def test_reactive_if_rearms_after_becoming_false
    source = <<~BSHARP
      DEFINE
      [a creature named ember].

      START
      [ember is calm].

      WHEN
      [player attacks ember
      <then> (change ember to angry].

      WHEN
      [player speaks ember
      <then> (change ember to calm].

      IF
      [ember is angry
      <then> (damage player].
    BSHARP
    runtime = BasicSharp::Runtime.new(resolve(source))
    vm = machine_for_source(source)
    %w[attack speak attack].each do |verb|
      event = "player #{verb}s ember"
      assert_equal semantic_result(runtime.run_event(event)), semantic_result(vm.run_event(event)), event
    end
    assert_equal 2, thing(vm.snapshot, 'player').fetch('damage')
  end

  def test_follow_up_events_run_after_if_settlement_in_fifo_order
    runtime = sample_runtime('follow_up_events')
    vm = sample_vm('follow_up_events')
    expected = runtime.run_event('player attacks henry')
    actual = vm.run_event('player attacks henry')
    assert_equal semantic_result(expected), semantic_result(actual)
    assert_equal ['henry attacks player', 'mara sounds brass bell'], actual.fetch('follow_up_events').map { |entry| entry.fetch('event') }
  end

  def test_missing_value_failure_is_atomic_for_every_kind
    source = <<~BSHARP
      DEFINE
      [a guard named henry
      a guard named mara
      a device named bell].

      START
      [henry has 10 health].

      WHEN
      [player sounds bell
      <then> (change health of every guard to 7].
    BSHARP
    runtime = BasicSharp::Runtime.new(resolve(source))
    vm = machine_for_source(source)
    expected = runtime.run_event('player sounds bell')
    actual = vm.run_event('player sounds bell')
    assert_equal semantic_result(expected), semantic_result(actual)
    assert_equal 10, thing(actual.fetch('state'), 'henry').fetch('values').fetch('health')
    refute thing(actual.fetch('state'), 'mara').fetch('values').key?('health')
  end

  def test_loaded_program_stays_frozen_and_unchanged_after_execution
    loader = BasicSharp::BytecodeLoader.read(File.join(ROOT, 'samples/first_room.bsbc'))
    before = Marshal.load(Marshal.dump(loader.model))
    vm = BasicSharp::BytecodeVirtualMachine.new(loader)
    vm.run_event('player attacks cinder')
    assert_equal before, loader.model
    assert loader.model.frozen?
    assert loader.model.fetch(:blocks).frozen?
  end

  def test_virtual_machines_are_isolated
    loader = BasicSharp::BytecodeLoader.read(File.join(ROOT, 'samples/first_room.bsbc'))
    first = BasicSharp::BytecodeVirtualMachine.new(loader)
    second = BasicSharp::BytecodeVirtualMachine.new(loader)
    first.run_event('player attacks cinder')
    refute_equal first.snapshot, second.snapshot
    assert_equal 0, thing(second.snapshot, 'cinder').fetch('values').fetch('damage')
  end

  def test_vm_runs_when_reference_runtime_constructor_is_disabled
    loader = BasicSharp::BytecodeLoader.read(File.join(ROOT, 'samples/first_room.bsbc'))
    Thread.current[:basic_sharp_vm_disable_runtime] = true
    begin
      vm = BasicSharp::BytecodeVirtualMachine.new(loader)
      result = vm.run_event('player attacks cinder')
      assert result.fetch('matched')
      assert_equal 1, thing(result.fetch('state'), 'cinder').fetch('damage')
    ensure
      Thread.current[:basic_sharp_vm_disable_runtime] = false
    end
  end

  def test_all_twelve_valid_meaning_cases_start_in_runtime_parity
    paths = Dir[File.join(ROOT, 'spec/meaning_v1/cases/*/source.bsharp')].sort.first(12)
    paths.each do |path|
      resolved = resolve_file(path)
      runtime = BasicSharp::Runtime.new(resolved)
      emitter = BasicSharp::BytecodeEmitter.new(resolved)
      loader = BasicSharp::BytecodeLoader.new(emitter.binary, expected_fingerprint: emitter.fingerprint)
      vm = BasicSharp::BytecodeVirtualMachine.new(loader)
      assert_equal runtime.snapshot, vm.snapshot, path
      assert runtime.startup_if_error == vm.startup_if_error, path
    end
  end

  def test_plain_language_vm_report_identifies_vm_and_world_changes
    vm = sample_vm('first_room')
    report = vm.report(vm.run_event('player attacks cinder'))
    assert_includes report, 'BSharp Virtual Machine'
    assert_includes report, 'what matched:'
    assert_includes report, 'cinder damage is now 1'
    assert_includes report, 'world state:'
  end

  def test_cli_runs_validated_bsbc_and_rejects_unmatched_event
    command = ['ruby', File.join(ROOT, 'compiler/basic_sharp.rb'), File.join(ROOT, 'samples/first_room.bsbc'), '--run', 'player attacks cinder']
    out, err, status = Open3.capture3(*command)
    assert status.success?, err
    assert_includes out, 'BSharp Virtual Machine'
    assert_includes out, 'cinder damage is now 1'

    _out, err, status = Open3.capture3('ruby', File.join(ROOT, 'compiler/basic_sharp.rb'), File.join(ROOT, 'samples/first_room.bsbc'), '--run', 'player sings cinder')
    refute status.success?
    assert_empty err
  end

  def test_cli_rejects_disassembly_combined_with_vm_execution
    _out, err, status = Open3.capture3(
      'ruby', File.join(ROOT, 'compiler/basic_sharp.rb'), File.join(ROOT, 'samples/first_room.bsbc'),
      '--run', 'player attacks cinder', '--disassemble-bytecode'
    )
    refute status.success?
    assert_includes err, 'cannot combine disassembly'
  end
end
