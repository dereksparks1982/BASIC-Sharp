# frozen_string_literal: true

require 'digest'
require 'json'
require 'minitest/autorun'
require_relative '../compiler/small_compiler_subset_ir_emitter'
require_relative '../compiler/small_compiler_subset_bsbc_encoder'
require_relative '../compiler/small_compiler_subset_bsbc_loader'
require_relative '../compiler/small_compiler_subset_bsbc_virtual_machine'
require_relative '../compiler/bytecode_loader'
require_relative '../compiler/bytecode_virtual_machine'
require_relative '../compiler/runtime'
require_relative '../compiler/world_save'

class TestSmallCompilerSubsetBSBCVMIndependence < Minitest::Test
  ROOT = File.expand_path('..', __dir__)
  SPEC_PATH = File.join(ROOT, 'spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_BSBC_VM_INDEPENDENCE_v1.json')

  def spec
    @spec ||= JSON.parse(File.read(SPEC_PATH, encoding: 'UTF-8'))
  end

  def fixture
    spec.fetch('fixture')
  end

  def source
    File.read(File.join(ROOT, fixture.fetch('source_path')), encoding: 'UTF-8')
  end

  def normalize(value)
    case value
    when Hash then value.each_with_object({}) { |(key, child), result| result[key.to_s] = normalize(child) }.sort.to_h
    when Array then value.map { |child| normalize(child) }
    else value
    end
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

  def machines
    ir = BasicSharp::SmallCompilerSubsetIREmitter.new(source)
    encoder = BasicSharp::SmallCompilerSubsetBSBCEncoder.new(ir.bsharp_ir)
    subset_loader = BasicSharp::SmallCompilerSubsetBSBCLoader.new(encoder.binary, expected_fingerprint: encoder.fingerprint)
    production_loader = BasicSharp::BytecodeLoader.new(encoder.binary, expected_fingerprint: encoder.fingerprint)
    [
      encoder,
      subset_loader,
      BasicSharp::SmallCompilerSubsetBSBCVirtualMachine.new(subset_loader),
      BasicSharp::BytecodeVirtualMachine.new(production_loader),
      BasicSharp::Runtime.new(ir.bsharp_ir)
    ]
  end

  def test_contract_identity_and_live_version
    assert_equal 'bsharp.small_compiler_subset.bsbc_vm_independence.contract.json', spec.fetch('format')
    assert_equal 1, spec.fetch('format_version')
    assert_equal '0.1.80', BasicSharp::VERSION
    assert_equal BasicSharp::VERSION, spec.fetch('target_version')
    assert_equal 'bsbc_vm_execution_independent_under_ruby_referee', spec.fetch('status')
  end

  def test_vm_source_has_no_production_vm_dependency
    text = File.read(File.join(ROOT, 'compiler/small_compiler_subset_bsbc_virtual_machine.rb'), encoding: 'UTF-8')
    refute_includes text, "require_relative 'bytecode_virtual_machine'"
    refute_match(/\bBytecodeVirtualMachine\.new\b/, text)
    refute_match(/class\s+SmallCompilerSubsetBSBCVirtualMachine\s*<\s*BytecodeVirtualMachine/, text)
  end

  def test_dedicated_fixture_is_profile_7_and_binary_is_locked
    encoder, = machines
    assert_equal fixture.fetch('expected_profile'), encoder.profile
    assert_equal fixture.fetch('expected_binary_bytes'), encoder.binary.bytesize
    assert_equal fixture.fetch('expected_binary_sha256'), Digest::SHA256.hexdigest(encoder.binary)
    assert_equal fixture.fetch('expected_fingerprint'), encoder.fingerprint
  end

  def test_event_results_and_world_match_both_referees
    _encoder, _loader, vm, production_vm, ruby_referee = machines
    vm_results = fixture.fetch('events').map { |event| vm.run_event(event) }
    production_results = fixture.fetch('events').map { |event| production_vm.run_event(event) }
    ruby_results = fixture.fetch('events').map { |event| ruby_referee.run_event(event) }

    assert_equal normalize(production_results), normalize(vm_results)
    assert_equal semantic(ruby_results), semantic(vm_results)
    assert_equal normalize(production_vm.snapshot), normalize(vm.snapshot)
    assert_equal normalize(ruby_referee.snapshot), normalize(vm.snapshot)
  end

  def test_save_document_matches_both_referees
    _encoder, _loader, vm, production_vm, ruby_referee = machines
    fixture.fetch('events').each do |event|
      vm.run_event(event)
      production_vm.run_event(event)
      ruby_referee.run_event(event)
    end
    expected = normalize(BasicSharp::WorldSave.document_for(vm))
    assert_equal expected, normalize(BasicSharp::WorldSave.document_for(production_vm))
    assert_equal expected, normalize(BasicSharp::WorldSave.document_for(ruby_referee))
  end

  def test_independent_vm_still_runs_when_production_constructor_is_disabled
    _encoder, subset_loader, = machines
    klass = BasicSharp::BytecodeVirtualMachine
    klass.singleton_class.class_eval do
      alias_method :__v077_test_original_new, :new
      define_method(:new) { |*| raise 'production VM invoked' }
    end
    begin
      vm = BasicSharp::SmallCompilerSubsetBSBCVirtualMachine.new(subset_loader)
      assert vm.run_event(fixture.fetch('events').first).fetch('matched')
    ensure
      klass.singleton_class.class_eval do
        alias_method :new, :__v077_test_original_new
        remove_method :__v077_test_original_new
      end
    end
  end

  def test_execution_parity_routes_independent_vm_and_separate_production_referee
    text = File.read(File.join(ROOT, 'compiler/small_compiler_subset_bsbc_execution_parity.rb'), encoding: 'UTF-8')
    assert_includes text, 'SmallCompilerSubsetBSBCVirtualMachine.new(subset_loader)'
    assert_includes text, 'BytecodeVirtualMachine.new(production_loader)'
  end

  def test_high_volume_contract_is_sealed
    high = spec.fetch('high_volume_parity')
    assert_equal 1_024, high.fetch('event_count')
    assert_equal 'player sounds brass bell', high.fetch('event')
    assert_match(/\A[0-9a-f]{64}\z/, high.fetch('expected_independent_vm_event_results_sha256'))
    assert_match(/\A[0-9a-f]{64}\z/, high.fetch('expected_final_snapshot_sha256'))
  end

  def test_profiles_1_through_7_remain_the_allowed_surface
    self_hosting = JSON.parse(File.read(File.join(ROOT, 'spec/self_hosting/BASIC_SHARP_SELF_HOSTING_SUBSET_v1.json'), encoding: 'UTF-8'))
    assert_equal 7, self_hosting.fetch('approved_profiles_available_to_creator_programs').length
    refute_includes JSON.generate(self_hosting.fetch('approved_profiles_available_to_creator_programs')), 'v8'
  end

  def test_trial_by_fire_inventory_runs_vm_independence_gate
    inventory = JSON.parse(File.read(File.join(ROOT, 'spec/trial_by_fire/BASIC_SHARP_TRIAL_BY_FIRE_VALIDATION_INVENTORY_v1.json'), encoding: 'UTF-8'))
    tools = inventory.fetch('required_tools').map { |entry| entry.fetch('path') }
    assert_includes tools, 'tools/small_compiler_subset_bsbc_vm_independence.rb'
  end
end
