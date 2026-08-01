#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require 'tempfile'
require 'benchmark'
require_relative '../compiler/parser'
require_relative '../compiler/resolver'
require_relative '../compiler/ir_emitter'
require_relative '../compiler/runtime'

DIRECT_EVENTS = 256
NESTED_EVENTS = 128
EXPECTED_CHAIN_EVENTS = 1 + DIRECT_EVENTS + 1 + NESTED_EVENTS
EXPECTED_DAMAGE = DIRECT_EVENTS + (NESTED_EVENTS * 2) + 3

def assert!(condition, message)
  raise message unless condition
end

def resolve(source)
  parser = BasicSharp::Parser.new(source)
  program = parser.parse
  document = BasicSharp::SemanticResolver.new(program, dictionary: parser.dictionary).resolve
  errors = document.diagnostics.select { |diagnostic| diagnostic.severity == 'error' }
  raise errors.map(&:to_s).join("\n") unless errors.empty?

  document
end

def chain_source
  definitions = [
    '@master bell is a #device',
    '@final alarm is a #device',
    '@henry is a #guard'
  ]
  DIRECT_EVENTS.times { |index| definitions << format('@bell %03d is a #device', index) }
  NESTED_EVENTS.times { |index| definitions << format('@echo %03d is a #device', index) }

  root_actions = ['|then (cause PLAYER speaks @master bell']
  DIRECT_EVENTS.times { |index| root_actions << format('|then (cause PLAYER sounds @bell %03d', index) }
  root_actions << '|then (change @henry to angry'

  rules = []
  DIRECT_EVENTS.times do |index|
    actions = ['|then (damage PLAYER']
    actions << format('|then (cause PLAYER sounds @echo %03d', index) if index < NESTED_EVENTS
    rules << <<~RULE
      WHEN PLAYER sounds @#{format('bell %03d', index)}
      [
          #{actions.join("\n")}
      ].
    RULE
  end
  NESTED_EVENTS.times do |index|
    rules << <<~RULE
      WHEN PLAYER sounds @#{format('echo %03d', index)}
      [
          |then (damage PLAYER by 2
      ].
    RULE
  end

  <<~BSHARP
    DEFINE
    [
        #{definitions.join("\n")}
    ].

    START
    [
        @henry is calm
    ].

    WHEN PLAYER sounds @master bell
    [
        #{root_actions.join("\n")}
    ].

    IF @henry is angry
    [
        |then (cause PLAYER sounds @final alarm
    ].

    WHEN PLAYER sounds @final alarm
    [
        |then (damage PLAYER by 3
    ].

    #{rules.join("\n")}
  BSHARP
end

def loop_source
  <<~BSHARP
    DEFINE
    [
        @master bell is a #device
    ].

    WHEN PLAYER sounds @master bell
    [
        |then (cause PLAYER sounds @master bell
    ].
  BSHARP
end

def context_source
  <<~BSHARP
    DEFINE
    [
        @henry is a #guard
    ].

    WHEN PLAYER attacks a #guard
    [
        |then (cause it attacks PLAYER
    ].

    WHEN a #guard attacks PLAYER
    [
        |then (damage PLAYER
    ].
  BSHARP
end

document = resolve(chain_source)
source_runtime = BasicSharp::Runtime.new(document)
source_result = nil
source_seconds = Benchmark.realtime do
  source_result = source_runtime.run_event('player sounds master bell')
end

saved_result = nil
saved_seconds = nil
Tempfile.create(['follow_up_event_stress', '.bsir.json']) do |file|
  file.write(BasicSharp::IREmitter.new(document).to_json)
  file.flush
  saved_runtime = BasicSharp::Runtime.load(file.path)
  saved_seconds = Benchmark.realtime do
    saved_result = saved_runtime.run_event('player sounds master bell')
  end
end

events = source_result.fetch('follow_up_events')
expected_direct = DIRECT_EVENTS.times.map { |index| format('player sounds bell %03d', index) }
expected_nested = NESTED_EVENTS.times.map { |index| format('player sounds echo %03d', index) }
expected_order = ['player speaks master bell'] + expected_direct + ['player sounds final alarm'] + expected_nested

assert!(events.length == EXPECTED_CHAIN_EVENTS, "expected #{EXPECTED_CHAIN_EVENTS} follow-up events, got #{events.length}")
assert!(events.map { |entry| entry.fetch('event') } == expected_order, 'follow-up event order changed')
assert!(!events.first.fetch('matched'), 'first unmatched follow-up unexpectedly matched')
assert!(events[1].fetch('matched'), 'event after unmatched follow-up did not run')
assert!(source_result.fetch('if_rules').map { |entry| entry.fetch('condition') } == ['henry is angry'], 'IF did not settle before follow-ups')
player = source_result.fetch('state').find { |thing| thing.fetch('name') == 'player' }
assert!(player.fetch('damage') == EXPECTED_DAMAGE, "expected player damage #{EXPECTED_DAMAGE}, got #{player.fetch('damage')}")
assert!(source_result == saved_result, 'source and saved BSharp IR results differ')

replay_one = BasicSharp::Runtime.new(document).run_event('player sounds master bell')
replay_two = BasicSharp::Runtime.new(document).run_event('player sounds master bell')
assert!(replay_one == replay_two, 'deterministic replay failed')

isolated_one = BasicSharp::Runtime.new(document)
isolated_two = BasicSharp::Runtime.new(document)
isolated_one.run_event('player sounds master bell')
assert!(isolated_one.snapshot != isolated_two.snapshot, 'separate runtimes shared world state')

context_result = BasicSharp::Runtime.new(resolve(context_source)).run_event('player attacks henry')
assert!(context_result.fetch('follow_up_events').first.fetch('event') == 'henry attacks player', "'that guard' was not captured")
assert!(context_result.fetch('follow_up_events').first.fetch('context') == { 'guard' => 'henry' }, 'fresh follow-up context failed')

loop_result = BasicSharp::Runtime.new(resolve(loop_source)).run_event('player sounds master bell')
assert!(loop_result.fetch('follow_up_events').length == 1_024, 'event-chain limit did not stop at 1,024')
assert!(loop_result.fetch('error') == BasicSharp::Runtime::EVENT_CHAIN_LIMIT_MESSAGE, 'event-chain loop explanation changed')
assert!(BasicSharp::Runtime.new(resolve(loop_source)).report(loop_result).lines.length < 150, 'human follow-up trace is not bounded')

puts "BASIC# Follow-Up Event Stress Test v#{BasicSharp::VERSION}"
puts "Direct follow-up events: #{DIRECT_EVENTS}"
puts "Nested follow-up events: #{NESTED_EVENTS}"
puts "Unmatched continuation events: 1"
puts "IF-caused events: 1"
puts "Total follow-up events in ordered chain: #{EXPECTED_CHAIN_EVENTS}"
puts format('Source path seconds: %.3f', source_seconds)
puts format('Saved BSharp IR path seconds: %.3f', saved_seconds)
puts 'Whole action body before follow-ups: PASS'
puts 'IF settlement before follow-ups: PASS'
puts 'First-created, first-run order: PASS'
puts 'Nested events append to the end: PASS'
puts 'Unmatched event continuation: PASS'
puts "Captured 'that Kind' context: PASS"
puts 'Fresh event context: PASS'
puts 'Source and saved-BSharp IR parity: PASS'
puts 'Deterministic replay: PASS'
puts 'Separate runtime isolation: PASS'
puts '1,024-event loop protection: PASS'
puts 'Bounded human trace: PASS'
puts 'FOLLOW-UP EVENT STRESS TEST: PASS'
