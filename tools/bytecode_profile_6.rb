#!/usr/bin/env ruby
# frozen_string_literal: true

require 'digest'
require 'json'
require_relative '../compiler/parser'
require_relative '../compiler/resolver'
require_relative '../compiler/bytecode_contract'
require_relative '../compiler/bytecode_emitter'
require_relative '../compiler/bytecode_loader'

root = File.expand_path('..', __dir__)
profile = BasicSharp::BytecodeContract.load_profile(File.join(root, 'spec/bytecode_v6/BASIC_SHARP_BYTECODE_PROFILE_v6.json'))
BasicSharp::BytecodeContract.validate_profile!(profile, root: root)
parser = BasicSharp::Parser.new(File.read(File.join(root, 'samples/compound_if_conditions.bsharp'), encoding: 'UTF-8'))
document = BasicSharp::SemanticResolver.new(parser.parse, dictionary: parser.dictionary).resolve
emitter = BasicSharp::BytecodeEmitter.new(document)
loader = BasicSharp::BytecodeLoader.new(emitter.binary)
fixture = JSON.parse(File.read(File.join(root, 'spec/bytecode_v6/BASIC_SHARP_BYTECODE_PROFILE_v6_FIXTURES_v1.json'), encoding: 'UTF-8'))
raise 'Profile 6 binary hash changed' unless Digest::SHA256.hexdigest(emitter.binary) == fixture.fetch('binary_sha256')
raise 'Profile 6 disassembly hash changed' unless Digest::SHA256.hexdigest(emitter.disassembly) == fixture.fetch('disassembly_sha256')
raise 'Profile 6 loader mismatch' unless loader.model.fetch(:profile) == 'bsharp.bytecode.v6'
raise 'Profile 6 ALL_CONDITIONS missing' unless emitter.disassembly.include?('ALL_CONDITIONS')
raise 'Profile 6 ANY_CONDITIONS missing' unless emitter.disassembly.include?('ANY_CONDITIONS')
puts 'BSharp Bytecode Profile 6: PASS'
