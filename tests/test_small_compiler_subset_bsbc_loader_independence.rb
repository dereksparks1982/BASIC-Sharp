# frozen_string_literal: true

require 'digest'
require 'json'
require 'minitest/autorun'
require_relative '../compiler/small_compiler_subset_ir_emitter'
require_relative '../compiler/small_compiler_subset_bsbc_encoder'
require_relative '../compiler/small_compiler_subset_bsbc_loader'
require_relative '../compiler/bytecode_loader'
require_relative '../compiler/small_compiler_subset_bsbc_execution_parity'

class TestSmallCompilerSubsetBSBCLoaderIndependence < Minitest::Test
  ROOT = File.expand_path('..', __dir__)
  SPEC_PATH = File.join(ROOT, 'spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_BSBC_LOADER_INDEPENDENCE_v1.json')

  def spec
    @spec ||= JSON.parse(File.read(SPEC_PATH, encoding: 'UTF-8'))
  end

  def fixture
    spec.fetch('fixture')
  end

  def source
    File.read(File.join(ROOT, fixture.fetch('source_path')), encoding: 'UTF-8')
  end

  def encoder
    ir = BasicSharp::SmallCompilerSubsetIREmitter.new(source)
    BasicSharp::SmallCompilerSubsetBSBCEncoder.new(ir.bsharp_ir)
  end

  def normalize(value)
    case value
    when Hash then value.each_with_object({}) { |(key, child), result| result[key.to_s] = normalize(child) }.sort.to_h
    when Array then value.map { |child| normalize(child) }
    else value
    end
  end

  def test_contract_identity_and_live_version
    assert_equal 'bsharp.small_compiler_subset.bsbc_loader_independence.contract.json', spec.fetch('format')
    assert_equal 1, spec.fetch('format_version')
    assert_equal '0.0.84', BasicSharp::VERSION
    assert_equal BasicSharp::VERSION, spec.fetch('target_version')
    assert_equal 'bsbc_loader_independent_under_ruby_referee', spec.fetch('status')
  end

  def test_loader_source_has_no_production_loader_dependency
    text = File.read(File.join(ROOT, 'compiler/small_compiler_subset_bsbc_loader.rb'), encoding: 'UTF-8')
    refute_includes text, "require_relative 'bytecode_loader'"
    refute_match(/\bBytecodeLoader\.new\b/, text)
    refute_match(/class\s+SmallCompilerSubsetBSBCLoader\s*<\s*BytecodeLoader/, text)
  end

  def test_valid_model_summary_fingerprint_and_disassembly_match_referee
    artifact = encoder
    subset = BasicSharp::SmallCompilerSubsetBSBCLoader.new(artifact.binary, expected_fingerprint: artifact.fingerprint)
    referee = BasicSharp::BytecodeLoader.new(artifact.binary, expected_fingerprint: artifact.fingerprint)
    assert_equal normalize(referee.model), normalize(subset.model)
    assert_equal normalize(referee.summary), normalize(subset.summary)
    assert_equal referee.fingerprint, subset.fingerprint
    assert_equal referee.disassembly, subset.disassembly
  end

  def test_dedicated_fixture_is_locked
    artifact = encoder
    assert_equal fixture.fetch('expected_profile'), artifact.profile
    assert_equal fixture.fetch('expected_binary_bytes'), artifact.binary.bytesize
    assert_equal fixture.fetch('expected_binary_sha256'), Digest::SHA256.hexdigest(artifact.binary)
    assert_equal fixture.fetch('expected_fingerprint'), artifact.fingerprint
  end

  def test_subset_loader_still_loads_when_production_constructor_is_disabled
    artifact = encoder
    klass = BasicSharp::BytecodeLoader
    klass.singleton_class.class_eval do
      alias_method :__v076_test_original_new, :new
      define_method(:new) { |*| raise 'production loader invoked' }
    end
    begin
      loaded = BasicSharp::SmallCompilerSubsetBSBCLoader.new(artifact.binary, expected_fingerprint: artifact.fingerprint)
      assert_equal artifact.fingerprint, loaded.fingerprint
    ensure
      klass.singleton_class.class_eval do
        alias_method :new, :__v076_test_original_new
        remove_method :__v076_test_original_new
      end
    end
  end

  def test_malformed_campaign_is_sealed_and_broad
    expected = %w[
      bad_magic unsupported_profile bad_section_offset overlapping_sections truncated_string_record
      invalid_string_index invalid_kind_index invalid_thing_index invalid_opcode invalid_selector
      invalid_condition invalid_operand_width bad_instruction_target incorrect_record_count
      truncated_artifact trailing_invalid_data
    ]
    assert_equal expected, spec.fetch('malformed_campaign')
    assert_operator expected.length, :>=, 16
  end

  def test_execution_parity_routes_subset_loaded_model_into_vm_engine
    text = File.read(File.join(ROOT, 'compiler/small_compiler_subset_bsbc_execution_parity.rb'), encoding: 'UTF-8')
    assert_includes text, 'SmallCompilerSubsetBSBCLoader.new'
    assert_includes text, 'SmallCompilerSubsetBSBCVirtualMachine.new(subset_loader)'
  end

  def test_trial_by_fire_inventory_runs_loader_independence_gate
    inventory = JSON.parse(File.read(File.join(ROOT, 'spec/trial_by_fire/BASIC_SHARP_TRIAL_BY_FIRE_VALIDATION_INVENTORY_v1.json'), encoding: 'UTF-8'))
    tools = inventory.fetch('required_tools').map { |entry| entry.fetch('path') }
    assert_includes tools, 'tools/small_compiler_subset_bsbc_loader_independence.rb'
  end
end
