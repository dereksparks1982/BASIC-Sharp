# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../compiler/parser'
require_relative '../compiler/resolver'
require_relative '../compiler/world_save'

class TestComments < Minitest::Test
  def resolve(source)
    parser = BasicSharp::Parser.new(source)
    BasicSharp::SemanticResolver.new(parser.parse, dictionary: parser.dictionary).resolve
  end

  def test_single_line_and_multiline_comments_do_not_change_meaning
    plain = <<~BS
      START
      [
          PLAYER has 3 speed
      ].
    BS
    commented = <<~BS
      //This comment has punctuation.\nAnd spans lines./.
      START
      [
          PLAYER has 3 speed //Walking speed./.
      ].
    BS
    assert_equal BasicSharp::WorldSave.program_fingerprint(resolve(plain)), BasicSharp::WorldSave.program_fingerprint(resolve(commented))
  end

  def test_comment_markers_inside_text_are_ordinary_text
    source = <<~BS
      DEFINE
      [
          @sign is a #thing
      ].
      START
      [
          @sign has "Use // and /. here." description
      ].
    BS
    document = resolve(source)
    assert_equal 0, document.error_count
    assert_equal 'Use // and /. here.', document.facts.first.fetch('text_value')
  end

  def test_unclosed_nested_and_unmatched_comments_are_rejected
    unclosed = resolve("START\n[\nPLAYER has 3 speed //open\n].\n")
    assert_includes unclosed.diagnostics.map(&:message).join("\n"), 'Close the comment by adding /.'
    nested = resolve("//outer //inner /.\n")
    assert_includes nested.diagnostics.map(&:message).join("\n"), 'Comments cannot begin inside another comment'
    unmatched = resolve("/.\n")
    assert_includes unmatched.diagnostics.map(&:message).join("\n"), 'has no opening //'
  end
end
