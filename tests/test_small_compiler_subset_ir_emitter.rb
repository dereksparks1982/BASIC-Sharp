# frozen_string_literal: true

require 'json'
require 'minitest/autorun'
require_relative '../compiler/small_compiler_subset_ir_emitter'

class TestSmallCompilerSubsetIREmitter < Minitest::Test
  ROOT = File.expand_path('..', __dir__)
  SPEC_PATH = File.join(ROOT, 'spec/self_hosting/BASIC_SHARP_SMALL_COMPILER_SUBSET_IR_EMITTER_v1.json')

  def spec
    @spec ||= JSON.parse(File.read(SPEC_PATH, encoding: 'UTF-8'))
  end

  def test_spec_targets_the_live_basic_sharp_version
    assert_equal '0.1.72', BasicSharp::VERSION
    assert_equal BasicSharp::VERSION, spec.fetch('target_version')
    assert_equal 'ir_emitter_under_ruby_referee', spec.fetch('status')
  end

  def test_subset_emitted_bsharp_ir_matches_ruby_referee_for_each_fixture
    spec.fetch('fixtures').each do |fixture|
      emitter = BasicSharp::SmallCompilerSubsetIREmitter.new(fixture.fetch('source'))
      record = emitter.to_h
      ir = record.fetch(:bsharp_ir)
      expected = fixture.fetch('expected_counts')

      assert emitter.parser_matches_ruby_referee?, "Parser referee mismatch for #{fixture.fetch('name')}"
      assert emitter.ir_matches_ruby_referee?, "BSharp IR referee mismatch for #{fixture.fetch('name')}"
      assert_equal true, record.fetch(:ruby_referee_matches)
      assert_equal expected.fetch('kinds'), ir.fetch(:kinds).length
      assert_equal expected.fetch('objects'), ir.fetch(:objects).length
      assert_equal expected.fetch('facts'), ir.fetch(:facts).length
      assert_equal expected.fetch('events'), ir.fetch(:events).length
      assert_equal expected.fetch('if_rules'), ir.fetch(:if_rules).length
      assert_equal expected.fetch('controls'), ir.fetch(:controls).length
      assert_equal expected.fetch('hover_declarations'), ir.fetch(:hover_declarations).length
      assert_equal expected.fetch('context_declarations'), ir.fetch(:context_declarations).length
      assert_equal expected.fetch('diagnostics'), ir.fetch(:diagnostics).length
      assert_equal expected.fetch('meaning_profile'), ir.fetch(:meaning_profile, 'bsharp.meaning.v1')
    end
  end

  def test_to_h_declares_non_production_status
    emitter = BasicSharp::SmallCompilerSubsetIREmitter.new("START\n[\n    PLAYER is ready\n].\n")
    record = emitter.to_h

    assert_equal 'bsharp.small_compiler_subset.ir_emitter.record', record.fetch(:format)
    assert_equal '0.1.72', record.fetch(:version)
    assert_equal 'ir_emitter_under_ruby_referee', record.fetch(:status)
    assert_equal true, record.fetch(:parser_ruby_referee_matches)
    assert_equal true, record.fetch(:ruby_referee_matches)
    assert_equal 'bsir.debug.json', record.fetch(:bsharp_ir).fetch(:format)
  end

  def test_trial_by_fire_inventory_runs_the_ir_emitter_tool
    inventory = JSON.parse(File.read(File.join(ROOT, 'spec/trial_by_fire/BASIC_SHARP_TRIAL_BY_FIRE_VALIDATION_INVENTORY_v1.json'), encoding: 'UTF-8'))
    tools = inventory.fetch('required_tools').map { |entry| entry.fetch('path') }

    assert_includes tools, 'tools/small_compiler_subset_ir_emitter.rb'
  end
end
