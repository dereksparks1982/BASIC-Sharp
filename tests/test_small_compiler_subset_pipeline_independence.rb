# frozen_string_literal: true

require 'json'
require 'minitest/autorun'
require 'open3'
require 'rbconfig'
require_relative '../compiler/small_compiler_subset_pipeline'
require_relative '../compiler/lexer'
require_relative '../compiler/parser'
require_relative '../compiler/resolver'
require_relative '../compiler/bytecode_emitter'
require_relative '../compiler/bytecode_loader'
require_relative '../compiler/bytecode_virtual_machine'
require_relative '../compiler/runtime'
require_relative '../compiler/world_save'

class TestSmallCompilerSubsetPipelineIndependence < Minitest::Test
  ROOT = File.expand_path('..', __dir__)
  SPEC_PATH = File.join(ROOT, 'spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_PIPELINE_INDEPENDENCE_v1.json')

  def spec
    @spec ||= JSON.parse(File.read(SPEC_PATH, encoding: 'UTF-8'))
  end

  def fixture
    spec.fetch('fixture')
  end

  def source
    @source ||= File.read(File.join(ROOT, fixture.fetch('source_path')), encoding: 'UTF-8')
  end

  def pipeline
    BasicSharp::SmallCompilerSubsetPipeline.new(source)
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

  def referee_machines
    parser = BasicSharp::Parser.new(source)
    document = BasicSharp::SemanticResolver.new(parser.parse, dictionary: parser.dictionary).resolve.to_h
    emitter = BasicSharp::BytecodeEmitter.new(document)
    loader = BasicSharp::BytecodeLoader.new(emitter.binary, expected_fingerprint: emitter.fingerprint)
    [document, emitter, loader, BasicSharp::BytecodeVirtualMachine.new(loader), BasicSharp::Runtime.new(document)]
  end

  def test_contract_identity_and_live_version
    assert_equal 'bsharp.small_compiler_subset.pipeline_independence.contract.json', spec.fetch('format')
    assert_equal 1, spec.fetch('format_version')
    assert_equal '0.1.79', BasicSharp::VERSION
    assert_equal BasicSharp::VERSION, spec.fetch('target_version')
    assert_equal 'integrated_independent_pipeline_under_ruby_referee', spec.fetch('status')
  end

  def test_pipeline_source_names_only_independent_primary_components
    text = File.read(File.join(ROOT, 'compiler/small_compiler_subset_pipeline.rb'), encoding: 'UTF-8')
    %w[bytecode_emitter bytecode_virtual_machine runtime_transition].each do |name|
      refute_includes text, "require_relative '#{name}'"
    end
    refute_match(/\bBytecodeEmitter\.new\b/, text)
    refute_match(/\bBytecodeLoader\.new\b/, text)
    refute_match(/\bBytecodeVirtualMachine\.new\b/, text)
    refute_match(/\bRuntime\.new\b/, text)
  end

  def test_reader_primary_path_is_independent_and_referee_is_separate
    text = File.read(File.join(ROOT, 'compiler/tokenizer_reader.rb'), encoding: 'UTF-8')
    reader_body = text[/def reader_records\n(.*?)\n    end/m, 1]
    assert_includes reader_body, 'independent_lines'
    refute_includes reader_body, 'ruby_referee_lines'
    assert_includes text, 'def ruby_referee_reader_records'
  end

  def test_constructor_disable_proof_runs_in_isolated_process
    stdout, stderr, status = Open3.capture3(
      RbConfig.ruby,
      'tools/small_compiler_subset_pipeline_independence.rb',
      chdir: ROOT
    )
    assert status.success?, "pipeline independence tool failed:\n#{stdout}\n#{stderr}"
    assert_includes stdout, 'TokenizerReader primary path independent from production Lexer: PASS'
    assert_includes stdout, 'Production compiler components used only as separate referees: PASS'
    assert_includes stdout, 'SMALL COMPILER SUBSET INTEGRATED INDEPENDENT PIPELINE: PASS'
  end

  def test_dedicated_fixture_compile_record_is_locked
    record = pipeline.compile_record
    assert_equal fixture.fetch('expected_profile'), record.fetch(:profile)
    assert_equal fixture.fetch('expected_reader_record_count'), record.fetch(:reader_record_count)
    assert_equal fixture.fetch('expected_statement_count'), record.fetch(:statement_count)
    assert_equal fixture.fetch('expected_binary_bytes'), record.fetch(:binary_bytes)
    assert_equal fixture.fetch('expected_binary_sha256'), record.fetch(:binary_sha256)
    assert_equal fixture.fetch('expected_disassembly_sha256'), record.fetch(:disassembly_sha256)
    assert_equal fixture.fetch('expected_bsharp_ir_sha256'), record.fetch(:bsharp_ir_sha256)
    assert_equal fixture.fetch('expected_fingerprint'), record.fetch(:fingerprint)
    assert_equal fixture.fetch('expected_loader_summary_sha256'), record.fetch(:loader_summary_sha256)
  end

  def test_bsharp_ir_and_bsbc_match_production_referees
    independent = pipeline
    document, emitter, loader, = referee_machines
    assert_equal normalize(document), normalize(independent.bsharp_ir)
    assert_equal emitter.binary, independent.binary
    assert_equal emitter.disassembly, independent.disassembly
    assert_equal emitter.fingerprint, independent.fingerprint
    assert_equal normalize(loader.summary), normalize(independent.loader.summary)
  end

  def test_event_results_and_world_match_both_referees
    independent = pipeline
    _document, _emitter, _loader, production_vm, ruby_runtime = referee_machines
    independent_results = fixture.fetch('events').map { |event| independent.run_event(event) }
    production_results = fixture.fetch('events').map { |event| production_vm.run_event(event) }
    ruby_results = fixture.fetch('events').map { |event| ruby_runtime.run_event(event) }

    assert_equal normalize(production_results), normalize(independent_results)
    assert_equal semantic(ruby_results), semantic(independent_results)
    assert_equal normalize(production_vm.snapshot), normalize(independent.snapshot)
    assert_equal normalize(ruby_runtime.snapshot), normalize(independent.snapshot)
    assert_equal fixture.fetch('expected_event_results_sha256'), BasicSharp::SmallCompilerSubsetPipeline.digest_json(independent_results)
    assert_equal fixture.fetch('expected_final_snapshot_sha256'), BasicSharp::SmallCompilerSubsetPipeline.digest_json(independent.snapshot)
  end

  def test_save_document_matches_both_referees
    independent = pipeline
    _document, _emitter, _loader, production_vm, ruby_runtime = referee_machines
    fixture.fetch('events').each do |event|
      independent.run_event(event)
      production_vm.run_event(event)
      ruby_runtime.run_event(event)
    end
    save = independent.save_document
    assert_equal normalize(BasicSharp::WorldSave.document_for(production_vm)), normalize(save)
    assert_equal normalize(BasicSharp::WorldSave.document_for(ruby_runtime)), normalize(save)
    assert_equal fixture.fetch('expected_save_document_sha256'), BasicSharp::SmallCompilerSubsetPipeline.digest_json(save)
  end

  def test_deterministic_replay_is_locked
    replay = spec.fetch('deterministic_replay')
    machine = pipeline
    results = Array.new(replay.fetch('event_count')) { machine.run_event(replay.fetch('event')) }
    assert_equal replay.fetch('expected_event_results_sha256'), BasicSharp::SmallCompilerSubsetPipeline.digest_json(results)
    assert_equal replay.fetch('expected_final_snapshot_sha256'), BasicSharp::SmallCompilerSubsetPipeline.digest_json(machine.snapshot)
  end

  def test_profiles_1_through_7_remain_the_allowed_surface
    self_hosting = JSON.parse(File.read(File.join(ROOT, 'spec/self_hosting/BASIC_SHARP_SELF_HOSTING_SUBSET_v1.json'), encoding: 'UTF-8'))
    assert_equal 7, self_hosting.fetch('approved_profiles_available_to_creator_programs').length
    refute_includes JSON.generate(self_hosting.fetch('approved_profiles_available_to_creator_programs')), 'v8'
  end

  def test_trial_by_fire_inventory_runs_pipeline_gate
    inventory = JSON.parse(File.read(File.join(ROOT, 'spec/trial_by_fire/BASIC_SHARP_TRIAL_BY_FIRE_VALIDATION_INVENTORY_v1.json'), encoding: 'UTF-8'))
    tools = inventory.fetch('required_tools').map { |entry| entry.fetch('path') }
    assert_includes tools, 'tools/small_compiler_subset_pipeline_independence.rb'
  end
end
