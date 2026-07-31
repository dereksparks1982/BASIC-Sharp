#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require 'benchmark'
require_relative '../compiler/parser'
require_relative '../compiler/resolver'
require_relative '../compiler/ir_emitter'
require_relative '../compiler/runtime'
require_relative '../compiler/world_save'
require_relative '../compiler/ask'

DIRECT_GUARDS = 512
CAPTAINS = 256
TOTAL_GUARDS = DIRECT_GUARDS + CAPTAINS
QUESTION_COUNT = 256


def assert_pass(condition, label)
  raise "#{label}: FAIL" unless condition

  puts "#{label}: PASS"
end


def resolve(source)
  parser = BasicSharp::Parser.new(source)
  document = BasicSharp::SemanticResolver.new(parser.parse, dictionary: parser.dictionary).resolve
  raise document.diagnostics.map(&:to_s).join("\n") unless document.error_count.zero?

  document
end

kind_lines = ['captain is a guard']
definitions = []
start_lines = []
DIRECT_GUARDS.times do |index|
  name = format('guard%03d', index)
  definitions << "a guard named #{name}"
  start_lines << "#{name} is calm"
  start_lines << "#{name} has 10 health"
end
CAPTAINS.times do |index|
  name = format('captain%03d', index)
  definitions << "a captain named #{name}"
  start_lines << "#{name} is calm"
  start_lines << "#{name} has 10 health"
end
definitions.concat(['a device named brass bell', 'a key named brass key', 'a table named oak table'])
start_lines << 'brass key is on oak table'

source = <<~BSHARP
  KINDS
  [#{kind_lines.join("\n")}].

  DEFINE
  [#{definitions.join("\n")}].

  START
  [#{start_lines.join("\n")}].

  WHEN
  [player attacks a guard
  <then> (damage that guard by 3
  <then> (cause that guard attacks player
  <then> (change that guard to angry].

  WHEN
  [a guard attacks player
  <then> (damage player].

  IF
  [guard000 has 3 damage
  <then> (change captain000 to angry].
BSHARP

document = resolve(source)
bsir = JSON.parse(BasicSharp::IREmitter.new(document).to_json)
source_runtime = BasicSharp::Runtime.new(document)
bsir_runtime = BasicSharp::Runtime.new(bsir)

questions = [
  'what is guard000',
  'what Kind is guard000',
  'what states does guard000 have',
  'what values does guard000 have',
  'what relationships does brass key have',
  'what Things are guards',
  'what happens when player attacks guard000',
  'what IF rules are true',
  'what is the world',
  'what is the save'
]
questions.concat(Array.new(QUESTION_COUNT - questions.length, 'what is guard000'))

source_answers = nil
source_seconds = Benchmark.realtime do
  source_answers = BasicSharp::Ask.new(source_runtime).answer_many(questions)
end
bsir_answers = nil
bsir_seconds = Benchmark.realtime do
  bsir_answers = BasicSharp::Ask.new(bsir_runtime).answer_many(questions)
end

source_before = source_runtime.snapshot
source_if_before = source_runtime.ask_if_rules
source_ready_before = source_runtime.save_ready?
inspector = BasicSharp::Ask.new(source_runtime)
source_json_one = inspector.to_json(source_answers)
source_json_two = inspector.to_json(inspector.answer_many(questions))
human = inspector.report(source_answers)

source_runtime.run_event('player attacks guard000')
save = BasicSharp::WorldSave.document_for(source_runtime)
restored = BasicSharp::Runtime.new(document, world_save: save)
post_questions = ['what is guard000', 'what IF rules are true']
source_post = BasicSharp::Ask.new(source_runtime).answer_many(post_questions)
restored_post = BasicSharp::Ask.new(restored).answer_many(post_questions)

membership = source_answers.find { |entry| entry.fetch('type') == 'kind_membership' }
event_answer = source_answers.find { |entry| entry.fetch('type') == 'event_match' }
world_answer = source_answers.find { |entry| entry.fetch('type') == 'world' }

puts "BASIC# ASK Stress Test v#{BasicSharp::VERSION}"
puts "Direct guards: #{DIRECT_GUARDS}"
puts "Inherited captains: #{CAPTAINS}"
puts "Things selected by guard membership: #{TOTAL_GUARDS}"
puts "ASK questions per command: #{QUESTION_COUNT}"
puts format('Source path seconds: %.3f', source_seconds)
puts format('Saved BSharp IR path seconds: %.3f', bsir_seconds)
assert_pass(source_answers == bsir_answers, 'Source and saved-BSIR answer parity')
assert_pass(membership.dig('answer', 'things').length == TOTAL_GUARDS, 'Complete direct and inherited Kind membership')
assert_pass(membership.dig('answer', 'things').first.fetch('name') == 'guard000', 'Definition-order membership')
assert_pass(membership.dig('answer', 'things').last.fetch('name') == 'captain255', 'Inherited membership order')
assert_pass(event_answer.dig('answer', 'matched_when') == 'player attacks a guard', 'Event-match inspection')
assert_pass(event_answer.dig('answer', 'actions').length == 3, 'Complete action inspection')
assert_pass(world_answer.dig('answer', 'things') == TOTAL_GUARDS + 4, 'World summary')
assert_pass(source_json_one == source_json_two, 'Byte-identical deterministic ASK JSON')
assert_pass(JSON.parse(source_json_one).fetch('answers').length == QUESTION_COUNT, 'Complete 256-question JSON')
assert_pass(human.include?('...and 718 more Things.'), 'Bounded human Kind output')
assert_pass(human.include?('Use --ask-json for the complete result.'), 'Complete-output guidance')
assert_pass(source_before == BasicSharp::Runtime.new(document).snapshot, 'ASK world non-mutation')
assert_pass(source_if_before == BasicSharp::Runtime.new(document).ask_if_rules, 'ASK IF-state non-mutation')
assert_pass(source_ready_before == true, 'ASK save-readiness preservation')
assert_pass(source_post == restored_post, 'Restored-save answer parity')
assert_pass(restored.ask_world_summary.fetch('origin') == 'BSharp Save', 'BSharp Save origin explanation')
assert_pass(BasicSharp::Runtime.new(document).snapshot != source_runtime.snapshot, 'Separate runtime isolation')
puts 'ASK STRESS TEST: PASS'
