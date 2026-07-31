#!/usr/bin/env ruby
# frozen_string_literal: true

require 'digest'
require 'json'
require_relative '../compiler/parser'
require_relative '../compiler/resolver'
require_relative '../compiler/runtime'
require_relative '../compiler/runtime_transition'
require_relative '../compiler/ask'
require_relative '../compiler/world_save'
require_relative '../compiler/bytecode_emitter'
require_relative '../compiler/bytecode_loader'
require_relative '../compiler/bytecode_virtual_machine'

ROOT = File.expand_path('..', __dir__)
FIXTURE = JSON.parse(File.read(File.join(ROOT, 'spec/runtime_v2/BASIC_SHARP_TEXT_VALUE_RUNTIME_FIXTURES_v1.json')))
EVENT_COUNT = Integer(ENV.fetch('TEXT_VALUE_EVENTS', '10000'), 10)
RESTORE_COUNT = Integer(ENV.fetch('TEXT_VALUE_RESTORES', '100'), 10)
PARITY_COUNT = Integer(ENV.fetch('TEXT_VALUE_PARITY_EVENTS', '25'), 10)

raise 'TEXT_VALUE_EVENTS must be from 1 through 100000' unless EVENT_COUNT.between?(1, 100_000)
raise 'TEXT_VALUE_RESTORES must be from 1 through 1000' unless RESTORE_COUNT.between?(1, 1_000)
raise 'TEXT_VALUE_PARITY_EVENTS must be from 1 through 100' unless PARITY_COUNT.between?(1, 100)

def assert!(condition, label)
  raise "#{label}: FAIL" unless condition
end

def resolve(path)
  parser = BasicSharp::Parser.new(File.read(path, encoding: 'UTF-8'))
  document = BasicSharp::SemanticResolver.new(parser.parse, dictionary: parser.dictionary).resolve
  raise "#{path} has diagnostics" if document.error_count.positive? || document.warning_count.positive?

  document
end

def hash_json(value)
  Digest::SHA256.hexdigest(JSON.generate(value))
end

sample = FIXTURE.fetch('sample')
source_document = resolve(File.join(ROOT, sample.fetch('source')))
bsir_document = JSON.parse(File.read(File.join(ROOT, sample.fetch('bsir')), encoding: 'UTF-8'))
loader = BasicSharp::BytecodeLoader.read(File.join(ROOT, sample.fetch('bytecode')))
event = FIXTURE.fetch('events').first
expected = FIXTURE.fetch('expected')

source_machine = BasicSharp::RuntimeTransition.new(source_document)
bsir_machine = BasicSharp::RuntimeTransition.new(bsir_document)
bytecode_machine = BasicSharp::BytecodeVirtualMachine.new(loader)
reference_machine = BasicSharp::Runtime.new(source_document)

EVENT_COUNT.times do
  source_machine.run_event(event)
  bsir_machine.run_event(event)
  bytecode_machine.run_event(event)
  reference_machine.run_event(event)
end

assert!(source_machine.snapshot == bsir_machine.snapshot, 'Source and BSIR text parity')
assert!(source_machine.snapshot == bytecode_machine.snapshot, 'Source and bytecode text parity')
assert!(source_machine.snapshot == reference_machine.snapshot, 'Preferred and reference text parity')
assert!(source_machine.program_fingerprint == expected.fetch('program_fingerprint'), 'Program fingerprint')

parity_machine = BasicSharp::RuntimeTransition.new(source_document, mode: :verify)
PARITY_COUNT.times { parity_machine.run_event(event) }
assert!(parity_machine.snapshot == source_machine.snapshot, 'Shadow parity text world')

save_source = BasicSharp::RuntimeTransition.new(source_document, mode: :verify)
save_source.run_event(event)
save_document = BasicSharp::WorldSave.document_for(save_source)
RESTORE_COUNT.times do
  restored = BasicSharp::RuntimeTransition.new(source_document, world_save: save_document, mode: :verify)
  assert!(restored.snapshot == save_source.snapshot, 'Typed Save restore parity')
  restored.run_event(event)
  assert!(restored.snapshot == save_source.snapshot, 'Typed Save replay determinism')
end

questions = FIXTURE.fetch('ask_questions')
ask_before = save_source.snapshot
answers = BasicSharp::Ask.new(save_source).answer_many(questions)
assert!(answers.length == questions.length, 'ASK answer count')
assert!(save_source.snapshot == ask_before, 'ASK read-only text world')

single = BasicSharp::RuntimeTransition.new(source_document, mode: :verify)
assert!(hash_json(single.snapshot) == expected.fetch('startup_snapshot_sha256'), 'Startup fixture hash')
single_result = single.run_event(event)
assert!(hash_json(single_result) == expected.fetch('event_result_sha256'), 'Event fixture hash')
assert!(hash_json(single.snapshot) == expected.fetch('final_snapshot_sha256'), 'Final fixture hash')
single_answers = BasicSharp::Ask.new(single).answer_many(questions)
assert!(hash_json(single_answers) == expected.fetch('ask_answers_sha256'), 'ASK fixture hash')
single_save = BasicSharp::WorldSave.document_for(single)
assert!(hash_json(single_save) == expected.fetch('save_document_sha256'), 'Save fixture hash')

puts 'BASIC# Creator-Facing Text Value Stress v0.1.32'
puts "Events per runtime path: #{EVENT_COUNT}"
puts "Shadow-parity events: #{PARITY_COUNT}"
puts "Typed Save restore cycles: #{RESTORE_COUNT}"
puts "ASK questions: #{questions.length}"
puts
puts 'Source and BSIR text parity: PASS'
puts 'Source and bytecode text parity: PASS'
puts 'Preferred and reference text parity: PASS'
puts 'Shadow parity: PASS'
puts 'Typed Save restore and replay: PASS'
puts 'ASK read-only behavior: PASS'
puts 'Deterministic fixture hashes: PASS'
puts
puts 'TEXT VALUE STRESS: PASS'
