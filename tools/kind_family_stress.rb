#!/usr/bin/env ruby
# frozen_string_literal: true

require 'benchmark'
require 'tmpdir'
require_relative '../compiler/parser'
require_relative '../compiler/resolver'
require_relative '../compiler/ir_emitter'
require_relative '../compiler/runtime'

DEPTH = Integer(ENV.fetch('BASIC_SHARP_KIND_DEPTH', '256'))
TRIGGERS = Integer(ENV.fetch('BASIC_SHARP_KIND_TRIGGERS', '64'))
THINGS = Integer(ENV.fetch('BASIC_SHARP_KIND_THINGS', '500'))
EVENTS = Integer(ENV.fetch('BASIC_SHARP_KIND_EVENTS', '2000'))

raise 'Kind depth must be at least 2' if DEPTH < 2
raise 'Overlapping Trigger count must be at least 1' if TRIGGERS < 1
raise 'Overlapping Trigger count must be smaller than Kind depth' if TRIGGERS >= DEPTH
raise 'Descendant Thing count must be at least 2' if THINGS < 2
raise 'Repeated event count must be at least 1' if EVENTS < 1

LEAF_KIND = format('kind%03d', DEPTH)
NEAREST_KIND = format('kind%03d', DEPTH - 1)
EXACT_THING_NUMBER = [250, THINGS].min
EXACT_THING = "heir #{EXACT_THING_NUMBER}"


def source_text
  kinds = (1..DEPTH).map do |number|
    parent = number == 1 ? 'thing' : format('kind%03d', number - 1)
    "#{format('kind%03d', number)} is a #{parent}"
  end

  definitions = (1..THINGS).map { |number| "a #{LEAF_KIND} named heir #{number}" }
  first_trigger_kind = DEPTH - TRIGGERS
  ancestor_rules = (first_trigger_kind...(DEPTH)).map do |number|
    kind = format('kind%03d', number)
    <<~RULE
      WHEN
      [player attacks a #{kind}
      <then> (damage that #{kind}].
    RULE
  end

  <<~BASIC_SHARP
    KINDS
    [#{kinds.join("\n")}].

    DEFINE
    [#{definitions.join("\n")}].

    WHEN
    [player attacks #{EXACT_THING}
    <then> (change #{EXACT_THING} to friendly].

    #{ancestor_rules.join("\n")}
    WHEN
    [player gives a #{NEAREST_KIND}
    <then> (damage that #{NEAREST_KIND}].

    WHEN
    [player gives a #{NEAREST_KIND}
    <then> (change that #{NEAREST_KIND} to hostile].
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


def repeated_name(index)
  number = (index % (THINGS - 1)) + 1
  number += 1 if number >= EXACT_THING_NUMBER
  "heir #{number}"
end


def run_sequence(machine)
  counts = Hash.new(0)
  last = nil

  EVENTS.times do |index|
    name = repeated_name(index)
    last = machine.run_event("player attacks #{name}")
    unless last.fetch('matched_when') == "player attacks a #{NEAREST_KIND}"
      raise "nearest Kind priority failed for #{name}"
    end
    unless last.fetch('context') == { NEAREST_KIND => name }
      raise "event context failed for #{name}"
    end
    unless last.fetch('understood').include?("that #{NEAREST_KIND} means #{name}")
      raise "plain event context trace failed for #{name}"
    end
    counts[name] += 1
  end

  exact = machine.run_event("player attacks #{EXACT_THING}")
  raise 'exact Trigger priority failed' unless exact.fetch('matched_when') == "player attacks #{EXACT_THING}"
  raise 'exact Trigger unexpectedly kept Kind context' unless exact.fetch('context').empty?

  tie = machine.run_event('player gives heir 1')
  raise 'same-distance source-order tie failed' unless tie.fetch('ran') == ['(damage heir 1']

  snapshot = machine.snapshot
  counts.each do |name, expected|
    expected += 1 if name == 'heir 1'
    actual = thing(snapshot, name).fetch('damage')
    raise "damage count mismatch for #{name}: expected #{expected}, got #{actual}" unless actual == expected
  end

  exact_state = thing(snapshot, EXACT_THING)
  raise 'exact Trigger state change failed' unless exact_state.fetch('states') == ['friendly']
  raise 'exact Trigger incorrectly ran an ancestor rule' if exact_state.key?('damage')

  tie_state = thing(snapshot, 'heir 1')
  raise 'same-distance first rule did not run' unless tie_state.fetch('damage') == counts['heir 1'] + 1
  raise 'same-distance later rule incorrectly ran' if tie_state.fetch('states').include?('hostile')

  [snapshot, last]
end

source = source_text
resolved = resolve(source)
source_machine = nil
source_snapshot = nil
source_last = nil
source_seconds = Benchmark.realtime do
  source_machine = BasicSharp::Runtime.new(resolved)
  source_snapshot, source_last = run_sequence(source_machine)
end

saved_machine = nil
saved_snapshot = nil
saved_last = nil
saved_seconds = Benchmark.realtime do
  Dir.mktmpdir do |dir|
    path = File.join(dir, 'kind_family_stress.ir.json')
    File.write(path, "#{BasicSharp::IREmitter.new(resolved).to_json}\n")
    saved_machine = BasicSharp::Runtime.load(path)
    saved_snapshot, saved_last = run_sequence(saved_machine)
  end
end

raise 'source and saved DKIR produced different worlds' unless source_snapshot == saved_snapshot
raise 'source and saved DKIR produced different final contexts' unless source_last.fetch('context') == saved_last.fetch('context')

replay = BasicSharp::Runtime.new(resolved)
replay_snapshot, = run_sequence(replay)
raise 'deterministic replay failed' unless replay_snapshot == source_snapshot

fresh = BasicSharp::Runtime.new(resolved)
raise 'state leaked into a fresh runtime' if thing(fresh.snapshot, 'heir 1').key?('damage')

puts "BASIC# Kind-Family Stress Test v#{BasicSharp::VERSION}"
puts "Kind depth: #{DEPTH}"
puts "Overlapping ancestor Triggers: #{TRIGGERS}"
puts "Descendant Things: #{THINGS}"
puts "Repeated events per execution path: #{EVENTS}"
puts "Total events per execution path: #{EVENTS + 2}"
puts format('Source path seconds: %.3f', source_seconds)
puts format('Saved DKIR path seconds: %.3f', saved_seconds)
puts '256-level ancestry: PASS' if DEPTH >= 256
puts 'Overlapping ancestor Trigger priority: PASS'
puts 'Exact Trigger priority: PASS'
puts 'Nearest Kind priority: PASS'
puts 'Same-distance source-order priority: PASS'
puts 'Event context isolation: PASS'
puts 'Source and saved-DKIR parity: PASS'
puts 'Deterministic replay: PASS'
puts 'Separate runtime isolation: PASS'
puts 'KIND-FAMILY STRESS TEST: PASS'
