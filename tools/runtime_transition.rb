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
FIXTURE = JSON.parse(File.read(File.join(ROOT, 'spec/runtime_v1/BASIC_SHARP_PREFERRED_RUNTIME_FIXTURES_v1.json'), encoding: 'UTF-8'))
COMPILER = File.join(ROOT, 'compiler/basic_sharp.rb')

module PreferredRuntimeAudit
  module_function

  def assert!(condition, label)
    raise "#{label}: FAIL" unless condition
  end

  def resolve(path)
    parser = BasicSharp::Parser.new(File.read(path, encoding: 'UTF-8'))
    resolved = BasicSharp::SemanticResolver.new(parser.parse, dictionary: parser.dictionary).resolve
    raise "#{path} has diagnostics" if resolved.error_count.positive? || resolved.warning_count.positive?

    resolved
  end

  def source_document(entry)
    resolve(File.join(ROOT, entry.fetch('source')))
  end

  def bsir_document(entry)
    JSON.parse(File.read(File.join(ROOT, entry.fetch('bsir')), encoding: 'UTF-8'))
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
direct_bsbc = bsbc_status.success? && bsbc_err.empty? &&
              bsbc_out.include?("BSharp Virtual Machine v#{BasicSharp::VERSION}")

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
                   reference_machine.report(reference_result).include?("BASIC# Runtime v#{BasicSharp::VERSION}")

default_independence = begin
  singleton = BasicSharp::Runtime.singleton_class
  singleton.define_method(:new) { |*| raise 'reference runtime called' }
  begin
    PreferredRuntimeAudit.transition(first).run_event('player attacks cinder').fetch('matched')
  ensure
    singleton.remove_method(:new)
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

text_source = File.join(ROOT, 'samples/text_values.bsharp')
text_machine = PreferredRuntimeAudit.transition(
  { 'source' => 'samples/text_values.bsharp' },
  mode: :verify,
  document: PreferredRuntimeAudit.resolve(text_source)
)
text_result = text_machine.run_event('player sounds brass bell')
text_profile_shadow = text_result.fetch('matched') && text_result['error'].nil? &&
                      text_machine.meaning_profile == 'bsharp.meaning.v2' &&
                      text_machine.snapshot.any? { |entry| entry.dig('values', 'title') == 'OPEN — RubyVM!' }

game_source = File.join(ROOT, 'samples/demon_killer_controls.bsharp')
game_machine = PreferredRuntimeAudit.transition({ 'source' => 'samples/demon_killer_controls.bsharp' }, mode: :verify, document: PreferredRuntimeAudit.resolve(game_source))
game_profile_shadow = game_machine.meaning_profile == 'bsharp.meaning.v3' && game_machine.game_declarations.fetch('controls').length == 1

platform_source = File.join(ROOT, 'samples/platform_movement.bsharp')
platform_machine = PreferredRuntimeAudit.transition(
  { 'source' => 'samples/platform_movement.bsharp' },
  mode: :verify,
  document: PreferredRuntimeAudit.resolve(platform_source)
)
platform_profile_shadow = platform_machine.meaning_profile == 'bsharp.meaning.v4' &&
                          platform_machine.game_declarations.fetch('controls').fetch(0).fetch('instructions').length == 3

number_source = File.join(ROOT, 'samples/number_changes.bsharp')
number_machine = PreferredRuntimeAudit.transition(
  { 'source' => 'samples/number_changes.bsharp' },
  mode: :verify,
  document: PreferredRuntimeAudit.resolve(number_source)
)
number_results = ['player takes gold coin', 'player attacks spikes', 'player attacks bow'].map do |event|
  number_machine.run_event(event)
end
number_profile_shadow = number_results.all? { |result| result.fetch('matched') && result['error'].nil? } &&
                        number_machine.meaning_profile == 'bsharp.meaning.v5' &&
                        number_machine.loader.model.fetch(:profile) == 'bsharp.bytecode.v5'

compound_source = File.join(ROOT, 'samples/compound_if_conditions.bsharp')
compound_machine = PreferredRuntimeAudit.transition(
  { 'source' => 'samples/compound_if_conditions.bsharp' },
  mode: :verify,
  document: PreferredRuntimeAudit.resolve(compound_source)
)
compound_results = ['player takes coin', 'player takes coin', 'player attacks boss', 'player speaks boss', 'player attacks boss', 'player attacks bridge'].map do |event|
  compound_machine.run_event(event)
end
compound_profile_shadow = compound_results.all? { |result| result.fetch('matched') && result['error'].nil? } &&
                          compound_machine.meaning_profile == 'bsharp.meaning.v6' &&
                          compound_machine.loader.model.fetch(:profile) == 'bsharp.bytecode.v6' &&
                          compound_machine.ask_if_rules.count { |entry| entry.fetch('active') } == 2

otherwise_source = File.join(ROOT, 'samples/otherwise_branches.bsharp')
otherwise_machine = PreferredRuntimeAudit.transition(
  { 'source' => 'samples/otherwise_branches.bsharp' },
  mode: :verify,
  document: PreferredRuntimeAudit.resolve(otherwise_source)
)
otherwise_results = ['player attacks switch', 'player attacks switch', 'player speaks switch'].map do |event|
  otherwise_machine.run_event(event)
end
otherwise_profile_shadow = otherwise_results.all? { |result| result.fetch('matched') && result['error'].nil? } &&
                           otherwise_machine.meaning_profile == 'bsharp.meaning.v7' &&
                           otherwise_machine.loader.model.fetch(:profile) == 'bsharp.bytecode.v7' &&
                           otherwise_machine.ask_if_rules.first.fetch('branch') == 'OTHERWISE'

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
  'Deterministic repeated execution' => deterministic,
  'Meaning Profile 2 text shadow parity' => text_profile_shadow,
  'Meaning Profile 3 game shadow parity' => game_profile_shadow,
  'Meaning Profile 4 platform shadow parity' => platform_profile_shadow,
  'Meaning Profile 5 number-change shadow parity' => number_profile_shadow,
  'Meaning Profile 6 compound IF shadow parity' => compound_profile_shadow,
  'Meaning Profile 7 IF and OTHERWISE shadow parity' => otherwise_profile_shadow
}

checks.each { |label, passed| PreferredRuntimeAudit.assert!(passed, label) }

puts "BASIC# Preferred Runtime Transition v#{BasicSharp::VERSION}"
puts "Sample programs: #{FIXTURE.fetch('samples').length}"
puts "Valid Meaning Profile cases: #{FIXTURE.fetch('meaning_cases').length}"
puts
checks.each_key { |label| puts "#{label}: PASS" }
puts
puts 'PREFERRED RUNTIME TRANSITION: PASS'
