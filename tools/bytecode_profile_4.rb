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
profile = BasicSharp::BytecodeContract.load_profile(File.join(root, 'spec/bytecode_v4/BASIC_SHARP_BYTECODE_PROFILE_v4.json'))
BasicSharp::BytecodeContract.validate_profile!(profile, root: root)
parser = BasicSharp::Parser.new(File.read(File.join(root, 'samples/platform_movement.bsharp')))
document = BasicSharp::SemanticResolver.new(parser.parse, dictionary: parser.dictionary).resolve
emitter = BasicSharp::BytecodeEmitter.new(document)
loader = BasicSharp::BytecodeLoader.new(emitter.binary)
fixture = JSON.parse(File.read(File.join(root, 'spec/bytecode_v4/BASIC_SHARP_BYTECODE_PROFILE_v4_FIXTURES_v1.json')))
raise 'Profile 4 binary hash changed' unless Digest::SHA256.hexdigest(emitter.binary) == fixture.fetch('binary_sha256')
raise 'Profile 4 disassembly hash changed' unless Digest::SHA256.hexdigest(emitter.disassembly) == fixture.fetch('disassembly_sha256')
raise 'Profile 4 loader mismatch' unless loader.model.fetch(:profile) == 'bsharp.bytecode.v4'
puts 'BSharp Bytecode Profile 4: PASS'
