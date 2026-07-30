#!/usr/bin/env ruby
# frozen_string_literal: true

require 'benchmark'
require 'json'
require 'tmpdir'
require_relative '../compiler/parser'
require_relative '../compiler/resolver'
require_relative '../compiler/ir_emitter'
require_relative '../compiler/runtime'

GUARDS = Integer(ENV.fetch('BASIC_SHARP_STRESS_GUARDS', '300'))
DRAGONS = Integer(ENV.fetch('BASIC_SHARP_STRESS_DRAGONS', '200'))
EVENTS = Integer(ENV.fetch('BASIC_SHARP_STRESS_EVENTS', '10000'))

def source_text
  definitions = []
  GUARDS.times { |index| definitions << "a guard named guard #{index + 1}" }
  DRAGONS.times { |index| definitions << "a wyrm named dragon #{index + 1}" }
  definitions << 'a key named stress key'
  definitions << 'a table named stress table'
  definitions << 'a door named stress door'

  exact_rule = if GUARDS >= 250
                 <<~RULE
                   WHEN
                   [player attacks guard 250
                   <then> (change guard 250 to hostile].

                 RULE
               else
                 ''
               end

  <<~DKS
    KINDS
    [creature is a thing
    dragon is a creature
    wyrm is a dragon].

    DEFINE
    [#{definitions.join("\n")}].

    START
    [guard 1 is calm
    dragon 1 is calm
    stress key is on stress table
    stress door is locked].

    IF
    [stress door is locked
    <then> (unlock stress door].

    #{exact_rule}WHEN
    [player attacks a guard
    <then> (damage that guard
    <then> (change that guard to angry].

    WHEN
    [player attacks dragon 1
    <then> (damage dragon 1
    <then> (change dragon 1 to angry].

    WHEN
    [player attacks a creature
    <then> (damage that creature
    <then> (change that creature to angry].

    WHEN
    [player takes stress key
    <then> (carry stress key].
  DKS
end

def resolve(source)
  parser = BasicSharp::Parser.new(source)
  program = parser.parse
  resolved = BasicSharp::SemanticResolver.new(program, dictionary: parser.dictionary).resolve
  errors = resolved.diagnostics.select { |diagnostic| diagnostic.severity == 'error' }
  raise errors.map(&:message).join("\n") unless errors.empty?

  resolved
end

def run_events(machine)
  EVENTS.times do |index|
    guard_number = (index % GUARDS) + 1
    machine.run_event("player attacks guard #{guard_number}")
  end
  machine.run_event('player attacks dragon 1')
  machine.run_event('player attacks dragon 2') if DRAGONS >= 2
  machine.run_event('player takes stress key')
end

def thing(snapshot, name)
  snapshot.find { |entry| entry.fetch('name') == name }
end

source = source_text
resolved = nil
source_machine = nil
ir_machine = nil
source_seconds = Benchmark.realtime do
  resolved = resolve(source)
  source_machine = BasicSharp::Runtime.new(resolved)
  run_events(source_machine)
end

ir_seconds = Benchmark.realtime do
  Dir.mktmpdir do |dir|
    path = File.join(dir, 'runtime_stress.ir.json')
    File.write(path, "#{BasicSharp::IREmitter.new(resolved).to_json}\n")
    ir_machine = BasicSharp::Runtime.load(path)
    run_events(ir_machine)
  end
end

source_snapshot = source_machine.snapshot
ir_snapshot = ir_machine.snapshot
raise 'source and saved DKIR produced different worlds' unless source_snapshot == ir_snapshot

fresh = BasicSharp::Runtime.new(resolved)
raise 'state leaked into a fresh runtime' if thing(fresh.snapshot, 'guard 1').key?('damage')

unknown = fresh.run_event('player attacks missing guard')
raise 'unknown Thing stress check failed' unless unknown['error'] == "event Thing 'missing guard' is not defined"

inherited = fresh.run_event('player attacks dragon 2')
raise 'inherited Kind stress check failed' unless inherited['matched_when'] == 'player attacks a creature'
raise 'inherited context stress check failed' unless inherited['context'] == { 'creature' => 'dragon 2' }

wrong = fresh.run_event('player attacks stress door')
raise 'wrong Kind stress check failed' unless wrong['error'] == 'stress door is a door, not a guard'

puts "BASIC# Runtime Stress Test v#{BasicSharp::VERSION}"
puts "Things: #{GUARDS + DRAGONS + 4}"
puts "Events per execution path: #{EVENTS + 3}"
puts format('Source path seconds: %.3f', source_seconds)
puts format('Saved DKIR path seconds: %.3f', ir_seconds)
puts 'Source and saved DKIR parity: PASS'
puts 'Separate runtime isolation: PASS'
puts 'Unknown Thing explanation: PASS'
puts 'Inherited Kind matching: PASS'
puts 'Wrong Kind explanation: PASS'
puts 'Deterministic final world: PASS'
puts 'STRESS TEST: PASS'
