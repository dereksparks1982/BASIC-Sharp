# frozen_string_literal: true

require 'json'
require 'minitest/autorun'
require_relative '../compiler/bytecode_contract'

class TestBytecodeContract < Minitest::Test
  ROOT = File.expand_path('..', __dir__)
  PROFILE_PATH = File.join(ROOT, 'spec/bytecode_v1/BASIC_SHARP_BYTECODE_PROFILE_v1.json')

  def profile
    @profile ||= JSON.parse(File.read(PROFILE_PATH))
  end

  def deep_copy(value)
    JSON.parse(JSON.generate(value))
  end

  def test_profile_validates
    assert BasicSharp::BytecodeContract.validate_profile!(profile, root: ROOT)
  end

  def test_artifact_identity_is_exact
    artifact = profile.fetch('artifact')
    assert_equal 'BSharp Bytecode', artifact.fetch('name')
    assert_equal 'BSBC', artifact.fetch('short_name')
    assert_equal '.bsbc', artifact.fetch('extension')
    assert_equal 'BSBC', artifact.fetch('magic_ascii')
    assert_equal '42 53 42 43', artifact.fetch('magic_hex')
    assert_equal 'bsharp.bytecode.bin', artifact.fetch('binary_format')
    assert_equal 'bsharp.bytecode.v1', artifact.fetch('profile')
    assert_equal 'bsharp.meaning.v1', artifact.fetch('required_meaning_profile')
    assert_equal 'little-endian', artifact.fetch('byte_order')
  end

  def test_header_and_directory_are_exactly_packed
    container = profile.fetch('container')
    assert_equal 32, container.fetch('header_size_bytes')
    assert_equal 16, container.fetch('section_directory_entry_size_bytes')
    assert_equal 160, container.fetch('section_data_minimum_offset')
    assert_equal (0...32).to_a, occupied_bytes(container.fetch('header_fields'))
    assert_equal (0...16).to_a, occupied_bytes(container.fetch('section_directory_fields'))
  end

  def test_required_sections_are_unique_and_ordered
    expected = %w[STRS META KIND THNG STRT EVNT IFRL CODE]
    assert_equal expected, profile.dig('container', 'section_order')
    assert_equal expected, profile.fetch('sections').map { |entry| entry.fetch('id') }
    assert_equal expected.length, expected.uniq.length
  end

  def test_instruction_codes_and_operands_are_fixed
    expected = BasicSharp::BytecodeContract::INSTRUCTIONS
    entries = profile.fetch('instructions')
    assert_equal expected.keys, entries.map { |entry| entry.fetch('name') }
    assert_equal expected.values, entries.map { |entry| entry.fetch('code') }
    entries.each do |entry|
      assert_equal format('0x%02X', entry.fetch('code')), entry.fetch('hex')
      refute_empty entry.fetch('operands')
    end
    assert_equal %w[target_selector_type target_reference amount], entry(entries, 'DAMAGE').fetch('operands')
    assert_equal 5, entry(entries, 'CAUSE_EVENT').fetch('operands').length
  end

  def test_selector_and_condition_codes_are_fixed
    assert_equal BasicSharp::BytecodeContract::SELECTORS.keys, profile.fetch('selectors').map { |entry| entry.fetch('name') }
    assert_equal BasicSharp::BytecodeContract::SELECTORS.values, profile.fetch('selectors').map { |entry| entry.fetch('code') }
    assert_equal BasicSharp::BytecodeContract::CONDITIONS.keys, profile.fetch('conditions').map { |entry| entry.fetch('name') }
    assert_equal BasicSharp::BytecodeContract::CONDITIONS.values, profile.fetch('conditions').map { |entry| entry.fetch('code') }
  end

  def test_reserved_ranges_cover_every_inactive_byte_without_overlap
    assert_reserved_partition('instruction_reserved_ranges', BasicSharp::BytecodeContract::INSTRUCTIONS.values)
    assert_reserved_partition('condition_reserved_ranges', BasicSharp::BytecodeContract::CONDITIONS.values)
    assert_reserved_partition('selector_reserved_ranges', BasicSharp::BytecodeContract::SELECTORS.values)
  end

  def test_all_thirteen_meaning_cases_have_coverage
    meaning = JSON.parse(File.read(File.join(ROOT, 'spec/meaning_v1/BASIC_SHARP_MEANING_PROFILE_v1.json')))
    expected_ids = meaning.fetch('cases').map { |case_entry| case_entry.fetch('id') }
    coverage = profile.fetch('meaning_case_coverage')
    assert_equal 13, coverage.length
    assert_equal expected_ids, coverage.map { |entry| entry.fetch('case_id') }
    coverage.each { |entry| refute_empty entry.fetch('requires') }
  end

  def test_contract_covers_every_current_official_action
    names = profile.fetch('instructions').map { |entry| entry.fetch('name') }
    %w[DAMAGE CHANGE_STATE CHANGE_VALUE CARRY UNLOCK CAUSE_EVENT].each do |name|
      assert_includes names, name
    end
  end

  def test_disassembly_is_diagnostic_and_bounded_by_blocks
    disassembly = profile.fetch('disassembly')
    assert_includes disassembly.fetch('status'), 'diagnostic only'
    assert_equal 'BLOCK <block_id>', disassembly.fetch('block_open')
    assert_equal 'END', disassembly.fetch('block_close')
    assert_includes disassembly.fetch('instruction_line'), '<MNEMONIC>'
  end

  def test_malformed_rejection_is_complete_and_atomic
    rules = profile.fetch('malformed_rejection_rules')
    BasicSharp::BytecodeContract::REQUIRED_MALFORMED_RULES.each do |rule|
      assert_includes rules, rule
    end
    assert_equal rules.length, rules.uniq.length
    assert_includes profile.dig('future_boundaries', 'v0_1_28_excludes'), 'bytecode execution'
    assert_equal ['.bsharp', '.bsir.json'], profile.dig('emission', 'source_inputs')
    assert_equal ['bsharp.bytecode.v1', 'bsharp.meaning.v1', 'sha256-bsir-meaning-v1'], profile.dig('emission', 'mandatory_string_prefix')
  end

  def test_loader_contract_is_complete_and_non_executing
    loading = profile.fetch('loading')
    assert_equal 'implemented by BASIC# v0.1.28', loading.fetch('status')
    assert_equal ['.bsbc'], loading.fetch('source_inputs')
    assert_includes loading.fetch('validation'), 'complete structural validation'
    assert_includes loading.fetch('trusted_model'), 'deeply frozen'
    assert_includes loading.fetch('failure_boundary'), 'no partial model'
    assert_includes loading.fetch('meaning_comparison'), '--against'
    assert_includes loading.fetch('execution_boundary'), 'non-executing'
    assert_includes loading.fetch('malformed_fixture_count'), '41'
  end


  def test_vm_execution_contract_is_direct_and_profile_complete
    execution = profile.fetch('execution')
    assert_equal 'preferred by BASIC# v0.1.31', execution.fetch('status')
    assert_equal 'successfully validated deeply frozen BytecodeLoader model', execution.fetch('input_boundary')
    assert_equal true, execution.fetch('direct_bytecode_interpretation')
    assert_equal false, execution.fetch('reconstructs_bsir')
    assert_equal false, execution.fetch('calls_reference_runtime')
    assert_equal 1_024, execution.fetch('follow_up_limit')
    assert_equal ['.bsharp', '.bsir.json', '.bsbc'], execution.fetch('preferred_runtime_inputs')
    assert_includes execution.fetch('source_and_bsir_pipeline'), 'emitted to BSBC in memory'
    assert_includes execution.fetch('reference_runtime_role'), '--reference-runtime'
    assert_includes execution.fetch('shadow_parity_verification'), '--verify-runtime-parity'
    assert_includes execution.fetch('action_instructions'), 'CAUSE_EVENT'
    assert_includes execution.fetch('condition_instructions'), 'VALUE_EQUALS'
    assert_includes profile.dig('future_boundaries', 'v0_1_29_excludes'), 'BSharp Save through the VM'
  end

  def test_canonical_contract_is_deterministic_across_hash_order
    reversed = reverse_hashes(deep_copy(profile))
    first = BasicSharp::BytecodeContract.canonical_json(profile)
    second = BasicSharp::BytecodeContract.canonical_json(reversed)
    assert_equal first, second
    assert_equal BasicSharp::BytecodeContract.sha256(first), BasicSharp::BytecodeContract.sha256(second)
  end

  def test_contract_contains_no_ruby_objects_machine_paths_or_timestamps
    text = File.read(PROFILE_PATH)
    refute BasicSharp::BytecodeContract.forbidden_serialized_data?(text)
    refute BasicSharp::BytecodeContract.forbidden_serialized_data?(BasicSharp::BytecodeContract.canonical_json(profile))
  end

  def test_mutated_magic_is_rejected
    changed = deep_copy(profile)
    changed.fetch('artifact')['magic_ascii'] = 'NOPE'
    error = assert_raises(BasicSharp::BytecodeContractError) do
      BasicSharp::BytecodeContract.validate_profile!(changed, root: ROOT)
    end
    assert_includes error.message, 'magic_ascii'
  end

  def test_mutated_opcode_is_rejected
    changed = deep_copy(profile)
    changed.fetch('instructions').find { |instruction| instruction['name'] == 'DAMAGE' }['code'] = 99
    error = assert_raises(BasicSharp::BytecodeContractError) do
      BasicSharp::BytecodeContract.validate_profile!(changed, root: ROOT)
    end
    assert_includes error.message, 'DAMAGE'
  end

  def test_missing_meaning_case_is_rejected
    changed = deep_copy(profile)
    changed.fetch('meaning_case_coverage').pop
    error = assert_raises(BasicSharp::BytecodeContractError) do
      BasicSharp::BytecodeContract.validate_profile!(changed, root: ROOT)
    end
    assert_includes error.message, '13 Meaning Profile cases'
  end

  private

  def entry(entries, name)
    entries.find { |candidate| candidate.fetch('name') == name }
  end

  def occupied_bytes(fields)
    fields.flat_map { |field| (field.fetch('offset')...(field.fetch('offset') + field.fetch('bytes'))).to_a }.sort
  end

  def assert_reserved_partition(key, active)
    reserved = profile.fetch(key).flat_map { |range| (range.fetch('start')..range.fetch('end')).to_a }
    assert_equal reserved.length, reserved.uniq.length
    assert_empty(reserved & active)
    assert_equal (0..255).to_a, (reserved + active).sort
  end

  def reverse_hashes(value)
    case value
    when Hash
      value.keys.reverse.each_with_object({}) { |key, result| result[key] = reverse_hashes(value[key]) }
    when Array
      value.map { |entry| reverse_hashes(entry) }
    else
      value
    end
  end
end
