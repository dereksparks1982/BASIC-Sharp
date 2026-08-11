#!/usr/bin/env ruby
# frozen_string_literal: true

require 'digest'
require 'json'
require_relative '../compiler/small_compiler_subset_ir_emitter'
require_relative '../compiler/small_compiler_subset_bsbc_encoder'
require_relative '../compiler/small_compiler_subset_bsbc_loader'
require_relative '../compiler/small_compiler_subset_bsbc_virtual_machine'
require_relative '../compiler/bytecode_loader'
require_relative '../compiler/bytecode_virtual_machine'
require_relative '../compiler/runtime'
require_relative '../compiler/world_save'

ROOT = File.expand_path('..', __dir__)
SPEC_PATH = File.join(ROOT, 'spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_BSBC_VM_INDEPENDENCE_v1.json')
VM_PATH = File.join(ROOT, 'compiler/small_compiler_subset_bsbc_virtual_machine.rb')

spec = JSON.parse(File.read(SPEC_PATH, encoding: 'UTF-8'))

def assert_contract!(condition, message)
  raise "Small compiler subset BSharp VM independence failed: #{message}" unless condition
end

def normalize(value)
  case value
  when Hash then value.each_with_object({}) { |(key, child), result| result[key.to_s] = normalize(child) }.sort.to_h
  when Array then value.map { |child| normalize(child) }
  else value
  end
end

def semantic(value)
  case value
  when Hash
    value.each_with_object({}) do |(key, child), result|
      key = key.to_s
      next if %w[line_number caused_by_line].include?(key)
      result[key] = semantic(child)
    end.sort.to_h
  when Array then value.map { |child| semantic(child) }
  else value
  end
end

def digest_json(value)
  Digest::SHA256.hexdigest(JSON.generate(normalize(value)))
end

def machines_for(source)
  ir = BasicSharp::SmallCompilerSubsetIREmitter.new(source)
  encoder = BasicSharp::SmallCompilerSubsetBSBCEncoder.new(ir.bsharp_ir)
  subset_loader = BasicSharp::SmallCompilerSubsetBSBCLoader.new(encoder.binary, expected_fingerprint: encoder.fingerprint)
  production_loader = BasicSharp::BytecodeLoader.new(encoder.binary, expected_fingerprint: encoder.fingerprint)
  [
    ir,
    encoder,
    subset_loader,
    BasicSharp::SmallCompilerSubsetBSBCVirtualMachine.new(subset_loader),
    BasicSharp::BytecodeVirtualMachine.new(production_loader),
    BasicSharp::Runtime.new(ir.bsharp_ir)
  ]
end

assert_contract!(spec.fetch('format') == 'bsharp.small_compiler_subset.bsbc_vm_independence.contract.json', 'wrong spec identity')
assert_contract!(spec.fetch('format_version') == 1, 'wrong format version')
assert_contract!(spec.fetch('target_version') == BasicSharp::VERSION, 'target version mismatch')
assert_contract!(spec.fetch('status') == 'bsbc_vm_execution_independent_under_ruby_referee', 'status changed')

vm_source = File.read(VM_PATH, encoding: 'UTF-8')
assert_contract!(!vm_source.include?("require_relative 'bytecode_virtual_machine'"), 'independent VM requires production BytecodeVirtualMachine')
assert_contract!(!vm_source.match?(/\bBytecodeVirtualMachine\.new\b/), 'independent VM instantiates production BytecodeVirtualMachine')
assert_contract!(!vm_source.match?(/class\s+SmallCompilerSubsetBSBCVirtualMachine\s*<\s*BytecodeVirtualMachine/), 'independent VM inherits production BytecodeVirtualMachine')

fixture = spec.fetch('fixture')
source = File.read(File.join(ROOT, fixture.fetch('source_path')), encoding: 'UTF-8')
ir, encoder, subset_loader, vm, production_vm, ruby_referee = machines_for(source)

assert_contract!(encoder.profile == fixture.fetch('expected_profile'), 'dedicated fixture profile changed')
assert_contract!(encoder.binary.bytesize == fixture.fetch('expected_binary_bytes'), 'dedicated fixture byte count changed')
assert_contract!(Digest::SHA256.hexdigest(encoder.binary) == fixture.fetch('expected_binary_sha256'), 'dedicated fixture binary digest changed')
assert_contract!(Digest::SHA256.hexdigest(encoder.disassembly) == fixture.fetch('expected_disassembly_sha256'), 'dedicated fixture disassembly digest changed')
assert_contract!(digest_json(ir.bsharp_ir) == fixture.fetch('expected_bsharp_ir_sha256'), 'dedicated fixture IR digest changed')
assert_contract!(encoder.fingerprint == fixture.fetch('expected_fingerprint'), 'dedicated fixture fingerprint changed')
assert_contract!(digest_json(subset_loader.summary) == fixture.fetch('expected_loader_summary_sha256'), 'dedicated fixture loader summary changed')
assert_contract!(digest_json(subset_loader.model) == fixture.fetch('expected_loader_model_sha256'), 'dedicated fixture loader model changed')

vm_results = fixture.fetch('events').map { |event| vm.run_event(event) }
production_results = fixture.fetch('events').map { |event| production_vm.run_event(event) }
ruby_results = fixture.fetch('events').map { |event| ruby_referee.run_event(event) }

assert_contract!(normalize(vm_results) == normalize(production_results), 'event results differ from production VM referee')
assert_contract!(semantic(vm_results) == semantic(ruby_results), 'event results differ from Ruby runtime referee')
assert_contract!(normalize(vm.snapshot) == normalize(production_vm.snapshot), 'final world differs from production VM referee')
assert_contract!(normalize(vm.snapshot) == normalize(ruby_referee.snapshot), 'final world differs from Ruby runtime referee')
assert_contract!(digest_json(vm_results) == fixture.fetch('expected_event_results_sha256'), 'dedicated event-result digest changed')
assert_contract!(digest_json(vm.snapshot) == fixture.fetch('expected_final_snapshot_sha256'), 'dedicated final snapshot digest changed')
assert_contract!(digest_json(BasicSharp::WorldSave.document_for(vm)) == fixture.fetch('expected_save_document_sha256'), 'dedicated Save digest changed')
assert_contract!(normalize(BasicSharp::WorldSave.document_for(vm)) == normalize(BasicSharp::WorldSave.document_for(production_vm)), 'Save differs from production VM referee')
assert_contract!(normalize(BasicSharp::WorldSave.document_for(vm)) == normalize(BasicSharp::WorldSave.document_for(ruby_referee)), 'Save differs from Ruby runtime referee')

# Independence must survive disabling the production VM constructor.
klass = BasicSharp::BytecodeVirtualMachine
klass.singleton_class.class_eval do
  alias_method :__v077_original_new, :new
  define_method(:new) { |*| raise 'production BytecodeVirtualMachine invoked from independent path' }
end
begin
  isolated = BasicSharp::SmallCompilerSubsetBSBCVirtualMachine.new(subset_loader)
  isolated_result = isolated.run_event(fixture.fetch('events').first)
  assert_contract!(isolated_result.fetch('matched'), 'independent VM failed with production VM disabled')
ensure
  klass.singleton_class.class_eval do
    alias_method :new, :__v077_original_new
    remove_method :__v077_original_new
  end
end

# High-volume parity and deterministic replay.
high = spec.fetch('high_volume_parity')
count = high.fetch('event_count')
event = high.fetch('event')
_, _, _, high_vm, high_production, high_ruby = machines_for(source)
high_vm_results = Array.new(count) { high_vm.run_event(event) }
high_production_results = Array.new(count) { high_production.run_event(event) }
high_ruby_results = Array.new(count) { high_ruby.run_event(event) }
assert_contract!(normalize(high_vm_results) == normalize(high_production_results), 'high-volume results differ from production VM referee')
assert_contract!(semantic(high_vm_results) == semantic(high_ruby_results), 'high-volume results differ from Ruby runtime referee')
assert_contract!(digest_json(high_vm_results) == high.fetch('expected_independent_vm_event_results_sha256'), 'high-volume event digest changed')
assert_contract!(digest_json(high_vm.snapshot) == high.fetch('expected_final_snapshot_sha256'), 'high-volume final snapshot changed')

_, _, _, replay_vm, = machines_for(source)
replay_results = Array.new(count) { replay_vm.run_event(event) }
assert_contract!(digest_json(replay_results) == digest_json(high_vm_results), 'high-volume deterministic replay changed')
assert_contract!(normalize(replay_vm.snapshot) == normalize(high_vm.snapshot), 'high-volume replay final world changed')

# Loop-protection parity is part of execution ownership.
loop_source = <<~BSHARP
  DEFINE
  [
      @master bell is a #device
  ].

  WHEN PLAYER sounds @master bell
  [
      |then (cause PLAYER sounds @master bell
  ].
BSHARP
_, _, _, loop_vm, loop_production, loop_ruby = machines_for(loop_source)
loop_event = 'player sounds master bell'
loop_vm_result = loop_vm.run_event(loop_event)
loop_production_result = loop_production.run_event(loop_event)
loop_ruby_result = loop_ruby.run_event(loop_event)
assert_contract!(normalize(loop_vm_result) == normalize(loop_production_result), 'loop protection differs from production VM referee')
assert_contract!(semantic(loop_vm_result) == semantic(loop_ruby_result), 'loop protection differs from Ruby runtime referee')
assert_contract!(loop_vm_result.fetch('follow_up_events').length == 1_024, 'loop protection did not stop at 1,024 follow-up events')
assert_contract!(loop_vm_result.fetch('error') == BasicSharp::SmallCompilerSubsetBSBCVirtualMachine::EVENT_CHAIN_LIMIT_MESSAGE, 'loop-protection explanation changed')

parity_source = File.read(File.join(ROOT, 'compiler/small_compiler_subset_bsbc_execution_parity.rb'), encoding: 'UTF-8')
assert_contract!(parity_source.include?('SmallCompilerSubsetBSBCVirtualMachine.new(subset_loader)'), 'execution parity does not use independent VM')
assert_contract!(parity_source.include?('BytecodeVirtualMachine.new(production_loader)'), 'production VM is not isolated as a referee')

references = [
  'README.md',
  'docs/roadmap/BASIC_SHARP_ROADMAP.md',
  'docs/hand_off/BASIC_SHARP_MASTER_THREAD_HANDOFF.md',
  'docs/company_bible/BASIC_SHARP_COMPANY_BIBLE.md',
  'spec/self_hosting/BASIC_SHARP_SELF_HOSTING_SUBSET_v1.json',
  'spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_BSBC_EXECUTION_PARITY_v1.json'
]
references.each do |relative|
  text = File.read(File.join(ROOT, relative), encoding: 'UTF-8')
  assert_contract!(text.include?('spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_BSBC_VM_INDEPENDENCE_v1.json'), "#{relative} does not reference the BSharp VM independence spec")
end

puts "BASIC# Small Compiler Subset BSharp VM Execution Independence v#{BasicSharp::VERSION}"
puts 'Independent subset VM executes trusted model: PASS'
puts 'Production BSharp VM used only as referee: PASS'
puts 'START and event matching parity: PASS'
puts 'Kind inheritance and selector parity: PASS'
puts 'Action ordering and object interaction parity: PASS'
puts 'Value mutation and IF/OTHERWISE parity: PASS'
puts 'Follow-up event parity: PASS'
puts '1,024-event loop protection parity: PASS'
puts "High-volume deterministic parity: PASS (#{count} events)"
puts 'Final-world and BSharp Save parity: PASS'
puts 'Ruby referee runtime parity: PASS'
puts 'Profiles 1-7 remain unchanged: PASS'
puts 'SMALL COMPILER SUBSET BSHARP VM EXECUTION INDEPENDENCE: PASS'
