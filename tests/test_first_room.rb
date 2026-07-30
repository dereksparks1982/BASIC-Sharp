# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../compiler/parser'

class TestFirstRoom < Minitest::Test
  def setup
    @source = File.read(File.expand_path('../samples/first_room.dks', __dir__))
    @program = DKScript::Parser.new(@source).parse
  end

  def test_parses_statement_counts
    assert_equal 5, @program.statements.length
    assert_equal 4, @program.definitions.length
    assert_equal 3, @program.facts.length
    assert_equal 2, @program.event_rules.length
    assert_equal 1, @program.if_rules.length
  end

  def test_definitions_feed_dictionary
    names = @program.definitions.map(&:name)
    assert_includes names, 'north door'
    assert_includes names, 'brass key'
    assert_includes names, 'oak table'
    assert_includes names, 'henry'
  end

  def test_actions_are_detected
    actions = @program.event_rules.flat_map(&:actions) + @program.if_rules.flat_map(&:actions)
    assert_equal %w[carry damage change unlock], actions.map(&:verb)
  end

  def test_no_errors
    errors = @program.diagnostics.select { |d| d.severity == 'error' }
    assert_empty errors, errors.map(&:to_s).join("
")
  end
end
