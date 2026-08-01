# frozen_string_literal: true

require 'digest'
require 'json'
require 'minitest/autorun'
require_relative '../compiler/parser'
require_relative '../compiler/resolver'
require_relative '../compiler/bytecode_contract'
require_relative '../compiler/bytecode_emitter'
require_relative '../compiler/bytecode_loader'

class BytecodeProfile6Test < Minitest::Test
  ROOT = File.expand_path('..', __dir__)

  def test_profile_6_contract_and_fixture
    profile = BasicSharp::BytecodeContract.load_profile(File.join(ROOT, 'spec/bytecode_v6/BASIC_SHARP_BYTECODE_PROFILE_v6.json'))
    BasicSharp::BytecodeContract.validate_profile!(profile, root: ROOT)
    assert_equal 'bsharp.bytecode.v6', profile.dig('artifact', 'profile')
    assert_equal %w[ALL_CONDITIONS ANY_CONDITIONS], profile.fetch('conditions').last(2).map { |entry| entry.fetch('name') }

    emitter = emitter_for('compound_if_conditions')
    fixture = JSON.parse(File.read(File.join(ROOT, 'spec/bytecode_v6/BASIC_SHARP_BYTECODE_PROFILE_v6_FIXTURES_v1.json')))
    assert_equal fixture.fetch('binary_sha256'), Digest::SHA256.hexdigest(emitter.binary)
    assert_equal fixture.fetch('disassembly_sha256'), Digest::SHA256.hexdigest(emitter.disassembly)
    assert_includes emitter.disassembly, 'ALL_CONDITIONS'
    assert_includes emitter.disassembly, 'ANY_CONDITIONS'
  end

  def test_loader_reconstructs_compound_condition_groups
    model = BasicSharp::BytecodeLoader.new(emitter_for('compound_if_conditions').binary).model
    assert_equal 'bsharp.bytecode.v6', model.fetch(:profile)
    assert_equal 'bsharp.meaning.v6', model.fetch(:meaning_profile)
    assert_equal %w[ALL_CONDITIONS ANY_CONDITIONS], model.fetch(:if_rules).map { |rule| rule.fetch(:condition).fetch(:name) }
    assert_equal [2, 2], model.fetch(:if_rules).map { |rule| rule.fetch(:condition).fetch(:clauses).length }
  end

  def test_profiles_1_through_5_samples_remain_byte_identical
    %w[ask_demo every_guard first_room follow_up_events values_and_amounts world_save_demo text_values demon_killer_controls platform_movement number_changes].each do |name|
      emitter = emitter_for(name)
      assert_equal File.binread(File.join(ROOT, "samples/#{name}.bsbc")), emitter.binary, "#{name}.bsbc changed"
      assert_equal File.read(File.join(ROOT, "samples/#{name}.bsbc.txt")), emitter.disassembly, "#{name}.bsbc.txt changed"
    end
  end

  def test_loader_rejects_a_compound_group_with_fewer_than_two_clauses
    bytes = emitter_for('compound_if_conditions').binary.dup
    ifrl_offset = nil
    bytes.byteslice(12, 4).unpack1('V').times do |index|
      row = bytes.byteslice(32 + index * 16, 16)
      section_id, offset = row.byteslice(0, 4), row.byteslice(4, 4).unpack1('V')
      ifrl_offset = offset if section_id == 'IFRL'
    end
    refute_nil ifrl_offset
    bytes[ifrl_offset + 4, 4] = [1].pack('V')
    error = assert_raises(BasicSharp::BytecodeLoaderError) { BasicSharp::BytecodeLoader.new(bytes) }
    assert_includes error.message, 'at least two clauses'
  end

  private

  def emitter_for(name)
    parser = BasicSharp::Parser.new(File.read(File.join(ROOT, "samples/#{name}.bsharp")))
    document = BasicSharp::SemanticResolver.new(parser.parse, dictionary: parser.dictionary).resolve
    BasicSharp::BytecodeEmitter.new(document)
  end
end
