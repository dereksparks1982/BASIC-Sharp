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

CYCLES = Integer(ENV.fetch('COMPOUND_IF_CYCLES', '5000'))

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
fixture = JSON.parse(File.read(File.join(root, 'spec/runtime_v6/BASIC_SHARP_COMPOUND_IF_RUNTIME_FIXTURES_v1.json'), encoding: 'UTF-8'))
input_path = File.join(root, fixture.fetch('input'))
expected_path = File.join(root, fixture.fetch('expected'))
assert_stress(Digest::SHA256.hexdigest(File.binread(input_path)) == fixture.fetch('input_sha256'), 'compound IF input fixture hash changed')
assert_stress(Digest::SHA256.hexdigest(File.binread(expected_path)) == fixture.fetch('expected_sha256'), 'compound IF expected fixture hash changed')

sample_document = compile(File.read(File.join(root, fixture.fetch('source')), encoding: 'UTF-8'))
sample_runtime = BasicSharp::Runtime.new(sample_document)
sample_results = JSON.parse(File.read(input_path, encoding: 'UTF-8')).map { |event| sample_runtime.run_event(event) }
sample_actual = {
  'events' => sample_results,
  'ask' => BasicSharp::Ask.new(sample_runtime).answer_many([
    'what values does player have', 'what IF rules are true', 'what is the world'
  ]),
  'final_state' => sample_runtime.snapshot,
  'save' => BasicSharp::WorldSave.document_for(sample_runtime)
}
assert_stress(sample_actual == JSON.parse(File.read(expected_path, encoding: 'UTF-8')), 'compound IF runtime fixture behavior changed')

source = <<~BS
  DEFINE
  [
      @boss is a #creature
      @bridge is a #thing
  ].
  START
  [
      PLAYER has 100 score
      PLAYER has 1 health
      PLAYER has 0 victories
      PLAYER has 0 alarms
      @boss is alive
      @bridge is whole
  ].
  WHEN PLAYER attacks @boss
  [
      |then (change @boss to dead
  ].
  WHEN PLAYER speaks @boss
  [
      |then (change @boss to alive
  ].
  WHEN PLAYER attacks @bridge
  [
      |then (change @bridge to broken
  ].
  WHEN PLAYER speaks @bridge
  [
      |then (change @bridge to whole
  ].
  IF PLAYER has at least 100 score and @boss is dead
  [
      |then (increase victories of PLAYER by 1
  ].
  IF PLAYER has less than 1 health or @bridge is broken
  [
      |then (increase alarms of PLAYER by 1
  ].
BS

document = compile(source)
reference = BasicSharp::Runtime.new(document)
machine = BasicSharp::BytecodeVirtualMachine.new(BasicSharp::BytecodeLoader.new(BasicSharp::BytecodeEmitter.new(document).binary))
events = ['player attacks boss', 'player speaks boss', 'player attacks bridge', 'player speaks bridge']

CYCLES.times do
  events.each do |event|
    reference_result = reference.run_event(event)
    machine_result = machine.run_event(event)
    assert_stress(reference_result == machine_result, "source and BSharp VM diverged during #{event}")
  end
end

player = thing(machine.snapshot, 'player')
assert_stress(player.dig('values', 'victories') == CYCLES, 'and condition did not wake once per false-to-true cycle')
assert_stress(player.dig('values', 'alarms') == CYCLES, 'or condition did not wake once per false-to-true cycle')
assert_stress(machine.ask_if_rules.none? { |entry| entry.fetch('active') }, 'compound IF rules did not rearm after the final false result')
assert_stress(BasicSharp::WorldSave.document_for(machine).fetch('format_version') == 6, 'compound IF stress did not produce Save format 6')

quoted = compile(<<~BS)
  START
  [
      PLAYER has "rock and roll or blues" motto
  ].
  IF PLAYER has "rock and roll or blues" motto
  [
      |then (change PLAYER to dead
  ].
BS
assert_stress(quoted.meaning_profile == 'bsharp.meaning.v2', 'quoted and/or was treated as a connector')

mixed_parser = BasicSharp::Parser.new("IF PLAYER is ready and PLAYER is armed or PLAYER is safe\n[\n].\n")
mixed = BasicSharp::SemanticResolver.new(mixed_parser.parse, dictionary: mixed_parser.dictionary).resolve
assert_stress(mixed.diagnostics.any? { |entry| entry.message.include?('does not mix and and or') }, 'mixed connector rejection changed')

puts "BASIC# Compound IF Stress Test v#{BasicSharp::VERSION}"
puts "Reactive cycles per runtime: #{CYCLES}"
puts "Events per runtime: #{CYCLES * events.length}"
puts 'Source and BSharp VM parity: PASS'
puts 'AND/OR false-to-true and rearming: PASS'
puts 'Quoted operator words and mixed-operator rejection: PASS'
puts 'Save format 6 and deterministic fixture: PASS'
puts 'COMPOUND IF STRESS TEST: PASS'
