# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../compiler/parser'
require_relative '../compiler/resolver'

class TestResolver < Minitest::Test
  def resolve(source)
    parser = DKScript::Parser.new(source)
    program = parser.parse
    DKScript::SemanticResolver.new(program, dictionary: parser.dictionary).resolve
  end

  def test_resolves_sample_without_errors
    source = File.read(File.expand_path('../samples/first_room.dks', __dir__))
    document = resolve(source)
    errors = document.diagnostics.select { |diagnostic| diagnostic.severity == 'error' }

    assert_empty errors, errors.map(&:to_s).join("\n")
    assert_equal 4, document.objects.length
    assert_equal %w[player north\ door brass\ key henry], document.objects.map { |object| object['name'] }
  end

  def test_normalizes_event_verbs
    source = File.read(File.expand_path('../samples/first_room.dks', __dir__))
    document = resolve(source)

    first_event = document.events.first.fetch('when')
    second_event = document.events.last.fetch('when')

    assert_equal 'take', first_event.fetch('action')
    assert_equal 'attack', second_event.fetch('action')
  end

  def test_reports_ambiguous_definite_kind
    document = resolve(<<~DKS)
      DEFINE
      <a door named north door
      <a door named cellar door.

      IF
      <the door is locked
      <then> (unlock the door.
    DKS

    messages = document.diagnostics.map(&:message)
    assert messages.any? { |message| message.include?('which door?') }, messages.join("\n")
  end

  def test_reports_unknown_action_and_state
    document = resolve(<<~DKS)
      DEFINE
      <a guard named henry.

      START
      <henry is sleepy.

      WHEN
      <player attacks henry
      <then> (explode henry.
    DKS

    errors = document.diagnostics.select { |diagnostic| diagnostic.severity == 'error' }.map(&:message)
    assert_includes errors, "unknown state 'sleepy'"
    assert_includes errors, "unknown action 'explode'"
  end
end
