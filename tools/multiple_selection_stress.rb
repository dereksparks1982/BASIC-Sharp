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


def assert_stress(condition, message)
  raise message unless condition
end

def thing(snapshot, name)
  snapshot.find { |entry| entry.fetch('name') == name }
end

def stress_source
  definitions = []
  DIRECT_GUARDS.times { |index| definitions << "a guard named guard #{index + 1}" }
  CAPTAINS.times { |index| definitions << "a captain named captain #{index + 1}" }
  UNRELATED_KEYS.times { |index| definitions << "a key named key #{index + 1}" }
  definitions << 'a device named alarm bell'

  <<~BS
    KINDS
    [captain is a guard].

    DEFINE
    [#{definitions.join("\n")}].

    WHEN
    [player sounds alarm bell
    <then> (damage every guard].

    WHEN
    [player attacks a guard
    <then> (damage every guard
    <then> (change that guard to angry].

    WHEN
    [player speaks alarm bell
    <then> (damage every creature].
  BS
end

def resolve(source)
  parser = BasicSharp::Parser.new(source)
  program = parser.parse
  document = BasicSharp::SemanticResolver.new(program, dictionary: parser.dictionary).resolve
  errors = document.diagnostics.select { |diagnostic| diagnostic.severity == 'error' }
  raise "multiple-selection stress source did not resolve: #{errors.map(&:message).join('; ')}" unless errors.empty?

  document
end

def run_repeated(machine)
  first_result = nil
  started = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  REPEATED_EVENTS.times do
    result = machine.run_event('player sounds alarm bell')
    first_result ||= result
  end
  elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC) - started
  [first_result, machine.snapshot, elapsed]
end

source = stress_source
document = resolve(source)
source_machine = BasicSharp::Runtime.new(document)
isolated_machine = BasicSharp::Runtime.new(document)

Dir.mktmpdir do |dir|
  path = File.join(dir, 'multiple_selection.bsir.json')
  File.write(path, "#{BasicSharp::IREmitter.new(document).to_json}\n")
  saved_machine = BasicSharp::Runtime.load(path)

  source_first, source_state, source_seconds = run_repeated(source_machine)
  saved_first, saved_state, saved_seconds = run_repeated(saved_machine)
  assert_stress(source_first == saved_first, 'source and saved BSharp IR first set results differ')

  direct_targets = source_first.fetch('selections').first.fetch('targets')
  assert_stress(source_first.fetch('state').length == TOTAL_THINGS, 'total Thing count changed')
  assert_stress(direct_targets.length == MATCHING_THINGS, 'set did not select all direct and inherited guards')
  assert_stress(direct_targets.first == 'guard 1', 'definition-order selection did not start with guard 1')
  assert_stress(direct_targets[DIRECT_GUARDS] == 'captain 1', 'inherited selection did not follow direct guards in definition order')
  assert_stress(direct_targets.last == "captain #{CAPTAINS}", 'definition-order selection ended incorrectly')
  assert_stress(source_first.fetch('steps').length == MATCHING_THINGS, 'structured results lost per-target changes')

  assert_stress(thing(source_state, 'guard 1').fetch('damage') == REPEATED_EVENTS, 'direct guard damage count was wrong')
  assert_stress(thing(source_state, "captain #{CAPTAINS}").fetch('damage') == REPEATED_EVENTS, 'inherited captain damage count was wrong')
  assert_stress(!thing(source_state, 'key 1').key?('damage'), 'unrelated Thing was mutated')
  assert_stress(source_state == saved_state, 'source and saved BSharp IR final states differ')

  report = source_machine.report(source_first)
  assert_stress(report.include?("every guard selected #{MATCHING_THINGS} Things:"), 'large selection summary was not bounded')
  assert_stress(report.include?("and #{MATCHING_THINGS - 12} more"), 'large selection remainder was not reported')
  assert_stress(report.include?("and #{MATCHING_THINGS - 12} more action results"), 'large action remainder was not reported')
  assert_stress(!report.include?("captain #{CAPTAINS} damage is now 1"), 'human report printed the full large result set')

  source_context = source_machine.run_event('player attacks guard 512')
  saved_context = saved_machine.run_event('player attacks guard 512')
  assert_stress(source_context.fetch('context') == { 'guard' => 'guard 512' }, 'singular event context was not preserved')
  assert_stress(source_context.fetch('selections').first.fetch('targets').length == MATCHING_THINGS, 'plural action did not keep full selection')
  assert_stress(thing(source_context.fetch('state'), 'guard 512').fetch('states') == ['angry'], 'that guard did not remain singular')
  assert_stress(thing(source_context.fetch('state'), 'guard 511').fetch('states').empty?, 'plural action corrupted singular that guard context')
  assert_stress(source_context == saved_context, 'source and saved BSharp IR context results differ')

  empty = source_machine.run_event('player speaks alarm bell')
  assert_stress(empty.fetch('matched'), 'empty-set event did not match')
  assert_stress(empty.fetch('selections').first.fetch('targets').empty?, 'known empty set was not empty')
  assert_stress(empty.fetch('steps').first.fetch('notice_lines').include?('every creature found no Things'), 'empty set explanation was missing')

  assert_stress(!thing(isolated_machine.snapshot, 'guard 1').key?('damage'), 'separate runtime inherited set mutations')

  replay_a = BasicSharp::Runtime.new(document)
  replay_b = BasicSharp::Runtime.new(document)
  5.times do
    replay_a.run_event('player sounds alarm bell')
    replay_b.run_event('player sounds alarm bell')
  end
  assert_stress(replay_a.snapshot == replay_b.snapshot, 'deterministic replay failed')

  puts "BASIC# Multiple-Selection Stress Test v#{BasicSharp::VERSION}"
  puts "Total Things: #{TOTAL_THINGS}"
  puts "Direct guards: #{DIRECT_GUARDS}"
  puts "Inherited captains: #{CAPTAINS}"
  puts "Things selected by every guard: #{MATCHING_THINGS}"
  puts "Repeated multi-target events per path: #{REPEATED_EVENTS}"
  puts "Per-target mutations per path: #{MATCHING_THINGS * REPEATED_EVENTS}"
  puts format('Source path seconds: %.3f', source_seconds)
  puts format('Saved BSharp IR path seconds: %.3f', saved_seconds)
  puts 'Direct Kind selection: PASS'
  puts 'Inherited Kind selection: PASS'
  puts 'Definition-order selection: PASS'
  puts 'Action-line ordering: PASS'
  puts 'Exact target isolation: PASS'
  puts "Singular 'that Kind' context preserved: PASS"
  puts 'Empty selection handling: PASS'
  puts 'Bounded human trace: PASS'
  puts 'Complete structured results: PASS'
  puts 'Source and saved BSharp IR parity: PASS'
  puts 'Separate runtime isolation: PASS'
  puts 'Deterministic final world: PASS'
  puts 'MULTIPLE-SELECTION STRESS TEST: PASS'
end
