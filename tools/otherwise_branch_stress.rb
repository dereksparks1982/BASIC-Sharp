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
require_relative '../compiler/ask'
require_relative '../compiler/world_save'

CYCLES = Integer(ENV.fetch('OTHERWISE_CYCLES', '10000'))

def assert_stress(condition, message)
  raise message unless condition
end

def compile(source)
  parser = BasicSharp::Parser.new(source)
  document = BasicSharp::SemanticResolver.new(parser.parse, dictionary: parser.dictionary).resolve
  errors = document.diagnostics.select { |entry| entry.severity == 'error' }
  raise errors.map(&:message).join("\n") unless errors.empty?
  document
end

def thing(snapshot, name)
  snapshot.find { |entry| entry.fetch('name') == name }
end

root = File.expand_path('..', __dir__)
fixture = JSON.parse(File.read(File.join(root, 'spec/runtime_v7/BASIC_SHARP_OTHERWISE_RUNTIME_FIXTURES_v1.json')))
input_path = File.join(root, fixture.fetch('input'))
expected_path = File.join(root, fixture.fetch('expected'))
assert_stress(Digest::SHA256.hexdigest(File.binread(input_path)) == fixture.fetch('input_sha256'), 'OTHERWISE input fixture hash changed')
assert_stress(Digest::SHA256.hexdigest(File.binread(expected_path)) == fixture.fetch('expected_sha256'), 'OTHERWISE expected fixture hash changed')

sample_document = compile(File.read(File.join(root, fixture.fetch('source'))))
sample_runtime = BasicSharp::Runtime.new(sample_document)
sample_results = JSON.parse(File.read(input_path)).map { |event| sample_runtime.run_event(event) }
sample_actual = {
  'events' => sample_results,
  'ask' => BasicSharp::Ask.new(sample_runtime).answer_many([
    'what values does player have', 'what IF rules are true', 'what IF rules are false', 'what is the world'
  ]),
  'final_state' => sample_runtime.snapshot,
  'save' => BasicSharp::WorldSave.document_for(sample_runtime)
}
assert_stress(sample_actual == JSON.parse(File.read(expected_path)), 'OTHERWISE runtime fixture behavior changed')

reference = BasicSharp::Runtime.new(sample_document)
machine = BasicSharp::BytecodeVirtualMachine.new(BasicSharp::BytecodeLoader.new(BasicSharp::BytecodeEmitter.new(sample_document).binary))
events = ['player attacks switch', 'player speaks switch']

CYCLES.times do
  events.each do |event|
    reference_result = reference.run_event(event)
    machine_result = machine.run_event(event)
    assert_stress(reference_result == machine_result, "source and BSharp VM diverged during #{event}")
  end
end

player = thing(machine.snapshot, 'player')
assert_stress(player.dig('values', 'ifruns') == CYCLES, 'IF branch did not run once per false-to-true transition')
assert_stress(player.dig('values', 'otherwiseruns') == CYCLES + 1, 'OTHERWISE branch did not run at startup and each true-to-false transition')
assert_stress(machine.ask_if_rules.first.fetch('branch') == 'OTHERWISE', 'final settled branch was not OTHERWISE')
save = BasicSharp::WorldSave.document_for(machine)
assert_stress(save.fetch('format_version') == 7, 'OTHERWISE stress did not produce Save format 7')
restored = BasicSharp::BytecodeVirtualMachine.new(BasicSharp::BytecodeLoader.new(BasicSharp::BytecodeEmitter.new(sample_document).binary), world_save: save)
assert_stress(restored.snapshot == machine.snapshot, 'Profile 7 Save restore changed the world')
assert_stress(restored.run_event('player speaks switch').fetch('if_rules').empty?, 'restore spuriously reran unchanged OTHERWISE')

puts "BASIC# OTHERWISE Branch Stress Test v#{BasicSharp::VERSION}"
puts "Alternating cycles per runtime: #{CYCLES}"
puts "Branch transitions per runtime: #{CYCLES * 2}"
puts 'Source and BSharp VM parity: PASS'
puts 'IF/OTHERWISE startup and alternating transitions: PASS'
puts 'Quiet unchanged branch, ASK, and Save restore: PASS'
puts 'OTHERWISE BRANCH STRESS TEST: PASS'
