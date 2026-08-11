#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require_relative '../compiler/small_compiler_subset_ir_emitter'
require_relative '../compiler/small_compiler_subset_semantic_resolver'

ROOT = File.expand_path('..', __dir__)
SPEC_PATH = File.join(ROOT, 'spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_SEMANTIC_RESOLVER_v1.json')
IR_SPEC_PATH = File.join(ROOT, 'spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_IR_EMITTER_v1.json')
DOC_PATH = File.join(ROOT, 'docs/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_SEMANTIC_RESOLVER_v0_1_74.md')
IMPLEMENTATION_PATH = File.join(ROOT, 'compiler/small_compiler_subset_semantic_resolver.rb')
EMITTER_PATH = File.join(ROOT, 'compiler/small_compiler_subset_ir_emitter.rb')

spec = JSON.parse(File.read(SPEC_PATH, encoding: 'UTF-8'))
ir_spec = JSON.parse(File.read(IR_SPEC_PATH, encoding: 'UTF-8'))

def assert_contract!(condition, message)
  raise "Small compiler subset semantic resolver failed: #{message}" unless condition
end

def fixture_source(entry, ir_spec)
  if entry['source_path']
    File.read(File.join(ROOT, entry.fetch('source_path')), encoding: 'UTF-8')
  else
    fixture = ir_spec.fetch('fixtures').find { |candidate| candidate.fetch('name') == entry.fetch('name') }
    raise "missing IR emitter fixture #{entry.fetch('name')}" unless fixture
    fixture.fetch('source')
  end
end

assert_contract!(spec.fetch('format') == 'bsharp.small_compiler_subset.semantic_resolver.contract.json', 'wrong spec identity')
assert_contract!(spec.fetch('format_version') == 1, 'wrong format version')
assert_contract!(spec.fetch('target_version') == BasicSharp::VERSION, 'target version does not match BasicSharp::VERSION')
assert_contract!(spec.fetch('status') == 'semantic_resolver_independent_under_ruby_referee', 'status changed')
assert_contract!(File.file?(IMPLEMENTATION_PATH), 'semantic resolver implementation is missing')
assert_contract!(File.file?(DOC_PATH), 'semantic resolver document is missing')

implementation = File.read(IMPLEMENTATION_PATH, encoding: 'UTF-8')
emitter_source = File.read(EMITTER_PATH, encoding: 'UTF-8')
assert_contract!(!implementation.match?(/\bSemanticResolver\.new\b/), 'independent resolver calls production SemanticResolver')
assert_contract!(!implementation.include?("require_relative 'resolver'"), 'independent resolver requires production resolver.rb')
assert_contract!(emitter_source.include?('SmallCompilerSubsetSemanticResolver.new(program, dictionary: dictionary).resolve'), 'subset IR emitter does not use the independent resolver')
assert_contract!(emitter_source.include?('SemanticResolver.new(ruby_program, dictionary: parser.dictionary).resolve'), 'separate Ruby referee resolver path is missing')

spec.fetch('fixtures').each do |entry|
  source = fixture_source(entry, ir_spec)
  emitter = BasicSharp::SmallCompilerSubsetIREmitter.new(source)
  assert_contract!(emitter.parser_matches_ruby_referee?, "#{entry.fetch('name')} parser differs from Ruby referee")
  assert_contract!(emitter.ir_matches_ruby_referee?, "#{entry.fetch('name')} IR differs from Ruby referee")
end

object_source = fixture_source(spec.fetch('fixtures').find { |entry| entry.fetch('name') == 'v074_object_interaction_independence' }, ir_spec)
object_ir = BasicSharp::SmallCompilerSubsetIREmitter.new(object_source).bsharp_ir
resolved_actions = object_ir.fetch(:events).flat_map { |event| event.fetch('then') }.map { |action| action.fetch('action') }
assert_contract!(resolved_actions.count('change') >= 3, 'open close lock did not canonicalize to change actions')
assert_contract!(resolved_actions.include?('carry'), 'take did not canonicalize to carry')

semantic_resolver_class = BasicSharp::SemanticResolver
semantic_resolver_class.class_eval do
  alias_method :__v074_original_resolve, :resolve
  define_method(:resolve) { raise 'production SemanticResolver called from independent path' }
end
begin
  isolated = BasicSharp::SmallCompilerSubsetIREmitter.new(object_source)
  isolated.document
ensure
  semantic_resolver_class.class_eval do
    alias_method :resolve, :__v074_original_resolve
    remove_method :__v074_original_resolve
  end
end

references = [
  'README.md',
  'docs/roadmap/BASIC_SHARP_ROADMAP.md',
  'docs/hand_off/BASIC_SHARP_MASTER_THREAD_HANDOFF.md',
  'docs/company_bible/BASIC_SHARP_COMPANY_BIBLE.md',
  'spec/self_hosting/BASIC_SHARP_SELF_HOSTING_SUBSET_v1.json',
  'spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_IR_EMITTER_v1.json'
]
references.each do |relative|
  text = File.read(File.join(ROOT, relative), encoding: 'UTF-8')
  assert_contract!(text.include?('spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_SEMANTIC_RESOLVER_v1.json'), "#{relative} does not reference the semantic resolver spec")
end

puts "BASIC# Small Compiler Subset Semantic Resolver v#{BasicSharp::VERSION}"
puts "Fixtures: #{spec.fetch('fixtures').length}"
puts 'Subset resolver builds its own semantic result: PASS'
puts 'Production resolver used only as referee: PASS'
puts 'Exact IR parity: PASS'
puts 'v0.1.73 object interaction parity: PASS'
puts 'SMALL COMPILER SUBSET SEMANTIC RESOLVER: PASS'
