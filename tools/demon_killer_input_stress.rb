#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../compiler/game_input'
require_relative '../compiler/parser'
require_relative '../compiler/resolver'

root = File.expand_path('..', __dir__)
parser = BasicSharp::Parser.new(File.read(File.join(root, 'samples/demon_killer_controls.bsharp'), encoding: 'UTF-8'))
document = BasicSharp::SemanticResolver.new(parser.parse, dictionary: parser.dictionary).resolve
input = BasicSharp::GameInput.new(document)
%w[W D].each { |key| input.process('type' => 'key_down', 'key' => key) }
10_000.times do |index|
  frame = input.process('type' => 'frame', 'time_ms' => index).fetch(0)
  length = Math.sqrt(frame.fetch('x')**2 + frame.fetch('y')**2)
  raise 'diagonal speed exceeded maximum' if length > 1.000_000_001
end

[
  ['keyboard arrows', { 'type' => 'key_down', 'key' => 'ArrowRight' }, { 'type' => 'key_up', 'key' => 'ArrowRight' }, 'x', 1.0],
  ['ps5 d-pad', { 'type' => 'button_down', 'device' => 'ps5', 'button' => 'dpad_left' }, { 'type' => 'button_up', 'device' => 'ps5', 'button' => 'dpad_left' }, 'x', -1.0],
  ['xbox stick', { 'type' => 'axis', 'device' => 'xbox', 'axis' => 'left_y', 'value' => 0.75 }, { 'type' => 'axis', 'device' => 'xbox', 'axis' => 'left_y', 'value' => 0.0 }, 'y', 1.0],
  ['generic gamepad', { 'type' => 'button_down', 'device' => 'generic_gamepad', 'button' => 'dpad_up' }, { 'type' => 'button_up', 'device' => 'generic_gamepad', 'button' => 'dpad_up' }, 'y', -1.0]
].each_with_index do |(label, down, up, axis, expected), index|
  input = BasicSharp::GameInput.new(document)
  input.process(down)
  frame = input.process('type' => 'frame', 'time_ms' => index).fetch(0)
  raise "#{label} did not map to top-down movement" unless frame.fetch(axis) == expected
  input.process(up)
  stopped = input.process('type' => 'frame', 'time_ms' => index + 100).fetch(0)
  raise "#{label} did not release top-down movement" unless stopped.fetch(axis) == 0.0
end

puts 'BASIC# Demon Killer input stress: PASS (10,000 frames)'
