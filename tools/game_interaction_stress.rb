#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../compiler/parser'
require_relative '../compiler/resolver'
require_relative '../compiler/runtime'
require_relative '../compiler/game_interaction'

root = File.expand_path('..', __dir__)
source = File.read(File.join(root, 'samples/demon_killer_controls.bsharp'))
parser = BasicSharp::Parser.new(source)
document = BasicSharp::SemanticResolver.new(parser.parse, dictionary: parser.dictionary).resolve
runtime = BasicSharp::Runtime.new(document)
interaction = BasicSharp::GameInteraction.new(document, machine: runtime)
1_000.times do
  labels = interaction.context_for('north gate').map { |entry| entry.fetch('label') }
  raise 'context menu order changed' unless labels == %w[Open Examine]
end
interaction.execute('north gate', 'Open')
raise 'context action did not change state' unless interaction.context_for('north gate').first.fetch('label') == 'Close'
puts 'BASIC# game interaction stress: PASS (1,000 inspections plus execution)'
