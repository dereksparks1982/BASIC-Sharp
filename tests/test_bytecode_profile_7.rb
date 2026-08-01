# frozen_string_literal: true

require 'digest'
require 'json'
require 'minitest/autorun'
require_relative '../compiler/parser'
require_relative '../compiler/resolver'
require_relative '../compiler/bytecode_contract'
require_relative '../compiler/bytecode_emitter'
require_relative '../compiler/bytecode_loader'

class BytecodeProfile7Test < Minitest::Test
  ROOT = File.expand_path('..', __dir__)

  def test_profile_7_contract_and_fixture
    profile = BasicSharp::BytecodeContract.load_profile(File.join(ROOT, 'spec/bytecode_v7/BASIC_SHARP_BYTECODE_PROFILE_v7.json'))
    BasicSharp::BytecodeContract.validate_profile!(profile, root: ROOT)
    assert_equal 'bsharp.bytecode.v7', profile.dig('artifact', 'profile')

    emitter = emitter_for('otherwise_branches')
    fixture = JSON.parse(File.read(File.join(ROOT, 'spec/bytecode_v7/BASIC_SHARP_BYTECODE_PROFILE_v7_FIXTURES_v1.json')))
    assert_equal fixture.fetch('binary_sha256'), Digest::SHA256.hexdigest(emitter.binary)
    assert_equal fixture.fetch('disassembly_sha256'), Digest::SHA256.hexdigest(emitter.disassembly)
    assert_includes emitter.disassembly, 'OTHERWISE BLOCK'
  end

  def test_loader_reconstructs_otherwise_block_reference
    model = BasicSharp::BytecodeLoader.new(emitter_for('otherwise_branches').binary).model
    rule = model.fetch(:if_rules).first
    assert_equal 'bsharp.bytecode.v7', model.fetch(:profile)
    assert_equal 'bsharp.meaning.v7', model.fetch(:meaning_profile)
    refute_equal BasicSharp::BytecodeContract::NO_REFERENCE_U32, rule.fetch(:otherwise_block_index)
    assert model.fetch(:blocks).any? { |block| block.fetch(:id) == rule.fetch(:otherwise_block_index) }
  end

  def test_profiles_1_through_6_samples_remain_byte_identical
    %w[ask_demo every_guard first_room follow_up_events values_and_amounts world_save_demo text_values demon_killer_controls platform_movement number_changes compound_if_conditions].each do |name|
      emitter = emitter_for(name)
      assert_equal File.binread(File.join(ROOT, "samples/#{name}.bsbc")), emitter.binary, "#{name}.bsbc changed"
      assert_equal File.read(File.join(ROOT, "samples/#{name}.bsbc.txt")), emitter.disassembly, "#{name}.bsbc.txt changed"
    end
  end

  def test_loader_rejects_noncanonical_otherwise_block_reference
    bytes = emitter_for('otherwise_branches').binary.dup
    ifrl_offset = nil
    bytes.byteslice(12, 4).unpack1('V').times do |index|
      row = bytes.byteslice(32 + index * 16, 16)
      section_id, offset = row.byteslice(0, 4), row.byteslice(4, 4).unpack1('V')
      ifrl_offset = offset if section_id == 'IFRL'
    end
    refute_nil ifrl_offset
    bytes[ifrl_offset + 16, 4] = [0].pack('V')
    error = assert_raises(BasicSharp::BytecodeLoaderError) { BasicSharp::BytecodeLoader.new(bytes) }
    assert_includes error.message, 'OTHERWISE block order is not canonical'
  end

  private

  def emitter_for(name)
    parser = BasicSharp::Parser.new(File.read(File.join(ROOT, "samples/#{name}.bsharp")))
    document = BasicSharp::SemanticResolver.new(parser.parse, dictionary: parser.dictionary).resolve
    BasicSharp::BytecodeEmitter.new(document)
  end
end
