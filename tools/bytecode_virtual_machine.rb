#!/usr/bin/env ruby
# frozen_string_literal: true

require 'digest'
require 'json'
require_relative '../compiler/parser'
require_relative '../compiler/resolver'
require_relative '../compiler/runtime'
require_relative '../compiler/bytecode_emitter'
require_relative '../compiler/bytecode_loader'
require_relative '../compiler/bytecode_virtual_machine'
require_relative '../compiler/game_interaction'
require_relative '../compiler/game_input'

ROOT = File.expand_path('..', __dir__)
FIXTURE_PATH = File.join(ROOT, 'spec/bytecode_v1/BASIC_SHARP_BYTECODE_VM_FIXTURES_v1.json')
FIXTURE = JSON.parse(File.read(FIXTURE_PATH))

module VMConformance
  module_function

  def assert!(condition, label)
    raise "#{label}: FAIL" unless condition
  end

  def resolve(path_or_source, file: true)
    source = file ? File.read(path_or_source) : path_or_source
    parser = BasicSharp::Parser.new(source)
    BasicSharp::SemanticResolver.new(parser.parse, dictionary: parser.dictionary).resolve
  end

  def semantic_result(result)
    {
      matched: result['matched'], error: result['error'], ran: result['ran'],
      context: result['context'], selections: result['selections'],
      if_conditions: result.fetch('if_rules', []).map { |entry| entry['condition'] },
      follow_up_events: result.fetch('follow_up_events', []).map { |entry| [entry['event'], entry['matched'], entry['error']] },
      state: result['state']
    }
  end

  def world_hash(snapshot)
    Digest::SHA256.hexdigest(JSON.generate(snapshot))
  end

  def vm_from_resolved(resolved)
    emitter = BasicSharp::BytecodeEmitter.new(resolved)
    loader = BasicSharp::BytecodeLoader.new(emitter.binary, expected_fingerprint: emitter.fingerprint)
    BasicSharp::BytecodeVirtualMachine.new(loader)
  end
end

include VMConformance

trusted_loader = begin
  error = begin
    BasicSharp::BytecodeVirtualMachine.new({})
    nil
  rescue BasicSharp::BytecodeVirtualMachineError => failure
    failure
  end
  !error.nil? && error.message.include?('validated BytecodeLoader')
end

startup_parity = true
event_parity = true
deterministic_worlds = true
canonical_reporting = true
FIXTURE.fetch('sample_programs').each do |entry|
  resolved = VMConformance.resolve(File.join(ROOT, entry.fetch('source')))
  runtime = BasicSharp::Runtime.new(resolved)
  loader = BasicSharp::BytecodeLoader.read(File.join(ROOT, entry.fetch('bytecode')))
  vm = BasicSharp::BytecodeVirtualMachine.new(loader)
  startup_parity &&= runtime.snapshot == vm.snapshot
  startup_parity &&= VMConformance.world_hash(vm.snapshot) == entry.fetch('startup_world_sha256')
  entry.fetch('events').each do |expected|
    runtime_result = runtime.run_event(expected.fetch('event'))
    vm_result = vm.run_event(expected.fetch('event'))
    event_parity &&= VMConformance.semantic_result(runtime_result) == VMConformance.semantic_result(vm_result)
  end
  deterministic_worlds &&= VMConformance.world_hash(vm.snapshot) == entry.fetch('final_world_sha256')
  canonical_reporting &&= vm.report(vm.run_event('unknown event')).include?('BSharp Virtual Machine')
end

meaning_parity = FIXTURE.fetch('meaning_cases').all? do |entry|
  resolved = VMConformance.resolve(File.join(ROOT, entry.fetch('source')))
  BasicSharp::Runtime.new(resolved).snapshot == VMConformance.vm_from_resolved(resolved).snapshot
end

text_resolved = VMConformance.resolve(File.join(ROOT, 'samples/text_values.bsharp'))
text_runtime = BasicSharp::Runtime.new(text_resolved)
text_vm = BasicSharp::BytecodeVirtualMachine.new(BasicSharp::BytecodeLoader.read(File.join(ROOT, 'samples/text_values.bsbc')))
text_runtime_result = text_runtime.run_event('player sounds brass bell')
text_vm_result = text_vm.run_event('player sounds brass bell')
text_profile_parity = VMConformance.semantic_result(text_runtime_result) == VMConformance.semantic_result(text_vm_result) &&
                      text_runtime.snapshot == text_vm.snapshot && text_vm.meaning_profile == 'bsharp.meaning.v2'

if_loop_source = <<~BSHARP
  DEFINE
  [
      @ember is a #creature
  ].

  START
  [
      @ember is calm
  ].

  IF @ember is calm
  [
      |then (change @ember to angry
  ].

  IF @ember is angry
  [
      |then (change @ember to calm
  ].
BSHARP
if_loop_vm = VMConformance.vm_from_resolved(VMConformance.resolve(if_loop_source, file: false))
if_loop_protection = if_loop_vm.startup_if_error.to_s.include?('kept waking each other')

event_loop_source = <<~BSHARP
  DEFINE
  [
      @brass bell is a #device
  ].

  WHEN PLAYER sounds @brass bell
  [
      |then (cause PLAYER sounds @brass bell
  ].
BSHARP
event_loop_vm = VMConformance.vm_from_resolved(VMConformance.resolve(event_loop_source, file: false))
event_loop_result = event_loop_vm.run_event('player sounds brass bell')
event_loop_protection = event_loop_result['error'] == BasicSharp::BytecodeVirtualMachine::EVENT_CHAIN_LIMIT_MESSAGE &&
                        event_loop_result.fetch('follow_up_events').length == 1_024

isolation_loader = BasicSharp::BytecodeLoader.read(File.join(ROOT, 'samples/first_room.bsbc'))
first_vm = BasicSharp::BytecodeVirtualMachine.new(isolation_loader)
second_vm = BasicSharp::BytecodeVirtualMachine.new(isolation_loader)
first_vm.run_event('player attacks cinder')
isolation = first_vm.snapshot != second_vm.snapshot && isolation_loader.model.frozen?

runtime_independence = begin
  singleton = BasicSharp::Runtime.singleton_class
  singleton.define_method(:new) { |*| raise 'reference runtime called' }
  begin
    vm = BasicSharp::BytecodeVirtualMachine.new(BasicSharp::BytecodeLoader.read(File.join(ROOT, 'samples/first_room.bsbc')))
    vm.run_event('player attacks cinder').fetch('matched')
  ensure
    singleton.remove_method(:new)
  end
rescue StandardError
  false
end

checks = {
  'Trusted-loader boundary' => trusted_loader,
  'Direct bytecode interpretation' => runtime_independence,
  'START world parity' => startup_parity,
  'Event matching parity' => event_parity,
  'Inherited Kind priority' => event_parity,
  'Singular binding parity' => event_parity,
  'Multiple-selection parity' => event_parity,
  'Action execution parity' => event_parity,
  'Value and atomicity parity' => event_parity,
  'Reactive IF parity' => event_parity && if_loop_protection,
  'Follow-up event parity' => event_parity,
  'Loop protection' => if_loop_protection && event_loop_protection,
  'Deterministic final worlds' => deterministic_worlds,
  'Separate VM isolation' => isolation,
  'Canonical reporting' => canonical_reporting,
  'Runtime independence' => runtime_independence,
  'Meaning Profile startup parity' => meaning_parity,
  'Meaning Profile 2 text parity' => text_profile_parity
}

game_loader = BasicSharp::BytecodeLoader.read(File.join(ROOT, 'samples/demon_killer_controls.bsbc'))
game_vm = BasicSharp::BytecodeVirtualMachine.new(game_loader)
interaction = BasicSharp::GameInteraction.new(game_loader.model, machine: game_vm)
game_result = interaction.execute('north gate', 'Open')
checks['Meaning Profile 3 context execution'] = game_result['error'].nil? && game_vm.ask_thing('north gate').fetch('states') == ['open']

platform_loader = BasicSharp::BytecodeLoader.read(File.join(ROOT, 'samples/platform_movement.bsbc'))
platform_vm = BasicSharp::BytecodeVirtualMachine.new(platform_loader)
platform_input = BasicSharp::GameInput.new(platform_loader.model)
platform_input.process('type' => 'key_down', 'key' => 'D')
platform_command = platform_input.process('type' => 'frame', 'time_ms' => 0, 'grounded' => true).fetch(0)
checks['Meaning Profile 4 platform movement'] = platform_vm.meaning_profile == 'bsharp.meaning.v4' &&
                                                platform_command.fetch('command') == 'move_with_collisions' &&
                                                platform_command.fetch('velocity_x') == 6.0

number_document = resolve(File.join(ROOT, 'samples/number_changes.bsharp'))
number_loader = BasicSharp::BytecodeLoader.read(File.join(ROOT, 'samples/number_changes.bsbc'))
number_vm = BasicSharp::BytecodeVirtualMachine.new(number_loader)
number_reference = BasicSharp::Runtime.new(number_document)
number_events = ['player takes gold coin', 'player attacks spikes', 'player attacks bow']
number_parity = number_events.all? { |event| number_vm.run_event(event) == number_reference.run_event(event) }
checks['Meaning Profile 5 number changes and thresholds'] = number_vm.meaning_profile == 'bsharp.meaning.v5' && number_parity

compound_document = resolve(File.join(ROOT, 'samples/compound_if_conditions.bsharp'))
compound_loader = BasicSharp::BytecodeLoader.read(File.join(ROOT, 'samples/compound_if_conditions.bsbc'))
compound_vm = BasicSharp::BytecodeVirtualMachine.new(compound_loader)
compound_reference = BasicSharp::Runtime.new(compound_document)
compound_events = ['player takes coin', 'player takes coin', 'player attacks boss', 'player speaks boss', 'player attacks boss', 'player attacks bridge']
compound_parity = compound_events.all? { |event| compound_vm.run_event(event) == compound_reference.run_event(event) }
checks['Meaning Profile 6 compound IF conditions'] = compound_vm.meaning_profile == 'bsharp.meaning.v6' &&
                                                     compound_parity &&
                                                     compound_vm.ask_if_rules.count { |entry| entry.fetch('active') } == 2

otherwise_document = resolve(File.join(ROOT, 'samples/otherwise_branches.bsharp'))
otherwise_loader = BasicSharp::BytecodeLoader.read(File.join(ROOT, 'samples/otherwise_branches.bsbc'))
otherwise_vm = BasicSharp::BytecodeVirtualMachine.new(otherwise_loader)
otherwise_reference = BasicSharp::Runtime.new(otherwise_document)
otherwise_events = ['player attacks switch', 'player attacks switch', 'player speaks switch']
otherwise_parity = otherwise_events.all? { |event| otherwise_vm.run_event(event) == otherwise_reference.run_event(event) }
checks['Meaning Profile 7 IF and OTHERWISE branches'] = otherwise_vm.meaning_profile == 'bsharp.meaning.v7' &&
                                                        otherwise_parity &&
                                                        otherwise_vm.ask_if_rules.first.fetch('branch') == 'OTHERWISE'

checks.each { |label, passed| VMConformance.assert!(passed, label) }

puts 'BSharp Virtual Machine v0.1.39'
puts "Sample programs: #{FIXTURE.fetch('sample_programs').length}"
puts "Valid Meaning Profile cases: #{FIXTURE.fetch('meaning_cases').length}"
puts 'Valid Meaning Profile 2 text sample: 1'
puts 'Valid Meaning Profile 3 game sample: 1'
puts 'Valid Meaning Profile 4 platform sample: 1'
puts 'Valid Meaning Profile 5 number-change sample: 1'
puts 'Valid Meaning Profile 6 compound IF sample: 1'
puts 'Valid Meaning Profile 7 IF and OTHERWISE sample: 1'
puts
checks.each { |label, _passed| puts "#{label}: PASS" }
puts
puts 'BSHARP VM: PASS'
