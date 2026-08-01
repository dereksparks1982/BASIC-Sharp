# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../compiler/parser'
require_relative '../compiler/resolver'

class TestGameDeclarations < Minitest::Test
  ROOT = File.expand_path('..', __dir__)

  def resolve(source)
    parser = BasicSharp::Parser.new(source)
    BasicSharp::SemanticResolver.new(parser.parse, dictionary: parser.dictionary).resolve
  end

  def test_canonical_sample_resolves_profile_3_without_diagnostics
    document = resolve(File.read(File.join(ROOT, 'samples/demon_killer_controls.bsharp')))
    assert_equal 'bsharp.meaning.v3', document.meaning_profile
    assert_equal 0, document.error_count
    assert_equal 0, document.warning_count
    assert_equal 1, document.controls.length
    assert_equal 1, document.hover_declarations.length
    assert_equal 1, document.context_declarations.length
  end

  def test_visual_markers_resolve_to_stable_internal_names
    document = resolve(File.read(File.join(ROOT, 'samples/demon_killer_controls.bsharp')))
    assert_equal ['player', 'north gate', 'iron sword'], document.objects.map { |entry| entry['name'] }
    assert_equal 'door', document.hover_declarations.first.dig('subject', 'kind_name')
    assert_equal 'north gate', document.events.first.dig('when', 'target', 'name')
  end

  def test_retired_visual_forms_report_teaching_errors
    source = <<~BS
      DEFINE
      [
          north door is a door
      ].
      WHEN
      [
          player opens north door
          <then> (change north door to open
      ].
    BS
    messages = resolve(source).diagnostics.map(&:message).join("\n")
    assert_includes messages, "Thing must look like '@north door is a #door'"
    assert_includes messages, 'WHEN must put its event on the Head line'
    assert_includes messages, 'retired <then> and <than>'
  end
end
