# frozen_string_literal: true

require 'digest'
require 'json'
require 'minitest/autorun'
require 'tmpdir'
require_relative '../compiler/small_compiler_subset_driver'
require_relative '../compiler/small_compiler_subset_ir_emitter'
require_relative '../compiler/small_compiler_subset_native_symbol_resolution'
require_relative '../compiler/parser'
require_relative '../compiler/resolver'

class TestNativeSymbolResolutionIntegration < Minitest::Test
  ROOT = File.expand_path('..', __dir__)
  SPEC = JSON.parse(File.read(File.join(ROOT, 'spec/self_hosting/BASIC_SHARP_NATIVE_SYMBOL_RESOLUTION_INTEGRATION_v1.json'), encoding: 'UTF-8'))
  COMPONENT = SPEC.fetch('native_component')
  SOURCE_PATH = File.join(ROOT, COMPONENT.fetch('source_path'))
  ARTIFACT_PATH = File.join(ROOT, COMPONENT.fetch('artifact_path'))
  DISASSEMBLY_PATH = File.join(ROOT, COMPONENT.fetch('disassembly_path'))
  TRIAL_SOURCE = File.read(File.join(ROOT, 'samples/trial_by_fire.bsharp'), encoding: 'UTF-8')

  def compile_sabotage(from, to, source: TRIAL_SOURCE)
    component = File.read(SOURCE_PATH, encoding: 'UTF-8')
    sabotage = component.sub(from, to)
    refute_equal component, sabotage
    Dir.mktmpdir('basic-sharp-v083-symbol-sabotage') do |directory|
      artifact = File.join(directory, 'symbol_sabotage.bsbc')
      BasicSharp::SmallCompilerSubsetDriver.new(sabotage).compile_to(artifact)
      resolver = BasicSharp::SmallCompilerSubsetNativeSymbolResolution.new(artifact_path: artifact)
      yield resolver, source
    end
  end

  def test_contract_and_checked_in_artifact
    assert_equal 'bsharp.native_symbol_resolution_integration.contract.json', SPEC.fetch('format')
    assert_equal BasicSharp::VERSION, SPEC.fetch('target_version')
    assert_equal COMPONENT.fetch('expected_binary_sha256'), Digest::SHA256.file(ARTIFACT_PATH).hexdigest
    assert_equal COMPONENT.fetch('expected_disassembly_sha256'), Digest::SHA256.file(DISASSEMBLY_PATH).hexdigest
  end

  def test_all_fifteen_symbol_decisions_are_native
    resolver = BasicSharp::SmallCompilerSubsetNativeSymbolResolution.new
    decisions = BasicSharp::SmallCompilerSubsetNativeSymbolResolution::PROBES.keys.to_h do |probe|
      [probe.to_s, resolver.decide(probe).decision]
    end
    assert_equal COMPONENT.fetch('expected_decisions'), decisions
    assert_equal 15, resolver.invocation_count
    assert_equal 15, resolver.matched_count
  end

  def test_primary_pipeline_observes_all_three_native_stages
    driver = BasicSharp::SmallCompilerSubsetDriver.new(TRIAL_SOURCE)
    assert_operator driver.native_dispatch_invocation_count, :>, 0
    assert_operator driver.native_semantic_invocation_count, :>, 0
    assert_operator driver.native_symbol_invocation_count, :>, 0
    assert_equal driver.pipeline.bsharp_ir, driver.pipeline.ir_emitter.ruby_referee_bsharp_ir
    refute_empty driver.pipeline.binary
    assert driver.execute_in_memory(['player sounds brass bell'])
  end

  def test_known_kind_sabotage_fails_closed
    compile_sabotage('"resolve-known-kind"', '"reject-unknown-kind"') do |bad, source|
      error = assert_raises(BasicSharp::SmallCompilerSubsetNativeSymbolResolutionError) do
        BasicSharp::SmallCompilerSubsetNativeSymbolResolution.with_artifact_path(bad.artifact_path) do
          BasicSharp::SmallCompilerSubsetDriver.new(source)
        end
      end
      assert_includes error.message, 'expected'
    end
  end

  def test_unknown_thing_sabotage_fails_closed
    source = "KINDS\n[\n#thing\n#door is a #thing\n].\nWHEN PLAYER opens @ghost\n[\n|then (sound bell\n].\n"
    compile_sabotage('"reject-unknown-thing"', '"resolve-known-thing"', source: source) do |bad, candidate|
      error = assert_raises(BasicSharp::SmallCompilerSubsetNativeSymbolResolutionError) do
        BasicSharp::SmallCompilerSubsetNativeSymbolResolution.with_artifact_path(bad.artifact_path) do
          BasicSharp::SmallCompilerSubsetDriver.new(candidate).pipeline.bsharp_ir
        end
      end
      assert_includes error.message, 'expected'
    end
  end

  def test_duplicate_thing_sabotage_fails_closed
    source = "KINDS\n[\n#thing\n#door is a #thing\n].\nDEFINE\n[\n@north door is a #door\n@north door is a #door\n].\n"
    compile_sabotage('"reject-duplicate-thing"', '"accept-unique-thing"', source: source) do |bad, candidate|
      error = assert_raises(BasicSharp::SmallCompilerSubsetNativeSymbolResolutionError) do
        BasicSharp::SmallCompilerSubsetNativeSymbolResolution.with_artifact_path(bad.artifact_path) do
          BasicSharp::SmallCompilerSubsetDriver.new(candidate).pipeline.bsharp_ir
        end
      end
      assert_includes error.message, 'expected'
    end
  end

  def test_invalid_kind_link_sabotage_fails_closed
    source = "KINDS\n[\n#thing\n#spirit door is a #ghost\n].\n"
    compile_sabotage('"reject-kind-link"', '"accept-kind-link"', source: source) do |bad, candidate|
      error = assert_raises(BasicSharp::SmallCompilerSubsetNativeSymbolResolutionError) do
        BasicSharp::SmallCompilerSubsetNativeSymbolResolution.with_artifact_path(bad.artifact_path) do
          BasicSharp::SmallCompilerSubsetDriver.new(candidate).pipeline.bsharp_ir
        end
      end
      assert_includes error.message, 'expected'
    end
  end

  def test_unrecognized_probe_fails_closed
    resolver = BasicSharp::SmallCompilerSubsetNativeSymbolResolution.new
    assert_raises(BasicSharp::SmallCompilerSubsetNativeSymbolResolutionError) { resolver.decide(:not_a_symbol_probe) }
  end

  def test_generation_two_is_byte_identical_fixed_point
    source = File.read(SOURCE_PATH, encoding: 'UTF-8')
    Dir.mktmpdir('basic-sharp-v083-symbol-fixed-point') do |directory|
      generation_2 = File.join(directory, 'generation_2.bsbc')
      BasicSharp::SmallCompilerSubsetNativeSymbolResolution.with_artifact_path(ARTIFACT_PATH) do
        BasicSharp::SmallCompilerSubsetDriver.new(source, source_label: '(v0.1.84 symbol generation 2)').compile_to(generation_2)
      end
      assert_equal File.binread(ARTIFACT_PATH), File.binread(generation_2)
      assert_equal File.binread(DISASSEMBLY_PATH), File.binread("#{generation_2}.txt")
    end
  end

  def test_production_semantic_resolver_is_referee_only
    emitter = BasicSharp::SmallCompilerSubsetIREmitter.new(TRIAL_SOURCE)
    independent = emitter.bsharp_ir
    parser = BasicSharp::Parser.new(TRIAL_SOURCE)
    production = BasicSharp::SemanticResolver.new(parser.parse, dictionary: parser.dictionary).resolve.to_h
    assert_equal production, independent
  end
end
