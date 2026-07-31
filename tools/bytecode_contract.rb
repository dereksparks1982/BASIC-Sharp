#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../compiler/bytecode_contract'

root = File.expand_path('..', __dir__)
path = File.join(root, 'spec/bytecode_v1/BASIC_SHARP_BYTECODE_PROFILE_v1.json')
profile = BasicSharp::BytecodeContract.load_profile(path)
BasicSharp::BytecodeContract.validate_profile!(profile, root: root)

puts 'BSharp Bytecode Contract v1'
puts 'Artifact identity: PASS'
puts 'Header and section directory: PASS'
puts 'Section layout: PASS'
puts 'Instruction identities: PASS'
puts 'Selector and condition identities: PASS'
puts 'Operand contracts: PASS'
puts 'Reserved ranges: PASS'
puts 'Profile 1 coverage: PASS'
puts 'Readable disassembly grammar: PASS'
puts 'Malformed-bytecode rules: PASS'
puts 'Deterministic contract: PASS'
puts 'No Ruby-specific serialized data: PASS'
puts
puts 'BYTECODE CONTRACT: PASS'
