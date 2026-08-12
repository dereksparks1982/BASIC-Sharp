# frozen_string_literal: true

require 'json'
require 'minitest/autorun'
require 'open3'
require 'rbconfig'
require 'tmpdir'
require_relative '../compiler/small_compiler_subset_driver'

class TestSmallCompilerSubsetArtifactRoundTrip < Minitest::Test
  ROOT = File.expand_path('..', __dir__)
  SPEC_PATH = File.join(ROOT, 'spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_ARTIFACT_ROUND_TRIP_v1.json')

  def spec
    @spec ||= JSON.parse(File.read(SPEC_PATH, encoding: 'UTF-8'))
  end

  def driver_spec
    @driver_spec ||= JSON.parse(File.read(File.join(ROOT, spec.fetch('fixture_spec')), encoding: 'UTF-8'))
  end

  def fixture
    driver_spec.fetch('fixture')
  end

  def source_path
    File.join(ROOT, fixture.fetch('source_path'))
  end

  def expected
    spec.fetch('expected')
  end

  def normalize(value)
    BasicSharp::SmallCompilerSubsetPipeline.normalize(value)
  end

  def test_contract_identity_and_live_version
    assert_equal 'bsharp.small_compiler_subset.artifact_round_trip.contract.json', spec.fetch('format')
    assert_equal 1, spec.fetch('format_version')
    assert_equal '0.1.82', BasicSharp::VERSION
    assert_equal BasicSharp::VERSION, spec.fetch('target_version')
    assert_equal 'independent_bsbc_artifact_round_trip_under_ruby_referee', spec.fetch('status')
  end

  def test_round_trip_tool_runs_in_isolated_process
    stdout, stderr, status = Open3.capture3(
      RbConfig.ruby,
      'tools/small_compiler_subset_artifact_round_trip.rb',
      chdir: ROOT
    )
    assert status.success?, "artifact round-trip tool failed:\n#{stdout}\n#{stderr}"
    assert_includes stdout, 'Real BSBC artifact persisted: PASS'
    assert_includes stdout, 'Source file unnecessary after artifact creation: PASS'
    assert_includes stdout, 'SMALL COMPILER SUBSET BSBC ARTIFACT ROUND TRIP: PASS'
  end

  def test_in_memory_and_saved_artifact_execution_are_exact
    Dir.mktmpdir do |directory|
      driver = BasicSharp::SmallCompilerSubsetDriver.from_file(source_path)
      destination = File.join(directory, fixture.fetch('artifact_name'))
      driver.compile_to(destination)
      in_memory = driver.execute_in_memory(fixture.fetch('events'))
      artifact = driver.execute_artifact(fixture.fetch('events'))
      assert_equal normalize(in_memory), normalize(artifact)
      assert_equal expected.fetch('event_results_sha256'), BasicSharp::SmallCompilerSubsetDriver.digest_json(artifact.fetch('events'))
      assert_equal expected.fetch('final_snapshot_sha256'), BasicSharp::SmallCompilerSubsetDriver.digest_json(artifact.fetch('snapshot'))
      assert_equal expected.fetch('save_document_sha256'), BasicSharp::SmallCompilerSubsetDriver.digest_json(artifact.fetch('save'))
    end
  end

  def test_repeated_compilation_is_byte_for_byte_deterministic
    Dir.mktmpdir do |directory|
      reference = nil
      reference_text = nil
      8.times do |index|
        driver = BasicSharp::SmallCompilerSubsetDriver.from_file(source_path)
        destination = File.join(directory, "repeat_#{index}.bsbc")
        driver.compile_to(destination)
        bytes = File.binread(destination)
        text = File.binread("#{destination}.txt")
        reference ||= bytes
        reference_text ||= text
        assert_equal reference, bytes
        assert_equal reference_text, text
        assert_equal expected.fetch('binary_sha256'), BasicSharp::SmallCompilerSubsetDriver.digest_binary(bytes)
      end
    end
  end

  def test_artifact_survives_source_removal
    Dir.mktmpdir do |directory|
      copied_source = File.join(directory, 'program.bsharp')
      File.binwrite(copied_source, File.binread(source_path))
      driver = BasicSharp::SmallCompilerSubsetDriver.from_file(copied_source)
      destination = File.join(directory, fixture.fetch('artifact_name'))
      driver.compile_to(destination)
      expected_execution = driver.execute_artifact(fixture.fetch('events'))
      File.delete(copied_source)

      loader = BasicSharp::SmallCompilerSubsetBSBCLoader.read(destination, expected_fingerprint: driver.pipeline.fingerprint)
      vm = BasicSharp::SmallCompilerSubsetBSBCVirtualMachine.new(loader)
      results = fixture.fetch('events').map { |event| vm.run_event(event) }
      assert_equal normalize(expected_execution.fetch('events')), normalize(results)
      assert_equal normalize(expected_execution.fetch('snapshot')), normalize(vm.snapshot)
    end
  end

  def test_failed_compilation_does_not_overwrite_existing_artifact
    Dir.mktmpdir do |directory|
      driver = BasicSharp::SmallCompilerSubsetDriver.from_file(source_path)
      destination = File.join(directory, fixture.fetch('artifact_name'))
      driver.compile_to(destination)
      before_bytes = File.binread(destination)
      before_text = File.binread("#{destination}.txt")

      assert_raises(StandardError) do
        BasicSharp::SmallCompilerSubsetDriver.new('THIS IS NOT BASIC#').compile_to(destination)
      end

      assert_equal before_bytes, File.binread(destination)
      assert_equal before_text, File.binread("#{destination}.txt")
    end
  end

  def test_artifact_extension_is_required
    driver = BasicSharp::SmallCompilerSubsetDriver.from_file(source_path)
    Dir.mktmpdir do |directory|
      error = assert_raises(BasicSharp::SmallCompilerSubsetDriverError) do
        driver.compile_to(File.join(directory, 'program.bin'))
      end
      assert_includes error.message, '.bsbc'
    end
  end

  def test_artifact_digest_and_disassembly_digest_are_locked
    Dir.mktmpdir do |directory|
      driver = BasicSharp::SmallCompilerSubsetDriver.from_file(source_path)
      destination = File.join(directory, fixture.fetch('artifact_name'))
      driver.compile_to(destination)
      assert_equal expected.fetch('binary_sha256'), BasicSharp::SmallCompilerSubsetDriver.digest_binary(File.binread(destination))
      assert_equal expected.fetch('disassembly_sha256'), BasicSharp::SmallCompilerSubsetDriver.digest_text(File.read("#{destination}.txt", encoding: 'UTF-8'))
    end
  end
end
