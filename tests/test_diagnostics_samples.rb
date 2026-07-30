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
    assert_no_duplicate_diagnostics('unknown_object.dks')
    assert_equal ["unknown reference 'ghost': not a defined object and not a known kind"], messages_for('unknown_object.dks', severity: 'error')
    assert_empty messages_for('unknown_object.dks', severity: 'warning')
  end

  def test_unknown_kind_sample_reports_unknown_kind_once
    assert_no_duplicate_diagnostics('unknown_kind.dks')
    assert_equal ["unknown kind 'dragon'"], messages_for('unknown_kind.dks', severity: 'error')
    assert_empty messages_for('unknown_kind.dks', severity: 'warning')
  end

  def test_unknown_state_sample_reports_unknown_state_once
    assert_no_duplicate_diagnostics('unknown_state.dks')
    assert_equal ["unknown state 'sleepy'"], messages_for('unknown_state.dks', severity: 'error')
    assert_empty messages_for('unknown_state.dks', severity: 'warning')
  end

  def test_unknown_action_sample_reports_unknown_action_once
    assert_no_duplicate_diagnostics('unknown_action.dks')
    assert_equal ["unknown action 'explode'"], messages_for('unknown_action.dks', severity: 'error')
    assert_empty messages_for('unknown_action.dks', severity: 'warning')
  end

  def test_ambiguous_door_sample_reports_both_ambiguous_lines
    assert_no_duplicate_diagnostics('ambiguous_door.dks')
    diagnostics = diagnostics_for('ambiguous_door.dks')

    assert_equal [5, 7], diagnostics.map(&:line_number)
    assert_equal ['which door? found: north door, cellar door', 'which door? found: north door, cellar door'], diagnostics.map(&:message)
  end

  def test_bad_line_command_sample_reports_only_the_typo
    assert_no_duplicate_diagnostics('bad_line_command.dks')
    assert_equal ["unknown line command '<thne>'; did you mean <then>?"], messages_for('bad_line_command.dks', severity: 'error')
    assert_empty messages_for('bad_line_command.dks', severity: 'warning')
  end
end
