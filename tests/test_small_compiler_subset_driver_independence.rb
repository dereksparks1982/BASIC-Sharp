# frozen_string_literal: true

require 'json'
require 'minitest/autorun'
require 'open3'
require 'rbconfig'
require 'tmpdir'
require_relative '../compiler/small_compiler_subset_driver'
require_relative '../compiler/parser'
require_relative '../compiler/resolver'
require_relative '../compiler/bytecode_emitter'
require_relative '../compiler/bytecode_loader'
require_relative '../compiler/bytecode_virtual_machine'
require_relative '../compiler/runtime'

class TestSmallCompilerSubsetDriverIndependence < Minitest::Test
  ROOT = File.expand_path('..', __dir__)
  SPEC_PATH = File.join(ROOT, 'spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_DRIVER_INDEPENDENCE_v1.json')

  def spec
    @spec ||= JSON.parse(File.read(SPEC_PATH, encoding: 'UTF-8'))
  end

  def fixture
    spec.fetch('fixture')
  end

  def source_path
    File.join(ROOT, fixture.fetch('source_path'))
  end

  def source
    @source ||= File.read(source_path, encoding: 'UTF-8')
  end

  def normalize(value)
    BasicSharp::SmallCompilerSubsetPipeline.normalize(value)
  end

  def semantic(value)
    case value
    when Hash
      value.each_with_object({}) do |(key, child), result|
        key = key.to_s
        next if %w[line_number caused_by_line].include?(key)
        result[key] = semantic(child)
      end.sort.to_h
    when Array then value.map { |child| semantic(child) }
    else value
    end
  end

  def test_contract_identity_and_live_version
    assert_equal 'bsharp.small_compiler_subset.driver_independence.contract.json', spec.fetch('format')
    assert_equal 1, spec.fetch('format_version')
    assert_equal '0.1.83', BasicSharp::VERSION
    assert_equal BasicSharp::VERSION, spec.fetch('target_version')
    assert_equal BasicSharp::SmallCompilerSubsetDriver::STATUS, spec.fetch('status')
  end

  def test_driver_source_names_only_independent_primary_components
    text = File.read(File.join(ROOT, 'compiler/small_compiler_subset_driver.rb'), encoding: 'UTF-8')
    %w[lexer parser resolver bytecode_emitter bytecode_loader bytecode_virtual_machine runtime runtime_transition].each do |name|
      refute_includes text, "require_relative '#{name}'"
    end
    assert_includes text, 'SmallCompilerSubsetPipeline.new'
    refute_match(/\bParser\.new\b/, text)
    refute_match(/\bSemanticResolver\.new\b/, text)
    refute_match(/\bBytecodeEmitter\.new\b/, text)
    refute_match(/\bBytecodeLoader\.new\b/, text)
    refute_match(/\bBytecodeVirtualMachine\.new\b/, text)
    refute_match(/\bRuntime\.new\b/, text)
  end

  def test_driver_reads_source_file_and_owns_pipeline
    driver = BasicSharp::SmallCompilerSubsetDriver.from_file(source_path)
    assert_equal File.expand_path(source_path), driver.source_label
    assert_equal source, driver.source
    assert_instance_of BasicSharp::SmallCompilerSubsetPipeline, driver.pipeline
  end

  def test_constructor_disable_proof_runs_in_isolated_process
    stdout, stderr, status = Open3.capture3(
      RbConfig.ruby,
      'tools/small_compiler_subset_driver_independence.rb',
      chdir: ROOT
    )
    assert status.success?, "driver independence tool failed:\n#{stdout}\n#{stderr}"
    assert_includes stdout, 'Production compiler and runtime constructors disabled on primary path: PASS'
    assert_includes stdout, 'Real BSBC artifact produced: PASS'
    assert_includes stdout, 'SMALL COMPILER SUBSET INDEPENDENT COMPILER DRIVER: PASS'
  end

  def test_driver_writes_locked_real_artifact
    Dir.mktmpdir do |directory|
      driver = BasicSharp::SmallCompilerSubsetDriver.from_file(source_path)
      destination = File.join(directory, fixture.fetch('artifact_name'))
      returned = driver.compile_to(destination)
      assert_same driver, returned
      assert File.file?(destination)
      assert File.file?("#{destination}.txt")
      assert_equal fixture.fetch('expected_binary_bytes'), File.size(destination)
      assert_equal fixture.fetch('expected_binary_sha256'), driver.artifact_sha256
      assert_equal fixture.fetch('expected_binary_sha256'), BasicSharp::SmallCompilerSubsetDriver.digest_binary(driver.pipeline.binary)
      assert_equal driver.pipeline.binary, File.binread(destination)
      assert_equal driver.pipeline.disassembly, File.read("#{destination}.txt", encoding: 'UTF-8')
    end
  end

  def test_driver_record_is_locked
    Dir.mktmpdir do |directory|
      driver = BasicSharp::SmallCompilerSubsetDriver.from_file(source_path)
      driver.compile_to(File.join(directory, fixture.fetch('artifact_name')))
      record = driver.driver_record
      assert_equal 'bsharp.small_compiler_subset.driver.record', record.fetch(:format)
      assert_equal BasicSharp::VERSION, record.fetch(:version)
      assert_equal fixture.fetch('expected_profile'), record.fetch(:profile)
      assert_equal fixture.fetch('expected_source_sha256'), record.fetch(:source_sha256)
      assert_equal fixture.fetch('expected_bsharp_ir_sha256'), record.fetch(:bsharp_ir_sha256)
      assert_equal fixture.fetch('expected_binary_bytes'), record.fetch(:binary_bytes)
      assert_equal fixture.fetch('expected_binary_sha256'), record.fetch(:binary_sha256)
      assert_equal fixture.fetch('expected_binary_sha256'), record.fetch(:artifact_sha256)
      assert_equal fixture.fetch('expected_disassembly_sha256'), record.fetch(:disassembly_sha256)
      assert_equal fixture.fetch('expected_fingerprint'), record.fetch(:fingerprint)
      assert record.fetch(:compiled)
    end
  end

  def test_saved_artifact_uses_independent_loader_and_vm
    Dir.mktmpdir do |directory|
      driver = BasicSharp::SmallCompilerSubsetDriver.from_file(source_path)
      driver.compile_to(File.join(directory, fixture.fetch('artifact_name')))
      assert_instance_of BasicSharp::SmallCompilerSubsetBSBCLoader, driver.artifact_loader
      assert_instance_of BasicSharp::SmallCompilerSubsetBSBCVirtualMachine, driver.artifact_virtual_machine
    end
  end

  def test_saved_artifact_matches_separate_referees
    Dir.mktmpdir do |directory|
      driver = BasicSharp::SmallCompilerSubsetDriver.from_file(source_path)
      driver.compile_to(File.join(directory, fixture.fetch('artifact_name')))

      parser = BasicSharp::Parser.new(source)
      document = BasicSharp::SemanticResolver.new(parser.parse, dictionary: parser.dictionary).resolve.to_h
      emitter = BasicSharp::BytecodeEmitter.new(document)
      loader = BasicSharp::BytecodeLoader.new(emitter.binary, expected_fingerprint: emitter.fingerprint)
      production_vm = BasicSharp::BytecodeVirtualMachine.new(loader)
      ruby_runtime = BasicSharp::Runtime.new(document)

      assert_equal emitter.binary, driver.artifact_bytes
      artifact = driver.execute_artifact(fixture.fetch('events'))
      production_results = fixture.fetch('events').map { |event| production_vm.run_event(event) }
      ruby_results = fixture.fetch('events').map { |event| ruby_runtime.run_event(event) }

      assert_equal normalize(production_results), normalize(artifact.fetch('events'))
      assert_equal semantic(ruby_results), semantic(artifact.fetch('events'))
      assert_equal normalize(production_vm.snapshot), normalize(artifact.fetch('snapshot'))
      assert_equal normalize(ruby_runtime.snapshot), normalize(artifact.fetch('snapshot'))
      assert_equal fixture.fetch('expected_event_results_sha256'), BasicSharp::SmallCompilerSubsetDriver.digest_json(artifact.fetch('events'))
      assert_equal fixture.fetch('expected_final_snapshot_sha256'), BasicSharp::SmallCompilerSubsetDriver.digest_json(artifact.fetch('snapshot'))
      assert_equal fixture.fetch('expected_save_document_sha256'), BasicSharp::SmallCompilerSubsetDriver.digest_json(artifact.fetch('save'))
    end
  end

  def test_profiles_1_through_7_remain_the_allowed_surface
    self_hosting = JSON.parse(File.read(File.join(ROOT, 'spec/self_hosting/BASIC_SHARP_SELF_HOSTING_SUBSET_v1.json'), encoding: 'UTF-8'))
    assert_equal 7, self_hosting.fetch('approved_profiles_available_to_creator_programs').length
    refute_includes JSON.generate(self_hosting.fetch('approved_profiles_available_to_creator_programs')), 'v8'
  end

  def test_trial_by_fire_inventory_runs_driver_gate
    inventory = JSON.parse(File.read(File.join(ROOT, 'spec/trial_by_fire/BASIC_SHARP_TRIAL_BY_FIRE_VALIDATION_INVENTORY_v1.json'), encoding: 'UTF-8'))
    tools = inventory.fetch('required_tools').map { |entry| entry.fetch('path') }
    assert_includes tools, 'tools/small_compiler_subset_driver_independence.rb'
  end
end
