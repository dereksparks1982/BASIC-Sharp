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

if_loop_source = <<~BSHARP
  DEFINE
  [a creature named ember].

  START
  [ember is calm].

  IF
  [ember is calm
  <then> (change ember to angry].

  IF
  [ember is angry
  <then> (change ember to calm].
BSHARP
if_loop_vm = VMConformance.vm_from_resolved(VMConformance.resolve(if_loop_source, file: false))
if_loop_protection = if_loop_vm.startup_if_error.to_s.include?('kept waking each other')

event_loop_source = <<~BSHARP
  DEFINE
  [a device named brass bell].

  WHEN
  [player sounds brass bell
  <then> (cause player sounds brass bell].
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
  singleton.alias_method(:__vm_lane_original_new, :new)
  singleton.define_method(:new) { |*| raise 'reference runtime called' }
  begin
    vm = BasicSharp::BytecodeVirtualMachine.new(BasicSharp::BytecodeLoader.read(File.join(ROOT, 'samples/first_room.bsbc')))
    vm.run_event('player attacks cinder').fetch('matched')
  ensure
    singleton.alias_method(:new, :__vm_lane_original_new)
    singleton.remove_method(:__vm_lane_original_new)
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
  'Meaning Profile startup parity' => meaning_parity
}

checks.each { |label, passed| VMConformance.assert!(passed, label) }

puts 'BSharp Virtual Machine v0.1.30'
puts "Sample programs: #{FIXTURE.fetch('sample_programs').length}"
puts "Valid Meaning Profile cases: #{FIXTURE.fetch('meaning_cases').length}"
puts
checks.each { |label, _passed| puts "#{label}: PASS" }
puts
puts 'BSHARP VM: PASS'
