# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../compiler/parser'
require_relative '../compiler/resolver'
require_relative '../compiler/runtime'
require_relative '../compiler/game_interaction'

class TestHoverInformation < Minitest::Test
  ROOT = File.expand_path('..', __dir__)

  def setup
    parser = BasicSharp::Parser.new(File.read(File.join(ROOT, 'samples/demon_killer_controls.bsharp')))
    @document = BasicSharp::SemanticResolver.new(parser.parse, dictionary: parser.dictionary).resolve
    @machine = BasicSharp::Runtime.new(@document)
  end

  def test_hover_fields_preserve_declared_order_and_current_values
    fields = BasicSharp::GameInteraction.new(@document, machine: @machine).hover_for('north gate')
    assert_equal %w[name kind state description], fields.map { |entry| entry['field'] }
    assert_equal ['north gate', 'gate', 'closed', 'A heavy oak gate.'], fields.map { |entry| entry['value'] }
  end

  def test_missing_hover_information_names_the_object_and_field
    source = File.read(File.join(ROOT, 'samples/demon_killer_controls.bsharp')).sub(
      '@north gate has "A heavy oak gate." description',
      '@north gate has 3 speed'
    )
    parser = BasicSharp::Parser.new(source)
    document = BasicSharp::SemanticResolver.new(parser.parse, dictionary: parser.dictionary).resolve
    interaction = BasicSharp::GameInteraction.new(document, machine: BasicSharp::Runtime.new(document))
    error = assert_raises(BasicSharp::GameInteractionError) { interaction.hover_for('north gate') }
    assert_includes error.message, '@north gate does not have description information'
  end
end
