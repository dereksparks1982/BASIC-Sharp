# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../compiler/parser'
require_relative '../compiler/resolver'

class TestDiagnosticsSamples < Minitest::Test
  SAMPLE_DIR = File.expand_path('../samples/errors', __dir__)

  def resolve_sample(name)
    source = File.read(File.join(SAMPLE_DIR, name))
    parser = DKScript::Parser.new(source)
    program = parser.parse
    DKScript::SemanticResolver.new(program, dictionary: parser.dictionary).resolve
  end

  def messages_for(name)
    resolve_sample(name).diagnostics.map(&:message)
  end

  def test_unknown_object_sample_reports_plain_reference_error
    messages = messages_for('unknown_object.dks')

    assert messages.any? { |message| message.include?("unknown reference 'ghost'") }, messages.join("\n")
  end

  def test_unknown_kind_sample_reports_unknown_kind
    messages = messages_for('unknown_kind.dks')

    assert messages.any? { |message| message == "unknown kind 'dragon'" }, messages.join("\n")
  end

  def test_unknown_state_sample_reports_unknown_state
    messages = messages_for('unknown_state.dks')

    assert messages.any? { |message| message == "unknown state 'sleepy'" }, messages.join("\n")
  end

  def test_unknown_action_sample_reports_unknown_action
    messages = messages_for('unknown_action.dks')

    assert messages.any? { |message| message == "unknown action 'explode'" }, messages.join("\n")
  end

  def test_ambiguous_door_sample_reports_choices
    messages = messages_for('ambiguous_door.dks')

    assert messages.any? { |message| message == 'which door? found: north door, cellar door' }, messages.join("\n")
  end

  def test_bad_line_command_sample_reports_then_suggestion
    messages = messages_for('bad_line_command.dks')

    assert messages.any? { |message| message == "unknown line command '<thne>'; did you mean <then>?" }, messages.join("\n")
  end
end
