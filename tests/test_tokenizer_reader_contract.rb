# frozen_string_literal: true

require 'json'
require 'minitest/autorun'
require_relative '../compiler/ast_nodes'
require_relative '../compiler/lexer'
require_relative '../compiler/parser'
require_relative '../compiler/tokenizer_reader'

class TestTokenizerReaderContract < Minitest::Test
  ROOT = File.expand_path('..', __dir__)
  SPEC_PATH = File.join(ROOT, 'spec/self_hosting/BASIC_SHARP_TOKENIZER_READER_CONTRACT_v1.json')

  def spec
    @spec ||= JSON.parse(File.read(SPEC_PATH, encoding: 'UTF-8'))
  end

  def test_spec_targets_the_live_basic_sharp_version
    assert_equal '0.1.65', BasicSharp::VERSION
    assert_equal BasicSharp::VERSION, spec.fetch('target_version')
    assert_equal 'implementation_under_ruby_referee', spec.fetch('status')
  end

  def test_current_head_words_match_the_parser_and_implementation
    expected = %w[KINDS DEFINE START WHEN IF OTHERWISE CONTROLS HOVER CONTEXT]

    assert_equal expected, spec.fetch('current_head_words')
    assert_equal expected, BasicSharp::Parser::BLOCK_HEADS
    assert_equal expected, BasicSharp::TokenizerReader::HEAD_WORDS
  end

  def test_reader_fixture_preserves_comments_quotes_and_line_numbers
    fixture = spec.fetch('fixtures').find { |entry| entry.fetch('name') == 'comments_preserve_reader_shape' }
    lexer = BasicSharp::Lexer.new(fixture.fetch('source'))
    lines = lexer.lines.map { |line| { 'number' => line.number, 'raw' => line.raw, 'text' => line.text } }
    reader = BasicSharp::TokenizerReader.new(fixture.fetch('source'))

    assert_equal fixture.fetch('expected_lines'), lines
    assert_equal lines, reader.reader_records.map(&:to_h).map { |entry| JSON.parse(JSON.generate(entry)) }
    assert reader.reader_matches_ruby_referee?
    assert_equal [], lexer.issues
  end

  def test_reader_fixture_reports_comment_issues
    fixture = spec.fetch('fixtures').find { |entry| entry.fetch('name') == 'reader_reports_comment_errors' }
    lexer = BasicSharp::Lexer.new(fixture.fetch('source'))
    lexer.lines
    reader = BasicSharp::TokenizerReader.new(fixture.fetch('source'))
    issues = lexer.issues.map(&:message)
    implementation_issues = reader.issues.map(&:message)

    fixture.fetch('expected_issue_fragments').each do |fragment|
      assert issues.any? { |message| message.include?(fragment) }, "missing issue fragment: #{fragment}"
      assert implementation_issues.any? { |message| message.include?(fragment) }, "implementation missing issue fragment: #{fragment}"
    end
  end

  def test_trial_by_fire_inventory_runs_the_contract_tool
    inventory = JSON.parse(File.read(File.join(ROOT, 'spec/trial_by_fire/BASIC_SHARP_TRIAL_BY_FIRE_VALIDATION_INVENTORY_v1.json'), encoding: 'UTF-8'))
    tools = inventory.fetch('required_tools').map { |entry| entry.fetch('path') }

    assert_includes tools, 'tools/tokenizer_reader_contract.rb'
  end
end
