#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../compiler/game_input'
require_relative '../compiler/parser'
require_relative '../compiler/resolver'

root = File.expand_path('..', __dir__)
parser = BasicSharp::Parser.new(File.read(File.join(root, 'samples/demon_killer_controls.bsharp')))
document = BasicSharp::SemanticResolver.new(parser.parse, dictionary: parser.dictionary).resolve
input = BasicSharp::GameInput.new(document)
%w[W D].each { |key| input.process('type' => 'key_down', 'key' => key) }
10_000.times do |index|
  frame = input.process('type' => 'frame', 'time_ms' => index).fetch(0)
  length = Math.sqrt(frame.fetch('x')**2 + frame.fetch('y')**2)
  raise 'diagonal speed exceeded maximum' if length > 1.000_000_001
end
puts 'BASIC# Demon Killer input stress: PASS (10,000 frames)'
