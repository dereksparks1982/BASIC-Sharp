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

MAX = 2_147_483_647
ITERATIONS = Integer(ENV.fetch('NUMBER_CHANGE_EVENTS', '10000'))

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
fixture = JSON.parse(File.read(File.join(root, 'spec/runtime_v5/BASIC_SHARP_NUMBER_CHANGE_RUNTIME_FIXTURES_v1.json'), encoding: 'UTF-8'))
input_path = File.join(root, fixture.fetch('input'))
expected_path = File.join(root, fixture.fetch('expected'))
assert_stress(Digest::SHA256.hexdigest(File.binread(input_path)) == fixture.fetch('input_sha256'), 'number-change input fixture hash changed')
assert_stress(Digest::SHA256.hexdigest(File.binread(expected_path)) == fixture.fetch('expected_sha256'), 'number-change expected fixture hash changed')
sample_document = compile(File.read(File.join(root, 'samples/number_changes.bsharp'), encoding: 'UTF-8'))
sample_runtime = BasicSharp::Runtime.new(sample_document)
sample_results = JSON.parse(File.read(input_path, encoding: 'UTF-8')).map { |event| sample_runtime.run_event(event) }
sample_actual = {
  'events' => sample_results,
  'ask' => BasicSharp::Ask.new(sample_runtime).answer_many([
    'what values does player have', 'what values does bow have', 'what IF rules are true'
  ]),
  'final_state' => sample_runtime.snapshot,
  'save' => BasicSharp::WorldSave.document_for(sample_runtime)
}
assert_stress(sample_actual == JSON.parse(File.read(expected_path, encoding: 'UTF-8')), 'number-change runtime fixture behavior changed')

source = <<~BS
  DEFINE
  [
      @coin is a #thing
      @toll is a #thing
  ].
  START
  [
      PLAYER has 0 score
      PLAYER has 10000 health
  ].
  WHEN PLAYER takes @coin
  [
      |then (increase score of PLAYER by 1
  ].
  WHEN PLAYER attacks @toll
  [
      |then (decrease score of PLAYER by 1
  ].
  IF PLAYER has at least 5000 score
  [
      |then (change PLAYER to on
  ].
  IF PLAYER has more than 9999 score
  [
      |then (change PLAYER to friendly
  ].
  IF PLAYER has at most 0 score
  [
      |then (change PLAYER to off
  ].
  IF PLAYER has less than 1 health
  [
      |then (change PLAYER to dead
  ].
BS

document = compile(source)
reference = BasicSharp::Runtime.new(document)
emitter = BasicSharp::BytecodeEmitter.new(document)
loader = BasicSharp::BytecodeLoader.new(emitter.binary)
machine = BasicSharp::BytecodeVirtualMachine.new(loader)

ITERATIONS.times do
  reference_result = reference.run_event('player takes coin')
  machine_result = machine.run_event('player takes coin')
  assert_stress(reference_result == machine_result, 'source and BSharp VM diverged during repeated increases')
end

ITERATIONS.times do
  reference_result = reference.run_event('player attacks toll')
  machine_result = machine.run_event('player attacks toll')
  assert_stress(reference_result == machine_result, 'source and BSharp VM diverged during repeated decreases')
end

assert_stress(thing(machine.snapshot, 'player').dig('values', 'score') == 0, 'repeated number changes did not return to zero')
assert_stress(machine.ask_if_rules.any? { |entry| entry.fetch('condition') == 'player has at most 0 score' && entry.fetch('active') }, 'at-most threshold did not rearm and fire')

overflow_source = source.sub('PLAYER has 0 score', "PLAYER has #{MAX} score")
overflow = BasicSharp::Runtime.new(compile(overflow_source)).run_event('player takes coin')
assert_stress(overflow.fetch('error') == "player score would be greater than #{MAX}.", 'overflow was not stopped atomically')
assert_stress(thing(overflow.fetch('state'), 'player').dig('values', 'score') == MAX, 'overflow changed the world')

underflow = BasicSharp::Runtime.new(document).run_event('player attacks toll')
assert_stress(underflow.fetch('error') == 'player score would be less than 0.', 'underflow was not stopped atomically')
assert_stress(thing(underflow.fetch('state'), 'player').dig('values', 'score') == 0, 'underflow changed the world')

puts "BASIC# Number Change and Threshold Stress Test v#{BasicSharp::VERSION}"
puts "Increase events per runtime: #{ITERATIONS}"
puts "Decrease events per runtime: #{ITERATIONS}"
puts 'Source and BSharp VM parity: PASS'
puts 'Deterministic runtime fixture: PASS'
puts 'Threshold crossing and rearming: PASS'
puts 'Atomic overflow and underflow: PASS'
puts 'NUMBER CHANGE AND THRESHOLD STRESS TEST: PASS'
