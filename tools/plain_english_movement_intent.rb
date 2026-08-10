#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../compiler/parser'
require_relative '../compiler/resolver'
require_relative '../compiler/game_input'
require_relative '../compiler/bytecode_emitter'
require_relative '../compiler/bytecode_loader'
require_relative '../compiler/ast_nodes'

ROOT = File.expand_path('..', __dir__)
source = File.read(File.join(ROOT, 'samples/movement_intent_3d.bsharp'), encoding: 'UTF-8')
parser = BasicSharp::Parser.new(source)
document = BasicSharp::SemanticResolver.new(parser.parse, dictionary: parser.dictionary).resolve

def assert_movement!(condition, message)
  raise "Plain-English movement intent failed: #{message}" unless condition
end

assert_movement!(BasicSharp::VERSION == '0.1.72', 'version mismatch')
assert_movement!(document.error_count == 0, '3D sample must compile without errors')
assert_movement!(document.warning_count == 0, '3D sample must compile without warnings')
assert_movement!(document.meaning_profile == 'bsharp.meaning.v4', '3D movement must remain Profile 4 movement meaning')

instructions = document.controls.fetch(0).fetch('instructions')
assert_movement!(instructions.map { |entry| entry.fetch('type') } == %w[world_move world_move world_move world_move], '3D controls must lower to world_move instructions')
assert_movement!(instructions.map { |entry| entry.fetch('direction') } == %w[forward backward left right], '3D controls must preserve forward/backward/left/right intent')

source_input = BasicSharp::GameInput.new(document)
source_input.process('type' => 'key_down', 'key' => 'W')
forward = source_input.process('type' => 'frame', 'time_ms' => 0).fetch(0)
assert_movement!(forward.fetch('command') == 'move_3d', 'W must emit 3D movement command')
assert_movement!(forward.fetch('velocity_z') == 6.0, 'W must mean forward in 3D movement')
assert_movement!(forward.fetch('velocity_x') == 0.0, 'W alone must not strafe')

source_input.process('type' => 'key_down', 'key' => 'D')
diagonal = source_input.process('type' => 'frame', 'time_ms' => 16).fetch(0)
assert_movement!(diagonal.fetch('velocity_x').positive?, 'D must strafe right in 3D movement')
assert_movement!(diagonal.fetch('velocity_z').positive?, 'W must keep forward intent while D strafes')

loader = BasicSharp::BytecodeLoader.new(BasicSharp::BytecodeEmitter.new(document).binary)
source_input = BasicSharp::GameInput.new(document)
bytecode_input = BasicSharp::GameInput.new(loader.model)
events = [
  { 'type' => 'key_down', 'key' => 'W' },
  { 'type' => 'key_down', 'key' => 'D' },
  { 'type' => 'frame', 'time_ms' => 0 }
]
assert_movement!(events.flat_map { |event| source_input.process(event) } == events.flat_map { |event| bytecode_input.process(event) }, 'source and BSBC loaded model must emit identical 3D movement')

puts 'BASIC# Plain-English 2D/3D Movement Intent: PASS'
puts 'WASD can express forward/backward/strafe in 3D while 2D up/down remains separate movement intent.'
