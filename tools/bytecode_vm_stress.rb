#!/usr/bin/env ruby
# frozen_string_literal: true

require 'benchmark'
require 'digest'
require 'json'
require_relative '../compiler/parser'
require_relative '../compiler/resolver'
require_relative '../compiler/runtime'
require_relative '../compiler/world_save'
require_relative '../compiler/ask'
require_relative '../compiler/bytecode_emitter'
require_relative '../compiler/bytecode_loader'
require_relative '../compiler/bytecode_virtual_machine'

ROOT = File.expand_path('..', __dir__)
FIXTURE = JSON.parse(File.read(File.join(ROOT, 'spec/bytecode_v1/BASIC_SHARP_BYTECODE_VM_HARDENING_FIXTURES_v1.json'), encoding: 'UTF-8'))
EVENTS = Integer(ENV.fetch('BASIC_SHARP_VM_STRESS_EVENTS', FIXTURE.fetch('default_events_per_path').to_s))
RESTORE_CYCLES = Integer(ENV.fetch('BASIC_SHARP_VM_RESTORE_CYCLES', FIXTURE.fetch('default_restore_cycles').to_s))
ISOLATED_VMS = Integer(ENV.fetch('BASIC_SHARP_VM_ISOLATED_WORLDS', FIXTURE.fetch('default_isolated_worlds').to_s))
ASK_QUESTIONS = Integer(ENV.fetch('BASIC_SHARP_VM_ASK_QUESTIONS', FIXTURE.fetch('default_ask_questions').to_s))

def resolve_file(path)
  parser = BasicSharp::Parser.new(File.read(path, encoding: 'UTF-8'))
  document = BasicSharp::SemanticResolver.new(parser.parse, dictionary: parser.dictionary).resolve
  errors = document.diagnostics.select { |diagnostic| diagnostic.severity == 'error' }
  raise errors.map(&:message).join("\n") unless errors.empty?
  document
end

def vm_for(name, world_save: nil)
  loader = BasicSharp::BytecodeLoader.read(File.join(ROOT, "samples/#{name}.bsbc"))
  BasicSharp::BytecodeVirtualMachine.new(loader, world_save: world_save)
end

def world_hash(machine)
  Digest::SHA256.hexdigest(JSON.generate(machine.snapshot))
end

source_document = resolve_file(File.join(ROOT, 'samples/first_room.bsharp'))
source_runtime = nil
bsir_runtime = nil
bsbc_vm = nil

source_seconds = Benchmark.realtime do
  source_runtime = BasicSharp::Runtime.new(source_document)
  EVENTS.times { source_runtime.run_event('player attacks cinder') }
end

bsir_seconds = Benchmark.realtime do
  bsir_runtime = BasicSharp::Runtime.load(File.join(ROOT, 'samples/first_room.bsir.json'))
  EVENTS.times { bsir_runtime.run_event('player attacks cinder') }
end

bsbc_seconds = Benchmark.realtime do
  bsbc_vm = vm_for('first_room')
  EVENTS.times { bsbc_vm.run_event('player attacks cinder') }
end

raise 'source and BSIR stress worlds differ' unless source_runtime.snapshot == bsir_runtime.snapshot
raise 'source and BSBC stress worlds differ' unless source_runtime.snapshot == bsbc_vm.snapshot

uninterrupted = vm_for('world_save_demo')
restored = vm_for('world_save_demo')
restore_seconds = Benchmark.realtime do
  RESTORE_CYCLES.times do
    uninterrupted.run_event('player attacks henry')
    restored.run_event('player attacks henry')
    document = BasicSharp::WorldSave.document_for(restored)
    restored = vm_for('world_save_demo', world_save: document)
  end
end
raise 'save/restore replay drifted from uninterrupted execution' unless uninterrupted.snapshot == restored.snapshot
raise 'save/restore IF state drifted' unless uninterrupted.ask_if_rules == restored.ask_if_rules

ask_vm = vm_for('ask_demo')
questions = Array.new(ASK_QUESTIONS) do |index|
  ['what is henry', 'what Things are guards', 'what happens when player attacks henry', 'what IF rules are true', 'what is the world'][index % 5]
end
before_ask = ask_vm.snapshot
before_ready = ask_vm.save_ready?
answers = BasicSharp::Ask.new(ask_vm).answer_many(questions)
raise 'ASK did not return every requested answer' unless answers.length == ASK_QUESTIONS
raise 'ASK mutated the VM world' unless ask_vm.snapshot == before_ask
raise 'ASK changed VM save readiness' unless ask_vm.save_ready? == before_ready

shared_loader = BasicSharp::BytecodeLoader.read(File.join(ROOT, 'samples/first_room.bsbc'))
machines = Array.new(ISOLATED_VMS) { BasicSharp::BytecodeVirtualMachine.new(shared_loader) }
machines.first.run_event('player attacks cinder')
raise 'isolated VM mutation did not happen' if machines.first.snapshot == machines.fetch(1).snapshot
baseline = machines.fetch(1).snapshot
raise 'state leaked across isolated VMs' unless machines.drop(1).all? { |machine| machine.snapshot == baseline }
raise 'shared loader model was mutated' unless shared_loader.model.frozen?

recovery_vm = vm_for('world_save_demo')
recovery_vm.run_event('player attacks henry')
recovery_before = recovery_vm.snapshot
broken_save = BasicSharp::WorldSave.document_for(recovery_vm)
broken_save['program_fingerprint']['value'] = '0' * 64
begin
  recovery_vm.restore_world_save!(broken_save)
  raise 'malformed save was accepted'
rescue BasicSharp::WorldSaveError
  # expected
end
raise 'failed restore mutated the existing VM world' unless recovery_vm.snapshot == recovery_before

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
parser = BasicSharp::Parser.new(if_loop_source)
resolved = BasicSharp::SemanticResolver.new(parser.parse, dictionary: parser.dictionary).resolve
emitter = BasicSharp::BytecodeEmitter.new(resolved)
if_loop_vm = BasicSharp::BytecodeVirtualMachine.new(BasicSharp::BytecodeLoader.new(emitter.binary))
raise 'IF loop guard did not stop the VM' unless if_loop_vm.startup_if_error.to_s.include?('kept waking each other')

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
parser = BasicSharp::Parser.new(event_loop_source)
resolved = BasicSharp::SemanticResolver.new(parser.parse, dictionary: parser.dictionary).resolve
emitter = BasicSharp::BytecodeEmitter.new(resolved)
event_loop_vm = BasicSharp::BytecodeVirtualMachine.new(BasicSharp::BytecodeLoader.new(emitter.binary))
event_loop = event_loop_vm.run_event('player sounds brass bell')
raise 'follow-up event guard did not stop the VM' unless event_loop['error'] == BasicSharp::BytecodeVirtualMachine::EVENT_CHAIN_LIMIT_MESSAGE
raise 'follow-up event guard stopped at the wrong count' unless event_loop.fetch('follow_up_events').length == 1_024

replay_a = vm_for('first_room')
replay_b = vm_for('first_room')
EVENTS.times do
  replay_a.run_event('player attacks cinder')
  replay_b.run_event('player attacks cinder')
end
raise 'repeated VM execution was not deterministic' unless world_hash(replay_a) == world_hash(replay_b)

puts "BASIC# BSharp VM Stress and Hardening Test v#{BasicSharp::VERSION}"
puts "Events per execution path: #{EVENTS}"
puts "Save/restore replay cycles: #{RESTORE_CYCLES}"
puts "Independent VM worlds: #{ISOLATED_VMS}"
puts "ASK questions: #{ASK_QUESTIONS}"
puts format('Source runtime seconds: %.3f', source_seconds)
puts format('Saved BSIR runtime seconds: %.3f', bsir_seconds)
puts format('BSharp VM seconds: %.3f', bsbc_seconds)
puts format('Save/restore cycle seconds: %.3f', restore_seconds)
puts 'Source / BSIR / BSBC world parity: PASS'
puts 'Repeated VM determinism: PASS'
puts 'Save / restore / replay parity: PASS'
puts 'ASK read-only parity: PASS'
puts 'Separate VM isolation: PASS'
puts 'Malformed-save recovery: PASS'
puts 'IF loop protection: PASS'
puts '1,024-event loop protection: PASS'
puts 'Loaded-program immutability: PASS'
puts 'VM STRESS AND HARDENING: PASS'
