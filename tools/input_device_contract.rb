#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require_relative '../compiler/ast_nodes'

ROOT = File.expand_path('..', __dir__)
SPEC_PATH = File.join(ROOT, 'spec/input/BASIC_SHARP_INPUT_DEVICE_MAPPING_v1.json')
DOC_PATH = File.join(ROOT, 'docs/language/BASIC_SHARP_PLAIN_ENGLISH_INPUT_MAPPING_v0_1_71.md')

def assert_contract!(condition, message)
  raise "INPUT DEVICE CONTRACT FAILED: #{message}" unless condition
end

spec = JSON.parse(File.read(SPEC_PATH, encoding: Encoding::UTF_8))
doc = File.read(DOC_PATH, encoding: Encoding::UTF_8)

assert_contract!(spec.fetch('format') == 'bsharp.input.device_mapping.json', 'format identity changed')
assert_contract!(spec.fetch('format_version') == 1, 'format version changed')
assert_contract!(spec.fetch('target_version') == BasicSharp::VERSION, 'target version does not match BasicSharp::VERSION')
assert_contract!(spec.fetch('status') == 'contract_and_runtime_mapping', 'status changed')

supported = spec.fetch('supported_inputs')
%w[keyboard mouse_keyboard movement_contexts declared_player_actions ps5 xbox generic_gamepad].each do |device|
  assert_contract!(supported.key?(device), "#{device} mapping is missing")
end

%w[left right up down jump attack interact pause].each do |meaning|
  assert_contract!(supported.fetch('keyboard').key?(meaning), "keyboard #{meaning} mapping is missing")
end
%w[jump attack interact pause].each do |action|
  assert_contract!(supported.fetch('declared_player_actions').key?(action), "declared player action #{action} is missing")
end
assert_contract!(supported.fetch('mouse_keyboard').key?('attack'), 'mouse attack mapping is missing')
%w[ps5 xbox generic_gamepad].each do |device|
  %w[left right up down jump attack interact pause].each do |meaning|
    assert_contract!(supported.fetch(device).fetch(meaning).is_a?(Array), "#{device} #{meaning} mapping is not an array")
    assert_contract!(!supported.fetch(device).fetch(meaning).empty?, "#{device} #{meaning} mapping is empty")
  end
end

boundary = spec.fetch('engine_boundary')
%w[key_down key_up button_down button_up axis pointer_move mouse_down mouse_up right_mouse_down right_mouse_up frame].each do |event_type|
  assert_contract!(boundary.fetch('host_event_types').include?(event_type), "#{event_type} event is missing")
end
%w[move move_3d move_toward_pointer move_with_collisions face_pointer open_context input_action].each do |command|
  assert_contract!(boundary.fetch('host_commands').include?(command), "#{command} host command is missing")
end

exclusions = spec.fetch('explicit_exclusions')
[
  'no controller remapping UI',
  'no per-player custom remapping syntax',
  'no platform-specific driver layer',
  'no engine bridge',
  'no Profile 8',
  'no Ruby replacement'
].each do |exclusion|
  assert_contract!(exclusions.include?(exclusion), "#{exclusion} exclusion is missing")
end

%w[Keyboard mouse PS5 Xbox Generic jump attack interact pause].each do |word|
  assert_contract!(doc.include?(word), "#{word} documentation is missing")
end

puts "BASIC# Input Device Contract v#{BasicSharp::VERSION}: PASS"
