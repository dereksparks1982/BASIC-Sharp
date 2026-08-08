#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require_relative '../compiler/ast_nodes'
require_relative '../compiler/lexer'
require_relative '../compiler/parser'
require_relative '../compiler/tokenizer_reader'

ROOT = File.expand_path('..', __dir__)
SPEC_PATH = File.join(ROOT, 'spec/self_hosting/BASIC_SHARP_TOKENIZER_READER_CONTRACT_v1.json')
CONTRACT_DOC_PATH = File.join(ROOT, 'docs/self_hosting/BASIC_SHARP_TOKENIZER_READER_CONTRACT_v0_1_47.md')
IMPLEMENTATION_DOC_PATH = File.join(ROOT, 'docs/self_hosting/BASIC_SHARP_TOKENIZER_READER_IMPLEMENTATION_v0_1_48.md')
REFERENCE_PATHS = [
  'README.md',
  'docs/roadmap/BASIC_SHARP_ROADMAP.md',
  'docs/hand_off/BASIC_SHARP_MASTER_THREAD_HANDOFF.md',
  'docs/company_bible/BASIC_SHARP_COMPANY_BIBLE.md',
  'docs/self_hosting/BASIC_SHARP_TOKENIZER_READER_CONTRACT_v0_1_47.md',
  'docs/self_hosting/BASIC_SHARP_TOKENIZER_READER_IMPLEMENTATION_v0_1_48.md',
  'docs/strategy/BASIC_SHARP_UNIVERSAL_STANDARD_AND_AI_TOOLING_DOCTRINE_v0_1_47.md'
].freeze

spec = JSON.parse(File.read(SPEC_PATH, encoding: 'UTF-8'))

def assert_contract!(condition, message)
  raise "Tokenizer/reader contract failed: #{message}" unless condition
end

assert_contract!(spec.fetch('format') == 'bsharp.tokenizer_reader.contract.json', 'wrong spec identity')
assert_contract!(spec.fetch('format_version') == 1, 'wrong format version')
assert_contract!(spec.fetch('target_version') == BasicSharp::VERSION, 'target version does not match BasicSharp::VERSION')
assert_contract!(spec.fetch('status') == 'implementation_under_ruby_referee', 'status must be implementation_under_ruby_referee')

allowed_heads = %w[KINDS DEFINE START WHEN IF OTHERWISE CONTROLS HOVER CONTEXT]
assert_contract!(spec.fetch('current_head_words') == allowed_heads, 'Head list drifted')
assert_contract!(BasicSharp::Parser::BLOCK_HEADS == allowed_heads, 'Parser Head list differs from contract')
assert_contract!(BasicSharp::TokenizerReader::HEAD_WORDS == allowed_heads, 'TokenizerReader Head list differs from parser')

forbidden = spec.fetch('scope').fetch('forbidden_until_later_approval')
[
  'replacing compiler/lexer.rb or compiler/parser.rb as the authority',
  'routing the production parser through compiler/tokenizer_reader.rb',
  'claiming BASIC# is self-hosted',
  'adding Profile 8',
  'adding new creator-facing syntax',
  'changing runtime meaning, BSharp IR, BSharp Bytecode, Save format, ASK output, input devices, graphics, engine bridge, browser work, web export, or Ruby retirement'
].each do |entry|
  assert_contract!(forbidden.include?(entry), "missing exclusion: #{entry}")
end

schema = spec.fetch('reader_record_schema')
assert_contract!(schema.keys.sort == %w[number raw text], 'reader record schema changed')
assert_contract!(spec.fetch('implementation_record_schema').keys.sort == %w[issues reader_records token_records], 'implementation record schema changed')
assert_contract!(spec.fetch('token_kinds_implemented') == %w[head body_open body_close body_line result_line result_marker action_word quoted_text], 'token kind list changed')

spec.fetch('fixtures').each do |fixture|
  lexer = BasicSharp::Lexer.new(fixture.fetch('source'))
  ruby_lines = lexer.lines.map { |line| { 'number' => line.number, 'raw' => line.raw, 'text' => line.text } }
  ruby_issues = lexer.issues.map(&:message)

  reader = BasicSharp::TokenizerReader.new(fixture.fetch('source'))
  implementation_lines = reader.reader_records.map(&:to_h).map { |entry| JSON.parse(JSON.generate(entry)) }
  implementation_issues = reader.issues.map(&:message)
  implementation_tokens = reader.token_records.map(&:to_h).map { |entry| JSON.parse(JSON.generate(entry)) }

  assert_contract!(implementation_lines == ruby_lines, "fixture #{fixture.fetch('name')} reader records no longer match Ruby referee")
  assert_contract!(reader.reader_matches_ruby_referee?, "fixture #{fixture.fetch('name')} referee comparison failed")

  if fixture.key?('expected_lines')
    assert_contract!(ruby_lines == fixture.fetch('expected_lines'), "fixture #{fixture.fetch('name')} line records changed")
    assert_contract!(ruby_issues == fixture.fetch('expected_issues'), "fixture #{fixture.fetch('name')} Ruby issues changed")
  end

  if fixture.key?('expected_issue_fragments')
    fixture.fetch('expected_issue_fragments').each do |fragment|
      assert_contract!(ruby_issues.any? { |message| message.include?(fragment) }, "fixture #{fixture.fetch('name')} missing issue fragment #{fragment}")
      assert_contract!(implementation_issues.any? { |message| message.include?(fragment) }, "fixture #{fixture.fetch('name')} implementation missing issue fragment #{fragment}")
    end
  end

  assert_contract!(implementation_tokens == fixture.fetch('expected_tokens'), "fixture #{fixture.fetch('name')} token records changed")
end

[CONTRACT_DOC_PATH, IMPLEMENTATION_DOC_PATH].each do |path|
  raise "Tokenizer/reader document is missing: #{path}" unless File.file?(path)
end

REFERENCE_PATHS.each do |relative|
  text = File.read(File.join(ROOT, relative), encoding: 'UTF-8')
  assert_contract!(text.include?('spec/self_hosting/BASIC_SHARP_TOKENIZER_READER_CONTRACT_v1.json'), "#{relative} does not reference the tokenizer/reader spec")
end

implementation_doc = File.read(IMPLEMENTATION_DOC_PATH, encoding: 'UTF-8')
['Ruby referee', 'compiler/tokenizer_reader.rb', 'not the production parser authority', 'No Profile 8'].each do |line|
  assert_contract!(implementation_doc.include?(line), "implementation document missing #{line}")
end

strategy = File.read(File.join(ROOT, 'docs/strategy/BASIC_SHARP_UNIVERSAL_STANDARD_AND_AI_TOOLING_DOCTRINE_v0_1_47.md'), encoding: 'UTF-8')
['Compatibility before conquest.', 'Validation before replacement.', 'Performance before hype.', 'Creator clarity before programmer tradition.'].each do |line|
  assert_contract!(strategy.include?(line), "universal doctrine missing #{line}")
end

puts "BASIC# Tokenizer/Reader Implementation v#{BasicSharp::VERSION}"
puts "Reader fixtures: #{spec.fetch('fixtures').length}"
puts "Current Heads: #{allowed_heads.join(', ')}"
puts 'Ruby Lexer referee comparison: PASS'
puts 'Implementation token records: PASS'
puts 'Parser authority unchanged: PASS'
puts 'No Profile 8, syntax, runtime, web export, or browser work: PASS'
puts 'TOKENIZER/READER IMPLEMENTATION: PASS'
