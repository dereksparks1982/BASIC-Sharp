# frozen_string_literal: true

require 'json'
require 'minitest/autorun'
require_relative '../compiler/tokenizer_reader'

class TestTokenizerReaderImplementation < Minitest::Test
  ROOT = File.expand_path('..', __dir__)
  SPEC_PATH = File.join(ROOT, 'spec/self_hosting/BASIC_SHARP_TOKENIZER_READER_CONTRACT_v1.json')

  def spec
    @spec ||= JSON.parse(File.read(SPEC_PATH, encoding: 'UTF-8'))
  end

  def fixture(name)
    spec.fetch('fixtures').find { |entry| entry.fetch('name') == name }
  end

  def test_reader_records_match_ruby_referee_for_each_fixture
    spec.fetch('fixtures').each do |entry|
      reader = BasicSharp::TokenizerReader.new(entry.fetch('source'))

      assert reader.reader_matches_ruby_referee?, "Ruby referee mismatch for #{entry.fetch('name')}"
      assert_equal JSON.parse(JSON.generate(reader.ruby_referee_reader_records)), reader.reader_records.map(&:to_h).map { |entry| JSON.parse(JSON.generate(entry)) }
    end
  end

  def test_expected_token_records_are_deterministic
    entry = fixture('comments_preserve_reader_shape')
    reader = BasicSharp::TokenizerReader.new(entry.fetch('source'))
    actual = reader.token_records.map(&:to_h).map { |record| JSON.parse(JSON.generate(record)) }

    assert_equal entry.fetch('expected_tokens'), actual
  end

  def test_action_words_inside_quoted_text_are_not_tokenized
    source = <<~BASIC
      START
      [
          PLAYER has "(change is text only" motto
          |then (change PLAYER to ready
      ].
    BASIC
    reader = BasicSharp::TokenizerReader.new(source)
    action_tokens = reader.token_records.select { |token| token.kind == 'action_word' }

    assert_equal 1, action_tokens.length
    assert_equal 4, action_tokens.first.line
    assert_equal 'change', action_tokens.first.normalized
  end

  def test_to_h_exposes_versioned_records_without_parser_authority_claim
    reader = BasicSharp::TokenizerReader.new(<<~BASIC)
      WHEN PLAYER jumps
      [
          |then (move PLAYER up
      ].
    BASIC
    document = reader.to_h

    assert_equal 'bsharp.tokenizer_reader.implementation.record', document.fetch(:format)
    assert_equal '0.1.53', document.fetch(:version)
    assert_equal [:format, :version, :reader_records, :token_records, :issues], document.keys
    assert document.fetch(:token_records).any? { |record| record[:kind] == 'head' && record[:normalized] == 'WHEN' }
    assert document.fetch(:token_records).any? { |record| record[:kind] == 'action_word' && record[:normalized] == 'move' }
  end
end
