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
    assert_equal '0.1.75', BasicSharp::VERSION
    assert_equal BasicSharp::VERSION, spec.fetch('target_version')
  end

  def test_contract_is_foundation_only
    assert_equal 'foundation_contract_only', spec.fetch('status')
    assert_equal 'BSharp Compiler Subset 0', spec.fetch('compiler_subset_name')
    assert_equal 'self_hosting_milestone_1_under_ruby_referee', spec.fetch('compiler_subset_status')
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
    assert_equal 'spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_SEMANTIC_RESOLVER_v1.json', documents.fetch('small_compiler_subset_semantic_resolver_spec')
    assert File.file?(File.join(ROOT, documents.fetch('small_compiler_subset_semantic_resolver_implementation')))
    assert File.file?(File.join(ROOT, documents.fetch('small_compiler_subset_semantic_resolver_file')))
    assert File.file?(File.join(ROOT, documents.fetch('small_compiler_subset_semantic_resolver_tool')))
    assert File.file?(File.join(ROOT, documents.fetch('small_compiler_subset_semantic_resolver_test')))
    assert File.file?(File.join(ROOT, documents.fetch('small_compiler_subset_ir_emitter_tool')))
    assert File.file?(File.join(ROOT, documents.fetch('small_compiler_subset_ir_emitter_test')))
    assert_equal 'spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_IR_PARITY_HARNESS_v1.json', documents.fetch('small_compiler_subset_ir_parity_harness_spec')
    assert File.file?(File.join(ROOT, documents.fetch('small_compiler_subset_ir_parity_harness_implementation')))
    assert_equal 'spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_ERROR_CONTRACT_v1.json', documents.fetch('small_compiler_subset_error_contract_spec')
    assert File.file?(File.join(ROOT, documents.fetch('small_compiler_subset_error_contract_implementation')))
    assert_equal 'spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_SCENE_BLOCK_EXPANSION_v1.json', documents.fetch('small_compiler_subset_scene_block_expansion_spec')
    assert File.file?(File.join(ROOT, documents.fetch('small_compiler_subset_scene_block_expansion_implementation')))
    assert_equal 'spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_SYMBOL_TABLE_CONTRACT_v1.json', documents.fetch('small_compiler_subset_symbol_table_contract_spec')
    assert File.file?(File.join(ROOT, documents.fetch('small_compiler_subset_symbol_table_contract_implementation')))
    assert_equal 'spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_BSBC_EMITTER_v1.json', documents.fetch('small_compiler_subset_bsbc_emitter_spec')
    assert File.file?(File.join(ROOT, documents.fetch('small_compiler_subset_bsbc_emitter_implementation')))
    assert File.file?(File.join(ROOT, documents.fetch('small_compiler_subset_bsbc_emitter_tool')))
    assert File.file?(File.join(ROOT, documents.fetch('small_compiler_subset_bsbc_emitter_test')))
    assert_equal 'spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_BSBC_EMITTER_INDEPENDENCE_v1.json', documents.fetch('small_compiler_subset_bsbc_emitter_independence_spec')
    assert File.file?(File.join(ROOT, documents.fetch('small_compiler_subset_bsbc_emitter_independence_implementation')))
    assert File.file?(File.join(ROOT, documents.fetch('small_compiler_subset_bsbc_encoder_file')))
    assert File.file?(File.join(ROOT, documents.fetch('small_compiler_subset_bsbc_emitter_independence_tool')))
    assert File.file?(File.join(ROOT, documents.fetch('small_compiler_subset_bsbc_emitter_independence_test')))
    assert_equal 'spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_BSBC_PARITY_HARNESS_v1.json', documents.fetch('small_compiler_subset_bsbc_parity_harness_spec')
    assert File.file?(File.join(ROOT, documents.fetch('small_compiler_subset_bsbc_parity_harness_implementation')))
    assert File.file?(File.join(ROOT, documents.fetch('small_compiler_subset_bsbc_parity_harness_tool')))
    assert File.file?(File.join(ROOT, documents.fetch('small_compiler_subset_bsbc_parity_harness_test')))
    assert_equal 'spec/self_hosting/BASIC_SHARP_SELF_HOSTING_FIXTURE_CORPUS_v1.json', documents.fetch('self_hosting_fixture_corpus_spec')
    assert File.file?(File.join(ROOT, documents.fetch('self_hosting_fixture_corpus_implementation')))
    assert File.file?(File.join(ROOT, documents.fetch('self_hosting_fixture_corpus_file')))
    assert File.file?(File.join(ROOT, documents.fetch('self_hosting_fixture_corpus_tool')))
    assert File.file?(File.join(ROOT, documents.fetch('self_hosting_fixture_corpus_test')))
    assert_equal 'spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_RUNTIME_SMOKE_v1.json', documents.fetch('small_compiler_subset_runtime_smoke_spec')
    assert File.file?(File.join(ROOT, documents.fetch('small_compiler_subset_runtime_smoke_implementation')))
    assert File.file?(File.join(ROOT, documents.fetch('small_compiler_subset_runtime_smoke_file')))
    assert File.file?(File.join(ROOT, documents.fetch('small_compiler_subset_runtime_smoke_tool')))
    assert File.file?(File.join(ROOT, documents.fetch('small_compiler_subset_runtime_smoke_test')))
    assert_equal 'spec/self_hosting/BASIC_SHARP_BOOTSTRAP_BOUNDARY_AUDIT_v1.json', documents.fetch('bootstrap_boundary_audit_spec')
    assert File.file?(File.join(ROOT, documents.fetch('bootstrap_boundary_audit_implementation')))
    assert File.file?(File.join(ROOT, documents.fetch('bootstrap_boundary_audit_file')))
    assert File.file?(File.join(ROOT, documents.fetch('bootstrap_boundary_audit_tool')))
    assert File.file?(File.join(ROOT, documents.fetch('bootstrap_boundary_audit_test')))
    assert_equal 'spec/self_hosting/BASIC_SHARP_README_CURRENT_RELEASE_TRUTH_v1.json', documents.fetch('readme_current_release_truth_spec')
    assert File.file?(File.join(ROOT, documents.fetch('readme_current_release_truth_tool')))
    assert_equal 'spec/self_hosting/BASIC_SHARP_SELF_HOSTING_MILESTONE_1_v1.json', documents.fetch('self_hosting_milestone_1_spec')
    assert File.file?(File.join(ROOT, documents.fetch('self_hosting_milestone_1_tool')))
  end

  def test_trial_by_fire_inventory_runs_the_contract_tool
    inventory = JSON.parse(File.read(File.join(ROOT, 'spec/trial_by_fire/BASIC_SHARP_TRIAL_BY_FIRE_VALIDATION_INVENTORY_v1.json'), encoding: 'UTF-8'))
    tools = inventory.fetch('required_tools').map { |entry| entry.fetch('path') }

    assert_includes tools, 'tools/self_hosting_contract.rb'
    assert_includes tools, 'tools/small_compiler_subset_parser.rb'
    assert_includes tools, 'tools/small_compiler_subset_ir_emitter.rb'
    assert_includes tools, 'tools/small_compiler_subset_semantic_resolver.rb'
    assert_includes tools, 'tools/small_compiler_subset_ir_parity_harness.rb'
    assert_includes tools, 'tools/small_compiler_subset_error_contract.rb'
    assert_includes tools, 'tools/small_compiler_subset_scene_block_expansion.rb'
    assert_includes tools, 'tools/small_compiler_subset_symbol_table_contract.rb'
    assert_includes tools, 'tools/small_compiler_subset_bsbc_emitter.rb'
    assert_includes tools, 'tools/small_compiler_subset_bsbc_emitter_independence.rb'
    assert_includes tools, 'tools/small_compiler_subset_bsbc_parity_harness.rb'
    assert_includes tools, 'tools/self_hosting_fixture_corpus.rb'
    assert_includes tools, 'tools/small_compiler_subset_runtime_smoke.rb'
    assert_includes tools, 'tools/bootstrap_boundary_audit.rb'
    assert_includes tools, 'tools/readme_current_release_truth.rb'
    assert_includes tools, 'tools/self_hosting_milestone_1.rb'
  end
end
