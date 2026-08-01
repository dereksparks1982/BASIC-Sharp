#!/usr/bin/env ruby
# frozen_string_literal: true

require 'benchmark'
require 'tmpdir'
require_relative '../compiler/parser'
require_relative '../compiler/resolver'
require_relative '../compiler/ir_emitter'
require_relative '../compiler/runtime'

CHAIN_RULES = Integer(ENV.fetch('BASIC_SHARP_IF_CHAIN_RULES', '128'))
UNRELATED_EVENTS = Integer(ENV.fetch('BASIC_SHARP_IF_UNRELATED_EVENTS', '1000'))
REACTIVATION_CYCLES = Integer(ENV.fetch('BASIC_SHARP_IF_REACTIVATION_CYCLES', '100'))

def source_text
  doors = (1..CHAIN_RULES).map { |index| "@chain door #{index} is a #door" }
  definitions = ['@trigger is a #creature', '@beacon is a #creature'] + doors
  starts = ['@trigger is calm', '@beacon is calm'] + (1..CHAIN_RULES).map { |index| "@chain door #{index} is locked" }

  chain = []
  chain << <<~RULE
    IF @trigger is angry
    [
        |then (unlock @chain door 1
    ].
  RULE
  (1...CHAIN_RULES).each do |index|
    chain << <<~RULE
      IF @chain door #{index} is unlocked
      [
          |then (unlock @chain door #{index + 1}
      ].
    RULE
  end

  <<~BASIC_SHARP
    DEFINE
    [
        #{definitions.join("\n")}
    ].

    START
    [
        #{starts.join("\n")}
    ].

    WHEN PLAYER attacks @trigger
    [
        |then (change @trigger to angry
    ].

    WHEN PLAYER speaks @trigger
    [
        |then (damage @trigger
    ].

    WHEN PLAYER attacks @beacon
    [
        |then (change @beacon to angry
    ].

    WHEN PLAYER speaks @beacon
    [
        |then (change @beacon to calm
    ].

    #{chain.join("\n")}
    IF @beacon is angry
    [
        |then (damage PLAYER
    ].
  BASIC_SHARP
end

def loop_source
  <<~BASIC_SHARP
    DEFINE
    [
        @ember is a #creature
    ].

    START
    [
        @ember is friendly
    ].

    WHEN PLAYER attacks @ember
    [
        |then (change @ember to calm
    ].

    IF @ember is calm
    [
        |then (change @ember to angry
    ].

    IF @ember is angry
    [
        |then (change @ember to calm
    ].
  BASIC_SHARP
end

def resolve(source)
  parser = BasicSharp::Parser.new(source)
  program = parser.parse
  document = BasicSharp::SemanticResolver.new(program, dictionary: parser.dictionary).resolve
  errors = document.diagnostics.select { |diagnostic| diagnostic.severity == 'error' }
  raise errors.map(&:message).join("\n") unless errors.empty?

  document
end

def thing(snapshot, name)
  snapshot.find { |entry| entry.fetch('name') == name }
end

def run_sequence(machine)
  cascade = machine.run_event('player attacks trigger')
  raise '128-rule cascade did not complete' unless cascade.fetch('if_rules').length == CHAIN_RULES

  expected_conditions = ['trigger is angry'] + (1...CHAIN_RULES).map { |index| "chain door #{index} is unlocked" }
  actual_conditions = cascade.fetch('if_rules').map { |entry| entry.fetch('condition') }
  raise 'IF source order changed' unless actual_conditions == expected_conditions

  (1..CHAIN_RULES).each do |index|
    states = thing(cascade.fetch('state'), "chain door #{index}").fetch('states')
    raise "chain door #{index} did not unlock" unless states == ['unlocked']
  end

  UNRELATED_EVENTS.times do
    result = machine.run_event('player speaks trigger')
    raise 'true IF repeated during unrelated event' unless result.fetch('if_rules').empty?
  end

  REACTIVATION_CYCLES.times do
    wake = machine.run_event('player attacks beacon')
    raise 're-armed IF did not wake' unless wake.fetch('if_rules').length == 1
    sleep_result = machine.run_event('player speaks beacon')
    raise 'false IF unexpectedly fired' unless sleep_result.fetch('if_rules').empty?
  end

  snapshot = machine.snapshot
  player = thing(snapshot, 'player')
  trigger = thing(snapshot, 'trigger')
  raise 'reactivation count mismatch' unless player.fetch('damage') == REACTIVATION_CYCLES
  raise 'unrelated event count mismatch' unless trigger.fetch('damage') == UNRELATED_EVENTS

  [snapshot, cascade]
end

resolved = resolve(source_text)
source_snapshot = nil
source_cascade = nil
source_seconds = Benchmark.realtime do
  source_machine = BasicSharp::Runtime.new(resolved)
  source_snapshot, source_cascade = run_sequence(source_machine)
end

saved_snapshot = nil
saved_cascade = nil
saved_seconds = Benchmark.realtime do
  Dir.mktmpdir do |dir|
    path = File.join(dir, 'if_rule_stress.bsir.json')
    File.write(path, "#{BasicSharp::IREmitter.new(resolved).to_json}\n")
    saved_machine = BasicSharp::Runtime.load(path)
    saved_snapshot, saved_cascade = run_sequence(saved_machine)
  end
end

raise 'source and saved BSharp IR produced different worlds' unless source_snapshot == saved_snapshot
raise 'source and saved BSharp IR produced different IF traces' unless source_cascade.fetch('if_rules') == saved_cascade.fetch('if_rules')

replay = BasicSharp::Runtime.new(resolved)
replay_snapshot, = run_sequence(replay)
raise 'deterministic final world failed' unless replay_snapshot == source_snapshot

fresh = BasicSharp::Runtime.new(resolved)
raise 'IF active state leaked into a fresh runtime' unless thing(fresh.snapshot, 'chain door 1').fetch('states') == ['locked']

loop_machine = BasicSharp::Runtime.new(resolve(loop_source))
loop_result = loop_machine.run_event('player attacks ember')
raise 'loop protection did not report an error' unless loop_result.fetch('error')&.include?('IF rules kept waking each other.')
raise 'loop protection leaked a Ruby exception' unless loop_result.fetch('error').include?('BASIC# stopped this chain so it would not run forever.')

puts "BASIC# IF-Rule Stress Test v#{BasicSharp::VERSION}"
puts "Chained IF rules: #{CHAIN_RULES}"
puts "Affected Things: #{CHAIN_RULES}"
puts "Unrelated events after settling: #{UNRELATED_EVENTS}"
puts "False-to-true reactivation cycles: #{REACTIVATION_CYCLES}"
puts format('Source path seconds: %.3f', source_seconds)
puts format('Saved BSharp IR path seconds: %.3f', saved_seconds)
puts "#{CHAIN_RULES}-rule cascade: PASS"
puts 'Source order: PASS'
puts 'No repeated firing while true: PASS'
puts 'Reactivation after false: PASS'
puts 'Source and saved-BSharp IR parity: PASS'
puts 'Separate runtime isolation: PASS'
puts 'Deterministic final world: PASS'
puts 'Loop protection: PASS'
puts 'IF-RULE STRESS TEST: PASS'
