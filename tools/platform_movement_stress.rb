#!/usr/bin/env ruby
# frozen_string_literal: true

require 'digest'
require 'json'
require_relative '../compiler/parser'
require_relative '../compiler/resolver'
require_relative '../compiler/game_input'

root = File.expand_path('..', __dir__)
parser = BasicSharp::Parser.new(File.read(File.join(root, 'samples/platform_movement.bsharp')))
document = BasicSharp::SemanticResolver.new(parser.parse, dictionary: parser.dictionary).resolve
fixture = JSON.parse(File.read(File.join(root, 'spec/runtime_v4/BASIC_SHARP_PLATFORM_MOVEMENT_RUNTIME_FIXTURES_v1.json')))
expected_path = File.join(root, fixture.fetch('expected'))
raise 'platform movement fixture hash changed' unless Digest::SHA256.hexdigest(File.binread(expected_path)) == fixture.fetch('expected_sha256')
fixture_input = BasicSharp::GameInput.new(document)
fixture_events = JSON.parse(File.read(File.join(root, fixture.fetch('input'))))
actual = { 'commands' => fixture_events.flat_map { |event| fixture_input.process(event) } }
expected = JSON.parse(File.read(expected_path))
raise 'platform movement fixture behavior changed' unless actual == expected

input = BasicSharp::GameInput.new(document)
input.process('type' => 'key_down', 'key' => 'D')

10_000.times do |index|
  input.process('type' => 'key_down', 'key' => 'SPACE') if (index % 250).zero?
  command = input.process(
    'type' => 'frame', 'time_ms' => index * 16,
    'grounded' => (index % 250).zero?, 'hit_right' => (index % 997).zero?
  ).fetch(0)
  raise 'wrong host command' unless command.fetch('command') == 'move_with_collisions'
  raise 'horizontal speed exceeded declaration' if command.fetch('velocity_x').abs > 6.0
  raise 'frame timing exceeded safety cap' if command.fetch('delta_seconds') > 0.25
  input.process('type' => 'key_up', 'key' => 'SPACE') if (index % 250) == 1
end

device_inputs = [
  ['keyboard arrows', { 'type' => 'key_down', 'key' => 'ArrowLeft' }, { 'type' => 'key_up', 'key' => 'ArrowLeft' }, -6.0],
  ['ps5 d-pad', { 'type' => 'button_down', 'device' => 'ps5', 'button' => 'dpad_right' }, { 'type' => 'button_up', 'device' => 'ps5', 'button' => 'dpad_right' }, 6.0],
  ['xbox stick', { 'type' => 'axis', 'device' => 'xbox', 'axis' => 'left_x', 'value' => -0.75 }, { 'type' => 'axis', 'device' => 'xbox', 'axis' => 'left_x', 'value' => 0.0 }, -6.0],
  ['generic gamepad', { 'type' => 'button_down', 'device' => 'generic_gamepad', 'button' => 'dpad_left' }, { 'type' => 'button_up', 'device' => 'generic_gamepad', 'button' => 'dpad_left' }, -6.0]
]

device_inputs.each_with_index do |(label, down, up, expected_x), index|
  input = BasicSharp::GameInput.new(document)
  input.process(down)
  command = input.process('type' => 'frame', 'time_ms' => index * 16, 'grounded' => true).fetch(0)
  raise "#{label} did not map to platform movement" unless command.fetch('velocity_x') == expected_x
  input.process(up)
  stopped = input.process('type' => 'frame', 'time_ms' => index * 16 + 16, 'grounded' => true).fetch(0)
  raise "#{label} did not release platform movement" unless stopped.fetch('velocity_x') == 0.0
end

puts 'BASIC# platform movement stress: PASS (10,000 frames)'
