#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require 'tmpdir'
require_relative '../compiler/parser'
require_relative '../compiler/resolver'
require_relative '../compiler/ir_emitter'
require_relative '../compiler/runtime'

DIRECT_GUARDS = 512
CAPTAINS = 256
UNRELATED_KEYS = 254
REPEATED_EVENTS = 100
MATCHING_THINGS = DIRECT_GUARDS + CAPTAINS
TOTAL_THINGS = 1 + DIRECT_GUARDS + CAPTAINS + UNRELATED_KEYS + 1
DAMAGE_AMOUNT = 3
MAX = 2_147_483_647


def assert_stress(condition, message)
  raise message unless condition
end

def thing(snapshot, name)
  snapshot.find { |entry| entry.fetch('name') == name }
end

def resolve(source)
  parser = BasicSharp::Parser.new(source)
  program = parser.parse
  document = BasicSharp::SemanticResolver.new(program, dictionary: parser.dictionary).resolve
  errors = document.diagnostics.select { |diagnostic| diagnostic.severity == 'error' }
  raise "value stress source did not resolve: #{errors.map(&:message).join('; ')}" unless errors.empty?

  document
end

def stress_source
  definitions = []
  names = []
  DIRECT_GUARDS.times do |index|
    name = "guard #{index + 1}"
    definitions << "a guard named #{name}"
    names << name
  end
  CAPTAINS.times do |index|
    name = "captain #{index + 1}"
    definitions << "a captain named #{name}"
    names << name
  end
  UNRELATED_KEYS.times { |index| definitions << "a key named key #{index + 1}" }
  definitions << 'a device named alarm bell'

  values = names.flat_map do |name|
    ["#{name} has 100 health", "#{name} has 5 courage"]
  end
  values << 'alarm bell has 0 signals'

  <<~BS
    KINDS
    [captain is a guard].

    DEFINE
    [#{definitions.join("\n")}].

    START
    [#{values.join("\n")}].

    WHEN
    [player sounds alarm bell
    <then> (damage every guard by #{DAMAGE_AMOUNT}
    <then> (change courage of every guard to 0].

    IF
    [guard 1 has 3 damage
    <then> (change signals of alarm bell to 1].
  BS
end

def run_repeated(machine)
  first = nil
  started = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  REPEATED_EVENTS.times do
    result = machine.run_event('player sounds alarm bell')
    first ||= result
  end
  elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC) - started
  [first, machine.snapshot, elapsed]
end

source = stress_source
document = resolve(source)
source_machine = BasicSharp::Runtime.new(document)
isolated_machine = BasicSharp::Runtime.new(document)

Dir.mktmpdir do |dir|
  path = File.join(dir, 'values.bsir.json')
  File.write(path, "#{BasicSharp::IREmitter.new(document).to_json}\n")
  saved_machine = BasicSharp::Runtime.load(path)

  source_first, source_state, source_seconds = run_repeated(source_machine)
  saved_first, saved_state, saved_seconds = run_repeated(saved_machine)

  assert_stress(source_first == saved_first, 'source and saved first results differ')
  assert_stress(source_state == saved_state, 'source and saved final states differ')
  assert_stress(source_state.length == TOTAL_THINGS, 'total Thing count changed')
  assert_stress(source_first.fetch('selections').first.fetch('targets').length == MATCHING_THINGS, 'guard selection count changed')
  assert_stress(source_first.fetch('steps').length == MATCHING_THINGS * 2, 'action-line structured results were incomplete')
  assert_stress(source_first.fetch('steps').first.fetch('word') == '(damage guard 1 by 3', 'damage line did not run first')
  assert_stress(source_first.fetch('steps')[MATCHING_THINGS - 1].fetch('word') == "(damage captain #{CAPTAINS} by 3", 'damage line did not finish its set')
  assert_stress(source_first.fetch('steps')[MATCHING_THINGS].fetch('word') == '(change courage of guard 1 to 0', 'value line began in the wrong position')

  expected_damage = DAMAGE_AMOUNT * REPEATED_EVENTS
  first_guard = thing(source_state, 'guard 1')
  last_captain = thing(source_state, "captain #{CAPTAINS}")
  assert_stress(first_guard.fetch('damage') == expected_damage, 'explicit damage amount accumulated incorrectly')
  assert_stress(last_captain.fetch('damage') == expected_damage, 'inherited target damage accumulated incorrectly')
  assert_stress(first_guard.fetch('values').fetch('health') == 100, 'damage secretly subtracted health')
  assert_stress(first_guard.fetch('values').fetch('courage') == 0, 'exact value assignment failed')
  assert_stress(thing(source_state, 'alarm bell').fetch('values').fetch('signals') == 1, 'exact-value IF did not react')
  assert_stress(!thing(source_state, 'key 1').key?('damage'), 'unrelated Thing was damaged')

  report = source_machine.report(source_first)
  assert_stress(report.include?("every guard selected #{MATCHING_THINGS} Things:"), 'large value selection was not bounded')
  assert_stress(report.include?("and #{MATCHING_THINGS * 2 - 12} more action results"), 'large value action remainder was not reported')

  assert_stress(!thing(isolated_machine.snapshot, 'guard 1').key?('damage'), 'separate runtime inherited damage')
  assert_stress(thing(isolated_machine.snapshot, 'guard 1').fetch('values').fetch('courage') == 5, 'separate runtime inherited value assignment')

  missing_source = <<~BS
    DEFINE
    [a guard named henry
    a guard named otto
    a device named bell].

    START
    [henry has 10 health].

    WHEN
    [player sounds bell
    <then> (change health of every guard to 7].
  BS
  missing_machine = BasicSharp::Runtime.new(resolve(missing_source))
  missing_result = missing_machine.run_event('player sounds bell')
  assert_stress(missing_result.fetch('error') == 'otto does not have a value named health.', 'missing-value explanation changed')
  assert_stress(thing(missing_result.fetch('state'), 'henry').fetch('values').fetch('health') == 10, 'missing-value action partially mutated the set')

  overflow_source = <<~BS
    DEFINE
    [a guard named henry
    a guard named otto
    a device named bell].

    START
    [henry has #{MAX - 5} damage
    otto has 2 damage].

    WHEN
    [player sounds bell
    <then> (damage every guard by 10].
  BS
  overflow_machine = BasicSharp::Runtime.new(resolve(overflow_source))
  overflow_result = overflow_machine.run_event('player sounds bell')
  assert_stress(overflow_result.fetch('error') == "henry damage would be greater than #{MAX}", 'overflow explanation changed')
  assert_stress(thing(overflow_result.fetch('state'), 'henry').fetch('damage') == MAX - 5, 'overflow partially mutated first target')
  assert_stress(thing(overflow_result.fetch('state'), 'otto').fetch('damage') == 2, 'overflow partially mutated later target')

  old_document = JSON.parse(File.read(File.expand_path('../tests/fixtures/first_room_v0_1_17.bsir.json', __dir__)))
  old_result = BasicSharp::Runtime.new(old_document).run_event('player attacks henry')
  assert_stress(thing(old_result.fetch('state'), 'henry').fetch('damage') == 1, 'old damage action did not default to one')

  replay_a = BasicSharp::Runtime.new(document)
  replay_b = BasicSharp::Runtime.new(document)
  5.times do
    replay_a.run_event('player sounds alarm bell')
    replay_b.run_event('player sounds alarm bell')
  end
  assert_stress(replay_a.snapshot == replay_b.snapshot, 'deterministic replay failed')

  puts "BASIC# Value-and-Amount Stress Test v#{BasicSharp::VERSION}"
  puts "Total Things: #{TOTAL_THINGS}"
  puts "Direct guards: #{DIRECT_GUARDS}"
  puts "Inherited captains: #{CAPTAINS}"
  puts "Things selected by every guard: #{MATCHING_THINGS}"
  puts "Repeated amount events per path: #{REPEATED_EVENTS}"
  puts "Explicit amount mutations per path: #{MATCHING_THINGS * REPEATED_EVENTS}"
  puts "Exact value assignments per path: #{MATCHING_THINGS * REPEATED_EVENTS}"
  puts format('Source path seconds: %.3f', source_seconds)
  puts format('Saved BSharp IR path seconds: %.3f', saved_seconds)
  puts 'Default damage amount compatibility: PASS'
  puts 'Explicit damage amounts: PASS'
  puts 'Generic Thing values: PASS'
  puts 'Exact value assignment: PASS'
  puts 'Exact value IF reactivity: PASS'
  puts 'Set action ordering: PASS'
  puts 'Missing-value atomicity: PASS'
  puts 'Overflow atomicity: PASS'
  puts 'No hidden health subtraction: PASS'
  puts 'Source and saved-BSharp IR parity: PASS'
  puts 'Separate runtime isolation: PASS'
  puts 'Deterministic final world: PASS'
  puts 'VALUE-AND-AMOUNT STRESS TEST: PASS'
end
