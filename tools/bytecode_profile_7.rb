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
profile = BasicSharp::BytecodeContract.load_profile(File.join(root, 'spec/bytecode_v7/BASIC_SHARP_BYTECODE_PROFILE_v7.json'))
BasicSharp::BytecodeContract.validate_profile!(profile, root: root)
parser = BasicSharp::Parser.new(File.read(File.join(root, 'samples/otherwise_branches.bsharp'), encoding: 'UTF-8'))
document = BasicSharp::SemanticResolver.new(parser.parse, dictionary: parser.dictionary).resolve
emitter = BasicSharp::BytecodeEmitter.new(document)
loader = BasicSharp::BytecodeLoader.new(emitter.binary)
fixture = JSON.parse(File.read(File.join(root, 'spec/bytecode_v7/BASIC_SHARP_BYTECODE_PROFILE_v7_FIXTURES_v1.json'), encoding: 'UTF-8'))
raise 'Profile 7 binary hash changed' unless Digest::SHA256.hexdigest(emitter.binary) == fixture.fetch('binary_sha256')
raise 'Profile 7 disassembly hash changed' unless Digest::SHA256.hexdigest(emitter.disassembly) == fixture.fetch('disassembly_sha256')
raise 'Profile 7 loader mismatch' unless loader.model.fetch(:profile) == 'bsharp.bytecode.v7'
raise 'Profile 7 OTHERWISE block missing' unless emitter.disassembly.include?('OTHERWISE BLOCK')
puts 'BSharp Bytecode Profile 7: PASS'
