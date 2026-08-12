#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../compiler/parser'
require_relative '../compiler/resolver'
require_relative '../compiler/game_input'
require_relative '../compiler/bytecode_emitter'
require_relative '../compiler/bytecode_loader'

ROOT = File.expand_path('..', __dir__)

def assert_input!(condition, message)
  raise "PLAIN-ENGLISH INPUT MAPPING FAILED: #{message}" unless condition
end

source = File.read(File.join(ROOT, 'samples/plain_english_input_mapping.bsharp'), encoding: 'UTF-8')
parser = BasicSharp::Parser.new(source)
document = BasicSharp::SemanticResolver.new(parser.parse, dictionary: parser.dictionary).resolve
assert_input!(BasicSharp::VERSION == '0.1.82', 'version mismatch')
assert_input!(document.error_count.zero?, 'input mapping sample must resolve without errors')

actions = document.controls.fetch(0).fetch('instructions').select { |entry| entry.fetch('type') == 'input_action' }.map { |entry| entry.fetch('action') }
assert_input!(actions == %w[jump attack interact pause], 'declared action set changed')

source_input = BasicSharp::GameInput.new(document)
bytecode_input = BasicSharp::GameInput.new(BasicSharp::BytecodeLoader.new(BasicSharp::BytecodeEmitter.new(document).binary).model)
events = [
  { 'type' => 'key_down', 'key' => 'Space' },
  { 'type' => 'mouse_down', 'button' => 'left' },
  { 'type' => 'button_down', 'device' => 'ps5', 'button' => 'triangle' },
  { 'type' => 'button_down', 'device' => 'xbox', 'button' => 'menu' },
  { 'type' => 'button_down', 'device' => 'generic_gamepad', 'button' => 'button_west' }
]
source_commands = events.flat_map { |event| source_input.process(event) }
bytecode_commands = events.flat_map { |event| bytecode_input.process(event) }
assert_input!(source_commands == bytecode_commands, 'source and BSBC loaded model must emit identical input actions')
assert_input!(source_commands.map { |entry| entry.fetch('action') } == %w[jump attack interact pause attack], 'action mapping command order changed')

puts "BASIC# Plain-English Input Mapping v#{BasicSharp::VERSION}: PASS"
