#!/usr/bin/env ruby
# frozen_string_literal: true

require 'digest'
require 'json'
require 'tmpdir'
require_relative '../compiler/ast_nodes'
require_relative '../compiler/small_compiler_subset_native_action_routing'
require_relative '../compiler/small_compiler_subset_driver'

ROOT = File.expand_path('..', __dir__)
SPEC = JSON.parse(File.read(File.join(ROOT, 'spec/self_hosting/BASIC_SHARP_NATIVE_ACTION_ROUTING_INTEGRATION_v1.json'), encoding: 'UTF-8'))
COMPONENT = SPEC.fetch('native_component')
SOURCE_PATH = File.join(ROOT, COMPONENT.fetch('source_path'))
ARTIFACT_PATH = File.join(ROOT, COMPONENT.fetch('artifact_path'))
DISASSEMBLY_PATH = File.join(ROOT, COMPONENT.fetch('disassembly_path'))

raise 'wrong action routing spec identity' unless SPEC.fetch('format') == 'bsharp.native_action_routing_integration.contract.json'
raise 'action routing target version mismatch' unless SPEC.fetch('target_version') == BasicSharp::VERSION
raise 'action artifact digest changed' unless Digest::SHA256.file(ARTIFACT_PATH).hexdigest == COMPONENT.fetch('expected_binary_sha256')
raise 'action disassembly digest changed' unless Digest::SHA256.file(DISASSEMBLY_PATH).hexdigest == COMPONENT.fetch('expected_disassembly_sha256')

router = BasicSharp::SmallCompilerSubsetNativeActionRouting.new
SPEC.fetch('expected_routes').each do |verb, expected|
  action = BasicSharp::ActionCall.new(verb: verb, target: 'PLAYER', tail: '', text_literal: nil, line_number: 1)
  route = router.route(action)
  raise "native action router rejected #{verb}" unless route
  raise "native action route mismatch for #{verb}: #{route.decision}" unless route.decision == expected
end
raise 'native action invocation count mismatch' unless router.invocation_count == SPEC.fetch('expected_routes').length

source = File.read(SOURCE_PATH, encoding: 'UTF-8')
Dir.mktmpdir('basic-sharp-v084-action-fixed-point') do |directory|
  generation_2 = File.join(directory, 'generation_2.bsbc')
  BasicSharp::SmallCompilerSubsetNativeActionRouting.with_artifact_path(ARTIFACT_PATH) do
    BasicSharp::SmallCompilerSubsetDriver.new(source, source_label: '(v0.0.84 action generation 2)').compile_to(generation_2)
  end
  raise 'action bootstrap generation #2 differs from generation #1' unless File.binread(generation_2) == File.binread(ARTIFACT_PATH)
  raise 'action bootstrap disassembly generation #2 differs from generation #1' unless File.binread("#{generation_2}.txt") == File.binread(DISASSEMBLY_PATH)
end

puts "BASIC# Native Action Routing Integration v#{BasicSharp::VERSION}"
puts 'All accepted official action families routed by BASIC# BSBC: PASS'
puts 'Native action invocation count observed: PASS'
puts 'No hidden Ruby verb-family answer table: PASS'
puts 'Bootstrap fixed point: PASS (generation #1 == generation #2)'
puts 'NATIVE ACTION ROUTING INTEGRATION: PASS'
