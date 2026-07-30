# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../compiler/parser'
require_relative '../compiler/resolver'

class TestResolver < Minitest::Test
  def resolve(source)
    parser = BasicSharp::Parser.new(source)
    program = parser.parse
    BasicSharp::SemanticResolver.new(program, dictionary: parser.dictionary).resolve
  end

  def test_resolves_sample_without_errors_or_warnings
    source = File.read(File.expand_path('../samples/first_room.bsharp', __dir__))
    document = resolve(source)

    errors = document.diagnostics.select { |diagnostic| diagnostic.severity == 'error' }
    warnings = document.diagnostics.select { |diagnostic| diagnostic.severity == 'warning' }

    assert_empty errors, errors.map(&:to_s).join("
")
    assert_empty warnings, warnings.map(&:to_s).join("
")
    assert_equal 7, document.objects.length
    assert_equal ['player', 'ember', 'cinder', 'north door', 'brass key', 'oak table', 'henry'], document.objects.map { |object| object['name'] }
  end

  def test_normalizes_event_verbs
    source = File.read(File.expand_path('../samples/first_room.bsharp', __dir__))
    document = resolve(source)

    first_event = document.events.first.fetch('when')
    second_event = document.events.last.fetch('when')

    assert_equal 'take', first_event.fetch('action')
    assert_equal 'attack', second_event.fetch('action')
  end

  def test_resolves_the_table_when_one_table_exists
    source = File.read(File.expand_path('../samples/first_room.bsharp', __dir__))
    document = resolve(source)
    table_fact = document.facts.find { |fact| fact.fetch('relation') == 'on' }
    target = table_fact.fetch('target')

    assert_equal 'object', target.fetch('type')
    assert_equal 'oak table', target.fetch('name')
    assert_equal true, target.fetch('matched_by_kind')
  end

  def test_warns_about_unresolved_definite_kind
    document = resolve(<<~DKS)
      DEFINE
      [a key named brass key].

      START
      [brass key is on the table].
    DKS

    warnings = document.diagnostics.select { |diagnostic| diagnostic.severity == 'warning' }.map(&:message)
    assert_includes warnings, "unresolved definite reference 'the table': no table object was defined"

    table_fact = document.facts.first
    assert_equal 'unresolved', table_fact.fetch('target').fetch('type')
    assert_equal 'no_defined_object', table_fact.fetch('target').fetch('reason')
  end

  def test_reports_ambiguous_definite_kind
    document = resolve(<<~DKS)
      DEFINE
      [a door named north door
      a door named cellar door].

      IF
      [the door is locked
      <then> (unlock the door].
    DKS

    messages = document.diagnostics.map(&:message)
    assert messages.any? { |message| message.include?('which door?') }, messages.join("
")
  end

  def test_reports_unknown_action_and_state
    document = resolve(<<~DKS)
      DEFINE
      [a guard named henry].

      START
      [henry is sleepy].

      WHEN
      [player attacks henry
      <then> (explode henry].
    DKS

    errors = document.diagnostics.select { |diagnostic| diagnostic.severity == 'error' }.map(&:message)
    assert_includes errors, "unknown state 'sleepy'"
    assert_includes errors, "unknown official word '(explode'"
  end

  def test_inherited_kind_selector_finds_descendant_object
    document = resolve(<<~DKS)
      KINDS
      [creature is a thing
      dragon is a creature
      wyrm is a dragon].

      DEFINE
      [a wyrm named ember].

      IF
      [the creature is calm
      <then> (damage the creature].
    DKS

    subject = document.if_rules.first.dig('if', 'subject')
    assert_equal 'object', subject.fetch('type')
    assert_equal 'ember', subject.fetch('name')
    assert_equal true, subject.fetch('matched_by_kind')

    parser = BasicSharp::Parser.new(<<~DKS)
      KINDS
      [creature is a thing
      dragon is a creature
      wyrm is a dragon].

      DEFINE
      [a wyrm named ember].
    DKS
    parser.parse
    assert_equal ['ember'], parser.dictionary.objects_by_kind('creature')
    assert_equal ['ember'], parser.dictionary.objects_by_kind('thing')
  end

end
