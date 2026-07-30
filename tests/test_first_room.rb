# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../compiler/parser'

class TestFirstRoom < Minitest::Test
  def setup
    @source = File.read(File.expand_path('../samples/first_room.bsharp', __dir__))
    @program = BasicSharp::Parser.new(@source).parse
  end

  def test_parses_statement_counts
    assert_equal 8, @program.statements.length
    assert_equal 6, @program.definitions.length
    assert_equal 5, @program.facts.length
    assert_equal 4, @program.event_rules.length
    assert_equal 1, @program.if_rules.length
  end

  def test_definitions_feed_dictionary
    names = @program.definitions.map(&:name)
    assert_includes names, 'ember'
    assert_includes names, 'cinder'
    assert_includes names, 'north door'
    assert_includes names, 'brass key'
    assert_includes names, 'oak table'
    assert_includes names, 'henry'
  end

  def test_actions_are_detected
    actions = @program.event_rules.flat_map(&:actions) + @program.if_rules.flat_map(&:actions)
    assert_equal %w[carry damage change damage change damage change unlock], actions.map(&:verb)
  end

  def test_no_errors
    errors = @program.diagnostics.select { |d| d.severity == 'error' }
    assert_empty errors, errors.map(&:to_s).join("
")
  end
end

class TestBodyStructureAndKinds < Minitest::Test
  def parse(source)
    BasicSharp::Parser.new(source).parse
  end

  def test_user_defined_kind_is_registered_before_define
    program = parse(<<~DKS)
      KINDS
      [dragon is a creature].

      DEFINE
      [a dragon named ember].
    DKS

    assert_equal ['dragon'], program.kind_definitions.map(&:name)
    assert_equal ['ember'], program.definitions.map(&:name)
    assert_empty program.diagnostics.select { |d| d.severity == 'error' }
  end


  def test_existing_builtin_kind_can_receive_one_direct_parent
    program = parse(<<~DKS)
      KINDS
      [creature is a thing
      dragon is a creature
      wyrm is a dragon].

      DEFINE
      [a wyrm named ember].
    DKS

    assert_equal %w[creature dragon wyrm], program.kind_definitions.map(&:name)
    assert_equal %w[thing creature dragon], program.kind_definitions.map(&:parent)
    assert_empty program.diagnostics.select { |d| d.severity == 'error' }
  end

  def test_kind_can_have_only_one_direct_parent
    program = parse(<<~DKS)
      KINDS
      [creature is a thing
      creature is a place].
    DKS

    errors = program.diagnostics.select { |d| d.severity == 'error' }.map(&:message)
    assert_includes errors, "kind 'creature' already has parent 'thing'"
  end

  def test_kind_family_loop_is_rejected_with_the_loop_shown
    program = parse(<<~DKS)
      KINDS
      [creature is a thing
      dragon is a creature
      thing is a dragon].
    DKS

    errors = program.diagnostics.select { |d| d.severity == 'error' }.map(&:message)
    assert_includes errors, 'Kind family has a loop: thing -> dragon -> creature -> thing'
  end

  def test_than_is_accepted_as_then_result
    program = parse(<<~DKS)
      DEFINE
      [a guard named henry].

      WHEN
      [player attacks henry
      <than> (damage henry].
    DKS

    assert_equal ['damage'], program.event_rules.first.actions.map(&:verb)
    assert_empty program.diagnostics.select { |d| d.severity == 'error' }
  end

  def test_old_child_structure_is_rejected
    program = parse("DEFINE\n<a guard named henry.\n")
    errors = program.diagnostics.select { |d| d.severity == 'error' }.map(&:message)

    assert_includes errors, 'old child-line structure no longer works; start the Body with ['
  end
end

class TestApprovedWordPairs < Minitest::Test
  def test_there_and_their_share_the_location_word
    dictionary = BasicSharp::CoreDictionary.new

    assert_equal 'there', dictionary.normalize_confused_word('there')
    assert_equal 'there', dictionary.normalize_confused_word('their')
  end
end
