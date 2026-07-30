# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../compiler/parser'
require_relative '../compiler/resolver'

class TestDiagnosticsSamples < Minitest::Test
  SAMPLE_DIR = File.expand_path('../samples/errors', __dir__)

  def resolve_sample(name)
    source = File.read(File.join(SAMPLE_DIR, name))
    parser = BasicSharp::Parser.new(source)
    program = parser.parse
    BasicSharp::SemanticResolver.new(program, dictionary: parser.dictionary).resolve
  end

  def diagnostics_for(name)
    resolve_sample(name).diagnostics
  end

  def messages_for(name, severity: nil)
    diagnostics_for(name)
      .select { |diagnostic| severity.nil? || diagnostic.severity == severity }
      .map(&:message)
  end

  def assert_no_duplicate_diagnostics(name)
    diagnostics = diagnostics_for(name)
    keys = diagnostics.map(&:key)

    assert_equal keys.uniq, keys, "duplicate diagnostics in #{name}: #{diagnostics.map(&:to_s).join("
")}"
  end

  def test_unknown_object_sample_reports_one_plain_reference_error
    assert_no_duplicate_diagnostics('unknown_object.bsharp')
    assert_equal ["unknown reference 'ghost': not a defined object and not a known kind"], messages_for('unknown_object.bsharp', severity: 'error')
    assert_empty messages_for('unknown_object.bsharp', severity: 'warning')
  end

  def test_unknown_kind_sample_reports_unknown_kind_once
    assert_no_duplicate_diagnostics('unknown_kind.bsharp')
    assert_equal ["unknown kind 'dragon'"], messages_for('unknown_kind.bsharp', severity: 'error')
    assert_empty messages_for('unknown_kind.bsharp', severity: 'warning')
  end

  def test_unknown_state_sample_reports_unknown_state_once
    assert_no_duplicate_diagnostics('unknown_state.bsharp')
    assert_equal ["unknown state 'sleepy'"], messages_for('unknown_state.bsharp', severity: 'error')
    assert_empty messages_for('unknown_state.bsharp', severity: 'warning')
  end

  def test_unknown_action_sample_reports_unknown_action_once
    assert_no_duplicate_diagnostics('unknown_action.bsharp')
    assert_equal ["unknown official word '(explode'"], messages_for('unknown_action.bsharp', severity: 'error')
    assert_empty messages_for('unknown_action.bsharp', severity: 'warning')
  end

  def test_ambiguous_door_sample_reports_both_ambiguous_lines
    assert_no_duplicate_diagnostics('ambiguous_door.bsharp')
    diagnostics = diagnostics_for('ambiguous_door.bsharp')

    assert_equal [5, 7], diagnostics.map(&:line_number)
    assert_equal ['which door? found: north door, cellar door', 'which door? found: north door, cellar door'], diagnostics.map(&:message)
  end

  def test_bad_line_command_sample_reports_only_the_typo
    assert_no_duplicate_diagnostics('bad_line_command.bsharp')
    assert_equal ["unknown Connector '<thne>'; did you mean <then>?"], messages_for('bad_line_command.bsharp', severity: 'error')
    assert_empty messages_for('bad_line_command.bsharp', severity: 'warning')
  end
end
