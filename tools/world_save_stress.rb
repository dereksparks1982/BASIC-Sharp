#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require 'tempfile'
require_relative '../compiler/parser'
require_relative '../compiler/resolver'
require_relative '../compiler/runtime'
require_relative '../compiler/world_save'

DIRECT_GUARDS = 384
CAPTAINS = 128
TOTAL_SELECTED = DIRECT_GUARDS + CAPTAINS
REPLAY_EVENTS = 100


def resolve(source)
  parser = BasicSharp::Parser.new(source)
  program = parser.parse
  document = BasicSharp::SemanticResolver.new(program, dictionary: parser.dictionary).resolve
  unless document.error_count.zero?
    raise document.diagnostics.map(&:to_s).join("\n")
  end
  document
end


def assert_pass(condition, label)
  raise "#{label}: FAIL" unless condition

  puts "#{label}: PASS"
end

kind_lines = ['#captain is a #guard']
definition_lines = []
start_lines = []
DIRECT_GUARDS.times do |index|
  name = format('guard%03d', index)
  definition_lines << "@#{name} is a #guard"
  start_lines << "@#{name} is calm"
  start_lines << "@#{name} has 10 health"
end
CAPTAINS.times do |index|
  name = format('captain%03d', index)
  definition_lines << "@#{name} is a #captain"
  start_lines << "@#{name} is calm"
  start_lines << "@#{name} has 10 health"
end
definition_lines.concat(['@brass bell is a #device', '@brass key is a #key', '@oak table is a #table'])
start_lines << '@brass key is on @oak table'

source = <<~BSHARP
  KINDS
  [
      #{kind_lines.join("\n")}
  ].

  DEFINE
  [
      #{definition_lines.join("\n")}
  ].

  START
  [
      #{start_lines.join("\n")}
  ].

  WHEN PLAYER sounds @brass bell
  [
      |then (damage every #guard by 3
      |then (change health of every #guard to 7
      |then (cause @guard000 attacks PLAYER
  ].

  IF @guard000 has 3 damage
  [
      |then (change @guard000 to angry
      |then (cause @captain000 sounds @brass bell
  ].

  WHEN @guard000 attacks PLAYER
  [
      |then (damage PLAYER
      |then (carry @brass key
  ].

  WHEN @captain000 sounds @brass bell
  [
      |then (damage PLAYER
  ].
BSHARP

document = resolve(source)
source_runtime = BasicSharp::Runtime.new(document)
source_start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
source_result = source_runtime.run_event('player sounds brass bell')
source_seconds = Process.clock_gettime(Process::CLOCK_MONOTONIC) - source_start
raise source_result['error'] if source_result['error']

bsir = JSON.parse(JSON.generate(document.to_h))
bsir_runtime = BasicSharp::Runtime.new(bsir)
bsir_start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
bsir_result = bsir_runtime.run_event('player sounds brass bell')
bsir_seconds = Process.clock_gettime(Process::CLOCK_MONOTONIC) - bsir_start
raise bsir_result['error'] if bsir_result['error']

source_save = BasicSharp::WorldSave.document_for(source_runtime)
bsir_save = BasicSharp::WorldSave.document_for(bsir_runtime)
source_save_json = "#{JSON.pretty_generate(source_save)}\n"
bsir_save_json = "#{JSON.pretty_generate(bsir_save)}\n"

restored_source = BasicSharp::Runtime.new(document, world_save: JSON.parse(source_save_json))
restored_bsir = BasicSharp::Runtime.new(bsir, world_save: JSON.parse(bsir_save_json))

first_replay = nil
second_replay = nil
REPLAY_EVENTS.times do
  first_replay = restored_source.run_event('guard000 attacks player')
  second_replay = restored_bsir.run_event('guard000 attacks player')
end

thing_names = source_save.dig('world', 'things').map { |entry| entry.fetch('name') }
selected_things = source_result.fetch('selections').first.fetch('targets')
henry = source_result.fetch('state').find { |entry| entry.fetch('name') == 'guard000' }
key = source_result.fetch('state').find { |entry| entry.fetch('name') == 'brass key' }
player = source_result.fetch('state').find { |entry| entry.fetch('name') == 'player' }

puts "BASIC# World-Save Stress Test v#{BasicSharp::VERSION}"
puts "Direct guards: #{DIRECT_GUARDS}"
puts "Inherited captains: #{CAPTAINS}"
puts "Things selected by every guard: #{TOTAL_SELECTED}"
puts "Saved Things: #{thing_names.length}"
puts "Replay events after restore: #{REPLAY_EVENTS}"
puts format('Source path seconds: %.3f', source_seconds)
puts format('Saved BSharp IR path seconds: %.3f', bsir_seconds)
assert_pass(source_runtime.program_fingerprint == bsir_runtime.program_fingerprint, 'Source and saved-BSIR fingerprint parity')
assert_pass(source_save_json == bsir_save_json, 'Byte-identical deterministic saves')
assert_pass(source_result.fetch('state') == bsir_result.fetch('state'), 'Source and saved-BSIR world parity')
assert_pass(selected_things.length == TOTAL_SELECTED, 'Direct and inherited Thing preservation')
assert_pass(thing_names == source_result.fetch('state').map { |entry| entry.fetch('name') }, 'Definition-order preservation')
assert_pass(henry.fetch('states') == ['angry'] && henry.dig('values', 'damage') == 3 && henry.dig('values', 'health') == 7, 'State and value preservation')
assert_pass(key.fetch('relations') == { 'carried by' => 'guard000' }, 'Relationship preservation')
assert_pass(player.dig('values', 'damage') == 2, 'Complete event-chain settlement before save')
assert_pass(source_save.dig('world', 'if_rules', 0, 'active') == true, 'IF-active preservation')
assert_pass(restored_source.startup_ran.empty? && restored_source.startup_follow_up_events.empty?, 'START and startup events do not rerun')
assert_pass(restored_source.snapshot == restored_bsir.snapshot, 'Restored source and saved-BSIR parity')
assert_pass(first_replay.fetch('state') == second_replay.fetch('state'), 'Deterministic replay after restore')

isolated = BasicSharp::Runtime.new(document, world_save: JSON.parse(source_save_json))
restored_source.run_event('guard000 attacks player')
assert_pass(isolated.snapshot != restored_source.snapshot, 'Separate runtime isolation')
assert_pass(!source_save.fetch('world').key?('pending_events'), 'No pending events in save')
puts 'WORLD-SAVE STRESS TEST: PASS'
