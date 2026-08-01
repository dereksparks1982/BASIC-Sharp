# frozen_string_literal: true

require 'digest'
require 'json'
require 'minitest/autorun'
require_relative '../compiler/parser'
require_relative '../compiler/resolver'
require_relative '../compiler/bytecode_contract'
require_relative '../compiler/bytecode_emitter'
require_relative '../compiler/bytecode_loader'

class TestBytecodeProfile3 < Minitest::Test
  ROOT = File.expand_path('..', __dir__)

  def emitter
    parser = BasicSharp::Parser.new(File.read(File.join(ROOT, 'samples/demon_killer_controls.bsharp')))
    document = BasicSharp::SemanticResolver.new(parser.parse, dictionary: parser.dictionary).resolve
    BasicSharp::BytecodeEmitter.new(document)
  end

  def test_profile_contract_and_fixture_hashes
    profile = BasicSharp::BytecodeContract.load_profile(File.join(ROOT, 'spec/bytecode_v3/BASIC_SHARP_BYTECODE_PROFILE_v3.json'))
    assert BasicSharp::BytecodeContract.validate_profile!(profile, root: ROOT)
    fixture = JSON.parse(File.read(File.join(ROOT, 'spec/bytecode_v3/BASIC_SHARP_BYTECODE_PROFILE_v3_FIXTURES_v1.json')))
    assert_equal fixture.fetch('binary_sha256'), Digest::SHA256.hexdigest(emitter.binary)
    assert_equal fixture.fetch('disassembly_sha256'), Digest::SHA256.hexdigest(emitter.disassembly)
  end

  def test_loader_validates_all_profile_3_sections
    loader = BasicSharp::BytecodeLoader.new(emitter.binary)
    assert_equal 'bsharp.bytecode.v3', loader.model.fetch(:profile)
    assert_equal 1, loader.model.fetch(:controls).length
    assert_equal 1, loader.model.fetch(:hover_declarations).length
    assert_equal 1, loader.model.fetch(:context_declarations).length
    assert_includes loader.disassembly, 'CONTROLS THING[player]'
    assert_includes loader.disassembly, 'CONTEXT KIND[door]'
  end

  def test_profile_1_and_profile_2_committed_artifacts_remain_byte_identical
    %w[ask_demo every_guard first_room follow_up_events values_and_amounts world_save_demo text_values].each do |name|
      parser = BasicSharp::Parser.new(File.read(File.join(ROOT, "samples/#{name}.bsharp")))
      document = BasicSharp::SemanticResolver.new(parser.parse, dictionary: parser.dictionary).resolve
      expected = Digest::SHA256.hexdigest(File.binread(File.join(ROOT, "samples/#{name}.bsbc")))
      actual = Digest::SHA256.hexdigest(BasicSharp::BytecodeEmitter.new(document).binary)
      assert_equal expected, actual, name
    end
  end
end
