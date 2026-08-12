#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require_relative '../compiler/small_compiler_subset_pipeline'
require_relative '../compiler/lexer'
require_relative '../compiler/parser'
require_relative '../compiler/resolver'
require_relative '../compiler/bytecode_emitter'
require_relative '../compiler/bytecode_loader'
require_relative '../compiler/bytecode_virtual_machine'
require_relative '../compiler/runtime'
require_relative '../compiler/world_save'

ROOT = File.expand_path('..', __dir__)
SPEC_PATH = File.join(ROOT, 'spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_PIPELINE_INDEPENDENCE_v1.json')
spec = JSON.parse(File.read(SPEC_PATH, encoding: 'UTF-8'))

def assert_contract!(condition, message)
  raise "Small compiler subset pipeline independence failed: #{message}" unless condition
end

def normalize(value)
  BasicSharp::SmallCompilerSubsetPipeline.normalize(value)
end

def semantic(value)
  case value
  when Hash
    value.each_with_object({}) do |(key, child), result|
      key = key.to_s
      next if %w[line_number caused_by_line].include?(key)
      result[key] = semantic(child)
    end.sort.to_h
  when Array then value.map { |child| semantic(child) }
  else value
  end
end

assert_contract!(spec.fetch('format') == 'bsharp.small_compiler_subset.pipeline_independence.contract.json', 'wrong spec identity')
assert_contract!(spec.fetch('format_version') == 1, 'wrong format version')
assert_contract!(spec.fetch('target_version') == BasicSharp::VERSION, 'target version mismatch')
assert_contract!(spec.fetch('status') == 'integrated_independent_pipeline_under_ruby_referee', 'status changed')

pipeline_source = File.read(File.join(ROOT, 'compiler/small_compiler_subset_pipeline.rb'), encoding: 'UTF-8')
assert_contract!(!pipeline_source.include?("require_relative 'bytecode_emitter'"), 'pipeline requires production BytecodeEmitter')
assert_contract!(!pipeline_source.include?("require_relative 'bytecode_virtual_machine'"), 'pipeline requires production BytecodeVirtualMachine')
assert_contract!(!pipeline_source.match?(/\bBytecodeEmitter\.new\b/), 'pipeline calls production BytecodeEmitter')
assert_contract!(!pipeline_source.match?(/\bBytecodeLoader\.new\b/), 'pipeline calls production BytecodeLoader')
assert_contract!(!pipeline_source.match?(/\bBytecodeVirtualMachine\.new\b/), 'pipeline calls production BytecodeVirtualMachine')
assert_contract!(!pipeline_source.match?(/\bRuntime\.new\b/), 'pipeline calls production Runtime')

fixture = spec.fetch('fixture')
source = File.read(File.join(ROOT, fixture.fetch('source_path')), encoding: 'UTF-8')
pipeline = BasicSharp::SmallCompilerSubsetPipeline.new(source)
record = pipeline.compile_record
assert_contract!(record.fetch(:profile) == fixture.fetch('expected_profile'), 'fixture profile changed')
assert_contract!(record.fetch(:reader_record_count) == fixture.fetch('expected_reader_record_count'), 'reader record count changed')
assert_contract!(record.fetch(:statement_count) == fixture.fetch('expected_statement_count'), 'statement count changed')
assert_contract!(record.fetch(:binary_bytes) == fixture.fetch('expected_binary_bytes'), 'binary byte count changed')
assert_contract!(record.fetch(:binary_sha256) == fixture.fetch('expected_binary_sha256'), 'binary digest changed')
assert_contract!(record.fetch(:disassembly_sha256) == fixture.fetch('expected_disassembly_sha256'), 'disassembly digest changed')
assert_contract!(record.fetch(:bsharp_ir_sha256) == fixture.fetch('expected_bsharp_ir_sha256'), 'BSharp IR digest changed')
assert_contract!(record.fetch(:fingerprint) == fixture.fetch('expected_fingerprint'), 'fingerprint changed')
assert_contract!(record.fetch(:loader_summary_sha256) == fixture.fetch('expected_loader_summary_sha256'), 'loader summary changed')

# Primary reader path must work with the production Lexer constructor disabled.
lexer_singleton = BasicSharp::Lexer.singleton_class
lexer_singleton.class_eval do
  alias_method :__v078_pipeline_original_new, :new
  define_method(:new) { |*| raise 'production Lexer invoked from primary reader path' }
end
begin
  isolated_reader = BasicSharp::TokenizerReader.new(source)
  assert_contract!(isolated_reader.reader_records.length == fixture.fetch('expected_reader_record_count'), 'independent reader failed with production Lexer disabled')
ensure
  lexer_singleton.class_eval do
    alias_method :new, :__v078_pipeline_original_new
    remove_method :__v078_pipeline_original_new
  end
end

# Primary source-to-world path must survive with every production constructor disabled.
classes = [
  BasicSharp::Lexer,
  BasicSharp::Parser,
  BasicSharp::SemanticResolver,
  BasicSharp::BytecodeEmitter,
  BasicSharp::BytecodeLoader,
  BasicSharp::BytecodeVirtualMachine,
  BasicSharp::Runtime
]
aliases = []
begin
  classes.each_with_index do |klass, index|
    singleton = klass.singleton_class
    alias_name = "__v078_pipeline_gate_original_new_#{index}".to_sym
    singleton.class_eval do
      alias_method alias_name, :new
      define_method(:new) { |*| raise "production constructor invoked: #{klass}" }
    end
    aliases << [singleton, alias_name]
  end
  isolated = BasicSharp::SmallCompilerSubsetPipeline.new(source)
  assert_contract!(BasicSharp::SmallCompilerSubsetPipeline.digest_binary(isolated.binary) == fixture.fetch('expected_binary_sha256'), 'isolated pipeline binary changed')
  assert_contract!(isolated.run_event(fixture.fetch('events').first).fetch('matched'), 'isolated pipeline could not execute fixture event')
ensure
  aliases.reverse_each do |singleton, alias_name|
    singleton.class_eval do
      alias_method :new, alias_name
      remove_method alias_name
    end
  end
end

# Separate production and Ruby referee comparisons.
parser = BasicSharp::Parser.new(source)
document = BasicSharp::SemanticResolver.new(parser.parse, dictionary: parser.dictionary).resolve.to_h
production_emitter = BasicSharp::BytecodeEmitter.new(document)
production_loader = BasicSharp::BytecodeLoader.new(production_emitter.binary, expected_fingerprint: production_emitter.fingerprint)
production_vm = BasicSharp::BytecodeVirtualMachine.new(production_loader)
ruby_runtime = BasicSharp::Runtime.new(document)

assert_contract!(normalize(document) == normalize(pipeline.bsharp_ir), 'BSharp IR differs from production semantic referee')
assert_contract!(production_emitter.binary == pipeline.binary, 'BSBC bytes differ from production emitter referee')
assert_contract!(normalize(production_loader.summary) == normalize(pipeline.loader.summary), 'loader summary differs from production loader referee')

independent_results = fixture.fetch('events').map { |event| pipeline.run_event(event) }
production_results = fixture.fetch('events').map { |event| production_vm.run_event(event) }
ruby_results = fixture.fetch('events').map { |event| ruby_runtime.run_event(event) }
assert_contract!(normalize(production_results) == normalize(independent_results), 'event results differ from production VM referee')
assert_contract!(semantic(ruby_results) == semantic(independent_results), 'event semantics differ from Ruby runtime referee')
assert_contract!(normalize(production_vm.snapshot) == normalize(pipeline.snapshot), 'final world differs from production VM referee')
assert_contract!(normalize(ruby_runtime.snapshot) == normalize(pipeline.snapshot), 'final world differs from Ruby runtime referee')
assert_contract!(BasicSharp::SmallCompilerSubsetPipeline.digest_json(independent_results) == fixture.fetch('expected_event_results_sha256'), 'event-result digest changed')
assert_contract!(BasicSharp::SmallCompilerSubsetPipeline.digest_json(pipeline.snapshot) == fixture.fetch('expected_final_snapshot_sha256'), 'final-world digest changed')
assert_contract!(BasicSharp::SmallCompilerSubsetPipeline.digest_json(pipeline.save_document) == fixture.fetch('expected_save_document_sha256'), 'Save digest changed')

replay = spec.fetch('deterministic_replay')
replay_pipeline = BasicSharp::SmallCompilerSubsetPipeline.new(source)
replay_results = Array.new(replay.fetch('event_count')) { replay_pipeline.run_event(replay.fetch('event')) }
assert_contract!(BasicSharp::SmallCompilerSubsetPipeline.digest_json(replay_results) == replay.fetch('expected_event_results_sha256'), 'deterministic replay event digest changed')
assert_contract!(BasicSharp::SmallCompilerSubsetPipeline.digest_json(replay_pipeline.snapshot) == replay.fetch('expected_final_snapshot_sha256'), 'deterministic replay world digest changed')

self_hosting = JSON.parse(File.read(File.join(ROOT, 'spec/self_hosting/BASIC_SHARP_SELF_HOSTING_SUBSET_v1.json'), encoding: 'UTF-8'))
assert_contract!(self_hosting.fetch('approved_profiles_available_to_creator_programs').length == 7, 'Profiles 1-7 surface changed')
assert_contract!(!JSON.generate(self_hosting.fetch('approved_profiles_available_to_creator_programs')).include?('v8'), 'Profile 8 appeared')

references = [
  'README.md',
  'docs/roadmap/BASIC_SHARP_ROADMAP.md',
  'docs/hand_off/BASIC_SHARP_MASTER_THREAD_HANDOFF.md',
  'docs/company_bible/BASIC_SHARP_COMPANY_BIBLE.md',
  'spec/self_hosting/BASIC_SHARP_SELF_HOSTING_SUBSET_v1.json'
]
references.each do |relative|
  text = File.read(File.join(ROOT, relative), encoding: 'UTF-8')
  assert_contract!(text.include?('spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_PIPELINE_INDEPENDENCE_v1.json'), "#{relative} does not reference pipeline independence spec")
end

puts "BASIC# Small Compiler Subset Integrated Independent Compiler Pipeline v#{BasicSharp::VERSION}"
puts 'Independent source-to-world pipeline: PASS'
puts 'TokenizerReader primary path independent from production Lexer: PASS'
puts 'Reader -> parser -> semantic resolver -> BSharp IR: PASS'
puts 'BSharp IR -> independent BSBC encoder: PASS'
puts 'BSBC -> independent loader -> independent BSharp VM: PASS'
puts 'Production compiler components used only as separate referees: PASS'
puts 'Ruby runtime used only as separate referee: PASS'
puts 'Exact BSharp IR and BSBC parity: PASS'
puts 'Exact event-result and final-world parity: PASS'
puts "Deterministic replay parity: PASS (#{replay.fetch('event_count')} events)"
puts 'Profiles 1-7 remain unchanged: PASS'
puts 'SMALL COMPILER SUBSET INTEGRATED INDEPENDENT PIPELINE: PASS'
