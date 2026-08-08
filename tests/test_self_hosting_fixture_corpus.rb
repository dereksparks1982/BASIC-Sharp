# frozen_string_literal: true

require 'json'
require 'minitest/autorun'
require_relative '../compiler/self_hosting_fixture_corpus'

class TestSelfHostingFixtureCorpus < Minitest::Test
  ROOT = File.expand_path('..', __dir__)
  SPEC_PATH = File.join(ROOT, 'spec/self_hosting/BASIC_SHARP_SELF_HOSTING_FIXTURE_CORPUS_v1.json')

  def spec
    @spec ||= JSON.parse(File.read(SPEC_PATH, encoding: 'UTF-8'))
  end

  def corpus
    @corpus ||= BasicSharp::SelfHostingFixtureCorpus.new(spec).to_h
  end

  def test_contract_identity
    assert_equal 'bsharp.self_hosting.fixture_corpus.json', spec.fetch('format')
    assert_equal 1, spec.fetch('format_version')
    assert_equal BasicSharp::VERSION, spec.fetch('target_version')
    assert_equal 'self_hosting_fixture_corpus_under_ruby_referee', spec.fetch('status')
  end

  def test_dklab_is_retired_as_compatibility_bridge
    assert_equal 'Elderedd Softworks LLC', spec.fetch('company_identity')
    assert_equal 'Elderedd Laboratory', spec.fetch('workspace_identity')
    assert_includes spec.fetch('workspace_meaning'), 'compatibility bridge'
    assert_includes spec.fetch('scope').fetch('forbidden'), 'removing the DKLab compatibility bridge before later accepted validation'
  end

  def test_fixture_corpus_covers_profiles_one_through_seven_without_profile_eight
    profiles = corpus.fetch(:profile_counts).keys
    spec.fetch('required_profiles').each { |profile| assert_includes profiles, profile }
    refute_includes profiles, 'bsharp.bytecode.v8'
    assert_operator corpus.fetch(:fixture_count), :>=, spec.fetch('minimum_fixture_count')
  end

  def test_every_fixture_matches_locked_pipeline_records
    assert corpus.fetch(:all_pass)
    corpus.fetch(:fixtures).each do |fixture|
      assert fixture.fetch(:passes), fixture.fetch(:name)
      assert fixture.fetch(:checks).values.all?, fixture.fetch(:name)
      assert_equal fixture.fetch(:expected_binary_sha256), fixture.fetch(:binary_sha256), fixture.fetch(:name)
      assert_equal fixture.fetch(:expected_loader_summary_sha256), fixture.fetch(:loader_summary_sha256), fixture.fetch(:name)
      assert_equal fixture.fetch(:expected_bsharp_ir_sha256), fixture.fetch(:bsharp_ir_sha256), fixture.fetch(:name)
      assert_equal fixture.fetch(:expected_symbols_sha256), fixture.fetch(:symbol_table_sha256), fixture.fetch(:name)
      assert_equal fixture.fetch(:expected_errors_sha256), fixture.fetch(:errors_sha256), fixture.fetch(:name)
    end
  end

  def test_trial_by_fire_inventory_runs_the_fixture_corpus_tool
    inventory = JSON.parse(File.read(File.join(ROOT, 'spec/trial_by_fire/BASIC_SHARP_TRIAL_BY_FIRE_VALIDATION_INVENTORY_v1.json'), encoding: 'UTF-8'))
    tools = inventory.fetch('required_tools').map { |entry| entry.fetch('path') }
    assert_includes tools, 'tools/self_hosting_fixture_corpus.rb'
  end
end
