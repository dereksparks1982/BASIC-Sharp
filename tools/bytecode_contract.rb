#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../compiler/bytecode_contract'

root = File.expand_path('..', __dir__)
path = File.join(root, 'spec/bytecode_v1/BASIC_SHARP_BYTECODE_PROFILE_v1.json')
profile = BasicSharp::BytecodeContract.load_profile(path)
BasicSharp::BytecodeContract.validate_profile!(profile, root: root)
profile_3 = BasicSharp::BytecodeContract.load_profile(File.join(root, 'spec/bytecode_v3/BASIC_SHARP_BYTECODE_PROFILE_v3.json'))
BasicSharp::BytecodeContract.validate_profile!(profile_3, root: root)
profile_4 = BasicSharp::BytecodeContract.load_profile(File.join(root, 'spec/bytecode_v4/BASIC_SHARP_BYTECODE_PROFILE_v4.json'))
BasicSharp::BytecodeContract.validate_profile!(profile_4, root: root)
profile_5 = BasicSharp::BytecodeContract.load_profile(File.join(root, 'spec/bytecode_v5/BASIC_SHARP_BYTECODE_PROFILE_v5.json'))
BasicSharp::BytecodeContract.validate_profile!(profile_5, root: root)

puts 'BSharp Bytecode Contract v1'
puts 'Artifact identity: PASS'
puts 'Header and section directory: PASS'
puts 'Section layout: PASS'
puts 'Instruction identities: PASS'
puts 'Selector and condition identities: PASS'
puts 'Operand contracts: PASS'
puts 'Reserved ranges: PASS'
puts 'Profile 1 coverage: PASS'
puts 'Profile 3 CTRL/HOVR/CTXT coverage: PASS'
puts 'Profile 4 platform movement coverage: PASS'
puts 'Profile 5 number-change and comparison coverage: PASS'
puts 'Readable disassembly grammar: PASS'
puts 'Emission ordering and atomic-output rules: PASS'
puts 'Loader boundary and trusted-model rules: PASS'
puts 'BSharp VM execution and independence rules: PASS'
puts 'Malformed-bytecode rules: PASS'
puts 'Deterministic contract: PASS'
puts 'No Ruby-specific serialized data: PASS'
puts
puts 'BYTECODE CONTRACT: PASS'
