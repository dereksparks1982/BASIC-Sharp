# frozen_string_literal: true

require 'json'
require 'minitest/autorun'
require 'open3'
require 'rbconfig'
require 'tmpdir'
require_relative '../compiler/small_compiler_subset_driver'

class TestFirstNativeCompilerComponent < Minitest::Test
  ROOT = File.expand_path('..', __dir__)
  SPEC_PATH = File.join(ROOT, 'spec/self_hosting/BASIC_SHARP_FIRST_NATIVE_COMPILER_COMPONENT_v1.json')

  def spec
    @spec ||= JSON.parse(File.read(SPEC_PATH, encoding: 'UTF-8'))
  end

  def component
    spec.fetch('component')
  end

  def source_path
    File.join(ROOT, component.fetch('source_path'))
  end

  def artifact_path
    File.join(ROOT, component.fetch('artifact_path'))
  end

  def decision_for(machine)
    object = machine.snapshot.find { |entry| entry.fetch('name') == component.fetch('decision_object') }
    object.fetch('values').fetch(component.fetch('decision_value'))
  end

  def test_contract_identity_and_live_version
    assert_equal 'bsharp.first_native_compiler_component.contract.json', spec.fetch('format')
    assert_equal 1, spec.fetch('format_version')
    assert_equal '0.1.81', BasicSharp::VERSION
    assert_equal BasicSharp::VERSION, spec.fetch('target_version')
    assert_equal 'first_bsharp_authored_compiler_component_under_ruby_referee', spec.fetch('status')
  end

  def test_component_is_authored_in_basic_sharp
    assert File.file?(source_path)
    assert_equal '.bsharp', File.extname(source_path)
    text = File.read(source_path, encoding: 'UTF-8')
    assert_includes text, 'WHEN PLAYER examines @kinds head'
    assert_includes text, '(change classification of @compiler decision'
    refute_includes text, 'def '
    refute_includes text, 'class '
  end

  def test_checked_in_artifact_is_real_and_locked
    assert File.file?(artifact_path)
    assert File.file?(component.fetch('disassembly_path').then { |path| File.join(ROOT, path) })
    assert_equal component.fetch('expected_binary_bytes'), File.size(artifact_path)
    assert_equal component.fetch('expected_binary_sha256'), BasicSharp::SmallCompilerSubsetDriver.digest_binary(File.binread(artifact_path))
    assert_equal component.fetch('expected_disassembly_sha256'), BasicSharp::SmallCompilerSubsetDriver.digest_text(File.read(File.join(ROOT, component.fetch('disassembly_path')), encoding: 'UTF-8'))
  end

  def test_independent_driver_reproduces_checked_in_artifact
    Dir.mktmpdir do |directory|
      destination = File.join(directory, 'native_component.bsbc')
      driver = BasicSharp::SmallCompilerSubsetDriver.from_file(source_path)
      driver.compile_to(destination)
      assert_equal component.fetch('profile'), driver.pipeline.profile
      assert_equal File.binread(artifact_path), File.binread(destination)
      assert_equal component.fetch('expected_source_sha256'), driver.driver_record.fetch(:source_sha256)
      assert_equal component.fetch('expected_bsharp_ir_sha256'), driver.driver_record.fetch(:bsharp_ir_sha256)
      assert_equal component.fetch('expected_fingerprint'), driver.driver_record.fetch(:fingerprint)
    end
  end

  def test_native_artifact_classifies_all_accepted_heads
    decisions = {}
    component.fetch('input_heads').each do |head|
      loader = BasicSharp::SmallCompilerSubsetBSBCLoader.read(artifact_path)
      machine = BasicSharp::SmallCompilerSubsetBSBCVirtualMachine.new(loader)
      result = machine.run_event("player examines #{head.downcase} head")
      assert result.fetch('matched'), "#{head} did not match"
      decisions[head.downcase] = decision_for(machine)
    end
    assert_equal component.fetch('expected_decisions'), decisions
    assert_equal component.fetch('expected_decisions_sha256'), BasicSharp::SmallCompilerSubsetDriver.digest_json(decisions)
  end

  def test_source_free_artifact_execution
    Dir.mktmpdir do |directory|
      copied_source = File.join(directory, 'component.bsharp')
      destination = File.join(directory, 'component.bsbc')
      File.write(copied_source, File.read(source_path, encoding: 'UTF-8'), encoding: 'UTF-8')
      BasicSharp::SmallCompilerSubsetDriver.from_file(copied_source).compile_to(destination)
      File.delete(copied_source)
      refute File.exist?(copied_source)

      loader = BasicSharp::SmallCompilerSubsetBSBCLoader.read(destination)
      machine = BasicSharp::SmallCompilerSubsetBSBCVirtualMachine.new(loader)
      assert machine.run_event('player examines when head').fetch('matched')
      assert_equal 'parse-event-rule', decision_for(machine)
    end
  end

  def test_full_native_component_gate_runs_in_isolated_process
    stdout, stderr, status = Open3.capture3(RbConfig.ruby, 'tools/first_native_compiler_component.rb', chdir: ROOT)
    assert status.success?, "native compiler component gate failed:\n#{stdout}\n#{stderr}"
    assert_includes stdout, 'Production compiler/runtime constructors disabled on primary path: PASS'
    assert_includes stdout, 'Source-free native artifact execution: PASS'
    assert_includes stdout, 'FIRST BASIC#-AUTHORED COMPILER COMPONENT: PASS'
  end

  def test_self_hosting_contract_links_native_component
    contract = JSON.parse(File.read(File.join(ROOT, 'spec/self_hosting/BASIC_SHARP_SELF_HOSTING_SUBSET_v1.json'), encoding: 'UTF-8'))
    documents = contract.fetch('documents')
    assert_equal 'spec/self_hosting/BASIC_SHARP_FIRST_NATIVE_COMPILER_COMPONENT_v1.json', documents.fetch('first_native_compiler_component_spec')
    assert_equal 'compiler/native/first_bsharp_compiler_component.bsharp', documents.fetch('first_native_compiler_component_source')
    assert_equal 'compiler/native/first_bsharp_compiler_component.bsbc', documents.fetch('first_native_compiler_component_artifact')
  end

  def test_trial_by_fire_inventory_runs_native_component_gate
    inventory = JSON.parse(File.read(File.join(ROOT, 'spec/trial_by_fire/BASIC_SHARP_TRIAL_BY_FIRE_VALIDATION_INVENTORY_v1.json'), encoding: 'UTF-8'))
    tools = inventory.fetch('required_tools').map { |entry| entry.fetch('path') }
    assert_includes tools, 'tools/first_native_compiler_component.rb'
  end
end
