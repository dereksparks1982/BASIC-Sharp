# frozen_string_literal: true

require 'digest'
require 'json'
require 'minitest/autorun'
require_relative '../compiler/parser'
require_relative '../compiler/resolver'
require_relative '../compiler/bytecode_contract'
require_relative '../compiler/bytecode_emitter'
require_relative '../compiler/bytecode_loader'

class TestBytecodeProfile4 < Minitest::Test
  ROOT = File.expand_path('..', __dir__)

  def emitter
    parser = BasicSharp::Parser.new(File.read(File.join(ROOT, 'samples/platform_movement.bsharp')))
    document = BasicSharp::SemanticResolver.new(parser.parse, dictionary: parser.dictionary).resolve
    BasicSharp::BytecodeEmitter.new(document)
  end

  def test_profile_contract_and_fixture_hashes
    profile = BasicSharp::BytecodeContract.load_profile(File.join(ROOT, 'spec/bytecode_v4/BASIC_SHARP_BYTECODE_PROFILE_v4.json'))
    assert BasicSharp::BytecodeContract.validate_profile!(profile, root: ROOT)
    fixture = JSON.parse(File.read(File.join(ROOT, 'spec/bytecode_v4/BASIC_SHARP_BYTECODE_PROFILE_v4_FIXTURES_v1.json')))
    assert_equal fixture.fetch('binary_sha256'), Digest::SHA256.hexdigest(emitter.binary)
    assert_equal fixture.fetch('disassembly_sha256'), Digest::SHA256.hexdigest(emitter.disassembly)
    assert_equal fixture.fetch('fingerprint'), emitter.fingerprint
  end

  def test_loader_requires_profile_4_and_preserves_platform_controls
    binary = emitter.binary
    raise 'Profile 4 must use profile format version 4' unless binary.byteslice(6, 2).unpack1('v') == 4
    loader = BasicSharp::BytecodeLoader.new(binary)
    assert_equal 'bsharp.bytecode.v4', loader.model.fetch(:profile)
    assert_equal 'bsharp.meaning.v4', loader.model.fetch(:meaning_profile)
    instructions = loader.model.fetch(:controls).fetch(0).fetch(:instructions)
    assert_equal %w[platform_move platform_move platform_jump], instructions.map { |entry| entry.fetch(:type) }
    assert_includes loader.disassembly, 'PLATFORM_MOVE direction=left key=A speed=6'
    assert_includes loader.disassembly, 'PLATFORM_JUMP key=SPACE speed=10'
  end

  def test_profile_1_through_3_committed_artifacts_remain_byte_identical
    %w[ask_demo every_guard first_room follow_up_events values_and_amounts world_save_demo text_values demon_killer_controls].each do |name|
      parser = BasicSharp::Parser.new(File.read(File.join(ROOT, "samples/#{name}.bsharp")))
      document = BasicSharp::SemanticResolver.new(parser.parse, dictionary: parser.dictionary).resolve
      expected = Digest::SHA256.hexdigest(File.binread(File.join(ROOT, "samples/#{name}.bsbc")))
      assert_equal expected, Digest::SHA256.hexdigest(BasicSharp::BytecodeEmitter.new(document).binary), name
    end
  end
end
