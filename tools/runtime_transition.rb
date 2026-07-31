#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require 'open3'
require 'rbconfig'
require 'tmpdir'
require_relative '../compiler/parser'
require_relative '../compiler/resolver'
require_relative '../compiler/runtime'
require_relative '../compiler/world_save'
require_relative '../compiler/ask'
require_relative '../compiler/runtime_transition'

ROOT = File.expand_path('..', __dir__)
FIXTURE = JSON.parse(File.read(File.join(ROOT, 'spec/runtime_v1/BASIC_SHARP_PREFERRED_RUNTIME_FIXTURES_v1.json')))
COMPILER = File.join(ROOT, 'compiler/basic_sharp.rb')

module PreferredRuntimeAudit
  module_function

  def assert!(condition, label)
    raise "#{label}: FAIL" unless condition
  end

  def resolve(path)
    parser = BasicSharp::Parser.new(File.read(path))
    resolved = BasicSharp::SemanticResolver.new(parser.parse, dictionary: parser.dictionary).resolve
    raise "#{path} has diagnostics" if resolved.error_count.positive? || resolved.warning_count.positive?

    resolved
  end

  def source_document(entry)
    resolve(File.join(ROOT, entry.fetch('source')))
  end

  def bsir_document(entry)
    JSON.parse(File.read(File.join(ROOT, entry.fetch('bsir'))))
  end

  def transition(entry, mode: :preferred, document: nil, world_save: nil)
    BasicSharp::RuntimeTransition.new(
      document || source_document(entry),
      mode: mode,
      world_save: world_save
    )
  end

  def cli(*arguments)
    Open3.capture3(RbConfig.ruby, COMPILER, *arguments, chdir: ROOT)
  end
end

first = FIXTURE.fetch('samples').find { |entry| entry.fetch('name') == 'first_room' }
ask_demo = FIXTURE.fetch('samples').find { |entry| entry.fetch('name') == 'ask_demo' }
world_save = FIXTURE.fetch('samples').find { |entry| entry.fetch('name') == 'world_save_demo' }

source_machine = PreferredRuntimeAudit.transition(first)
source_result = source_machine.run_event('player attacks cinder')
source_default = source_machine.preferred? && source_result.fetch('matched') &&
                 source_machine.report(source_result).include?('BSharp Virtual Machine')

bsir_machine = PreferredRuntimeAudit.transition(first, document: PreferredRuntimeAudit.bsir_document(first))
bsir_result = bsir_machine.run_event('player attacks cinder')
bsir_default = bsir_machine.preferred? && bsir_result.fetch('matched') &&
               bsir_machine.snapshot == source_machine.snapshot

bsbc_out, bsbc_err, bsbc_status = PreferredRuntimeAudit.cli(
  File.join(ROOT, 'samples/first_room.bsbc'), '--run', 'player attacks cinder'
)
direct_bsbc = bsbc_status.success? && bsbc_err.empty? && bsbc_out.include?('BSharp Virtual Machine v0.1.31')

in_memory = source_machine.loader.is_a?(BasicSharp::BytecodeLoader) &&
            source_machine.loader.source_label == '(in-memory preferred runtime bytecode)' &&
            source_machine.loader.model.frozen?

no_leakage = Dir.mktmpdir do |dir|
  before = Dir.children(dir)
  Dir.chdir(dir) { PreferredRuntimeAudit.transition(first).run_event('player attacks cinder') }
  before == Dir.children(dir)
end

reference_machine = PreferredRuntimeAudit.transition(first, mode: :reference)
reference_result = reference_machine.run_event('player attacks cinder')
reference_opt_in = reference_machine.reference? && reference_machine.loader.nil? &&
                   reference_machine.report(reference_result).include?('BASIC# Runtime v0.1.31')

default_independence = begin
  singleton = BasicSharp::Runtime.singleton_class
  singleton.alias_method(:__preferred_runtime_original_new, :new)
  singleton.define_method(:new) { |*| raise 'reference runtime called' }
  begin
    PreferredRuntimeAudit.transition(first).run_event('player attacks cinder').fetch('matched')
  ensure
    singleton.alias_method(:new, :__preferred_runtime_original_new)
    singleton.remove_method(:__preferred_runtime_original_new)
  end
rescue StandardError
  false
end

startup_shadow = true
event_shadow = true
world_shadow = true
if_shadow = true
follow_up_shadow = true
FIXTURE.fetch('samples').each do |entry|
  machine = PreferredRuntimeAudit.transition(entry, mode: :verify)
  startup_shadow &&= machine.startup_if_error.nil?
  entry.fetch('events').each do |event|
    result = machine.run_event(event)
    event_shadow &&= result.fetch('matched') && result['error'].nil?
    follow_up_shadow &&= result.fetch('follow_up_events', []).is_a?(Array)
  end
  world_shadow &&= machine.snapshot.is_a?(Array) && machine.save_ready?
  if_shadow &&= machine.ask_if_rules.is_a?(Array)
end

ask_machine = PreferredRuntimeAudit.transition(ask_demo, mode: :verify)
ask_machine.run_event('player attacks henry')
ask_before = ask_machine.snapshot
ask_ready = ask_machine.save_ready?
answers = BasicSharp::Ask.new(ask_machine).answer_many(FIXTURE.fetch('ask_questions'))
ask_shadow = answers.length == FIXTURE.fetch('ask_questions').length &&
             ask_machine.snapshot == ask_before && ask_machine.save_ready? == ask_ready

save_machine = PreferredRuntimeAudit.transition(world_save, mode: :verify)
save_machine.run_event('player attacks henry')
save_document = BasicSharp::WorldSave.document_for(save_machine)
save_shadow = save_document.fetch('world').fetch('settled') == true &&
              save_document.fetch('program_fingerprint').fetch('value') == save_machine.program_fingerprint

restored = PreferredRuntimeAudit.transition(world_save, mode: :verify, world_save: save_document)
restore_shadow = restored.snapshot == save_machine.snapshot && restored.startup_ran.empty?
save_machine.run_event('player attacks henry')
restored.run_event('player attacks henry')
restore_shadow &&= restored.snapshot == save_machine.snapshot

mismatch_detection = begin
  mismatch = PreferredRuntimeAudit.transition(first, mode: :verify)
  reference = mismatch.instance_variable_get(:@reference_machine)
  original = reference.method(:snapshot)
  reference.define_singleton_method(:snapshot) { original.call + [{ 'name' => 'parity intruder' }] }
  mismatch.snapshot
  false
rescue BasicSharp::RuntimeTransitionError => error
  error.message.include?('BSharp VM and reference runtime disagreed') &&
    error.message.include?('not allowed to continue')
end

replay_a = PreferredRuntimeAudit.transition(first)
replay_b = PreferredRuntimeAudit.transition(first)
100.times do
  replay_a.run_event('player attacks cinder')
  replay_b.run_event('player attacks cinder')
end
deterministic = replay_a.snapshot == replay_b.snapshot &&
                BasicSharp::WorldSave.document_for(replay_a) == BasicSharp::WorldSave.document_for(replay_b)

checks = {
  'Source defaults to BSharp VM' => source_default,
  'BSIR defaults to BSharp VM' => bsir_default,
  'Direct BSBC remains BSharp VM' => direct_bsbc,
  'In-memory bytecode pipeline' => in_memory,
  'No temporary artifact leakage' => no_leakage,
  'Reference-runtime opt-in' => reference_opt_in,
  'Default-path runtime independence' => default_independence,
  'Startup shadow parity' => startup_shadow,
  'Event-result shadow parity' => event_shadow,
  'World-state shadow parity' => world_shadow,
  'Reactive IF shadow parity' => if_shadow,
  'Follow-up-event shadow parity' => follow_up_shadow,
  'ASK shadow parity' => ask_shadow,
  'Save shadow parity' => save_shadow,
  'Restore and replay shadow parity' => restore_shadow,
  'Mismatch detection' => mismatch_detection,
  'Deterministic repeated execution' => deterministic
}

checks.each { |label, passed| PreferredRuntimeAudit.assert!(passed, label) }

puts 'BASIC# Preferred Runtime Transition v0.1.31'
puts "Sample programs: #{FIXTURE.fetch('samples').length}"
puts "Valid Meaning Profile cases: #{FIXTURE.fetch('meaning_cases').length}"
puts
checks.each_key { |label| puts "#{label}: PASS" }
puts
puts 'PREFERRED RUNTIME TRANSITION: PASS'
