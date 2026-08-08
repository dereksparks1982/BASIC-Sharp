# frozen_string_literal: true

require 'json'
require 'minitest/autorun'
require_relative '../compiler/ast_nodes'

class TestSelfHostingContract < Minitest::Test
  ROOT = File.expand_path('..', __dir__)
  SPEC_PATH = File.join(ROOT, 'spec/self_hosting/BASIC_SHARP_SELF_HOSTING_SUBSET_v1.json')

  def spec
    @spec ||= JSON.parse(File.read(SPEC_PATH, encoding: 'UTF-8'))
  end

  def test_spec_targets_the_live_basic_sharp_version
    assert_equal '0.1.51', BasicSharp::VERSION
    assert_equal BasicSharp::VERSION, spec.fetch('target_version')
  end

  def test_contract_is_foundation_only
    assert_equal 'foundation_contract_only', spec.fetch('status')
    assert_equal 'BSharp Compiler Subset 0', spec.fetch('compiler_subset_name')
    assert_equal 'ir_golden_parity_under_ruby_referee', spec.fetch('compiler_subset_status')
  end

  def test_future_work_is_explicitly_excluded
    forbidden = spec.fetch('compiler_subset_forbids_until_later_approval')

    assert_includes forbidden, 'replacing the Ruby bootstrap compiler'
    assert_includes forbidden, 'claiming BASIC# is self-hosted'
    assert_includes forbidden, 'Profile 8'
    assert_includes forbidden, 'BSharp native document application work'
  end


  def test_tokenizer_reader_contract_is_linked
    documents = spec.fetch('documents')

    assert_equal 'spec/self_hosting/BASIC_SHARP_TOKENIZER_READER_CONTRACT_v1.json', documents.fetch('tokenizer_reader_spec')
    assert File.file?(File.join(ROOT, documents.fetch('tokenizer_reader_contract')))
    assert File.file?(File.join(ROOT, documents.fetch('tokenizer_reader_tool')))
    assert File.file?(File.join(ROOT, documents.fetch('tokenizer_reader_test')))
    assert_equal 'spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_PARSER_v1.json', documents.fetch('small_compiler_subset_parser_spec')
    assert File.file?(File.join(ROOT, documents.fetch('small_compiler_subset_parser_tool')))
    assert File.file?(File.join(ROOT, documents.fetch('small_compiler_subset_parser_test')))
    assert_equal 'spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_IR_EMITTER_v1.json', documents.fetch('small_compiler_subset_ir_emitter_spec')
    assert File.file?(File.join(ROOT, documents.fetch('small_compiler_subset_ir_emitter_tool')))
    assert File.file?(File.join(ROOT, documents.fetch('small_compiler_subset_ir_emitter_test')))
    assert_equal 'spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_IR_PARITY_HARNESS_v1.json', documents.fetch('small_compiler_subset_ir_parity_harness_spec')
    assert File.file?(File.join(ROOT, documents.fetch('small_compiler_subset_ir_parity_harness_implementation')))
  end

  def test_trial_by_fire_inventory_runs_the_contract_tool
    inventory = JSON.parse(File.read(File.join(ROOT, 'spec/trial_by_fire/BASIC_SHARP_TRIAL_BY_FIRE_VALIDATION_INVENTORY_v1.json'), encoding: 'UTF-8'))
    tools = inventory.fetch('required_tools').map { |entry| entry.fetch('path') }

    assert_includes tools, 'tools/self_hosting_contract.rb'
    assert_includes tools, 'tools/small_compiler_subset_parser.rb'
    assert_includes tools, 'tools/small_compiler_subset_ir_emitter.rb'
    assert_includes tools, 'tools/small_compiler_subset_ir_parity_harness.rb'
  end
end
